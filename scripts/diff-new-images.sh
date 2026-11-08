#!/usr/bin/env bash
# Report what changed inside the images a change introduces: packages and files.
#
# Trivy answers "is there a known vulnerability". This answers "what appeared",
# which is the question a rugpull fails. Informational: never exits non-zero on
# a finding, because a legitimate base bump moves dozens of packages.
#
# Writes a markdown report to $SUMMARY (default stdout).
#
# Usage (from repo root):
#   ./scripts/diff-new-images.sh <base-ref> <head-ref>
set -euo pipefail

PLATFORM="${PLATFORM:-linux/arm64}"
SUMMARY="${SUMMARY:-/dev/stdout}"
MAX_ROWS="${MAX_ROWS:-25}"
ENTRYPOINT="kubernetes/clusters/home/entrypoint"

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <base-ref> <head-ref>" >&2
  exit 2
fi
base="$1"; head="$2"

for bin in flate syft crane git; do
  command -v "$bin" >/dev/null || { echo "error: $bin not found" >&2; exit 2; }
done

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TMP="$(mktemp -d)"
cleanup() {
  git worktree remove --force "$TMP/base" 2>/dev/null || true
  git worktree remove --force "$TMP/head" 2>/dev/null || true
  rm -rf "$TMP"
}
trap cleanup EXIT

render() {
  flate build all --path "$1/$ENTRYPOINT" --allow-missing-secrets \
    | grep -ohE '^[[:space:]]*image:[[:space:]]+[a-z0-9][^[:space:]]*' \
    | sed 's/.*image:[[:space:]]*//' | sort -u
}

git worktree add --detach --quiet "$TMP/base" "$base"
git worktree add --detach --quiet "$TMP/head" "$head"
render "$TMP/base" > "$TMP/base.txt"
render "$TMP/head" > "$TMP/head.txt"

# A repository whose digest changed, with the ref it replaces. Matching on the
# whole string would flag a retag, where only the tag moved and the bytes did not.
python3 - "$TMP/base.txt" "$TMP/head.txt" > "$TMP/pairs.tsv" <<'PY'
import sys, collections

def load(path):
    by_repo = collections.defaultdict(set)
    for line in open(path):
        ref = line.strip()
        if not ref:
            continue
        repo = ref.split('@')[0].rsplit(':', 1)[0] if ':' in ref.split('@')[0] else ref.split('@')[0]
        digest = ref.split('@')[1] if '@' in ref else ''
        by_repo[repo].add((digest, ref))
    return by_repo

base, head = load(sys.argv[1]), load(sys.argv[2])
for repo, entries in sorted(head.items()):
    old = base.get(repo, set())
    old_digests = {d for d, _ in old}
    for digest, ref in sorted(entries):
        if digest in old_digests:
            continue
        prev = sorted(r for d, r in old if d not in {x for x, _ in entries})
        print(f"{repo}\t{prev[0] if prev else ''}\t{ref}")
PY

count=$(grep -c . "$TMP/pairs.tsv" || true)
{ echo "## Image contents"; echo; } > "$TMP/md"

if [[ "$count" -eq 0 ]]; then
  echo "No image digest changed between \`$base\` and \`$head\`." >> "$TMP/md"
  cat "$TMP/md" > "$SUMMARY"
  exit 0
fi

echo "comparing $count image(s) on $PLATFORM"
while IFS=$'\t' read -r repo old new; do
  [[ -z "$new" ]] && continue
  if [[ -z "$old" ]]; then
    { echo "### \`$repo\`"; echo; echo "New image, nothing to compare against."; echo; } >> "$TMP/md"
    continue
  fi

  syft scan --platform "$PLATFORM" -q -o json "$old" 2>/dev/null \
    | jq -r '.artifacts[] | "\(.name)@\(.version)"' | sort -u > "$TMP/pkg.old" || true
  syft scan --platform "$PLATFORM" -q -o json "$new" 2>/dev/null \
    | jq -r '.artifacts[] | "\(.name)@\(.version)"' | sort -u > "$TMP/pkg.new" || true

  crane export --platform "$PLATFORM" "$old" - 2>/dev/null | tar -tf - 2>/dev/null | sort -u > "$TMP/f.old" || true
  crane export --platform "$PLATFORM" "$new" - 2>/dev/null | tar -tf - 2>/dev/null | sort -u > "$TMP/f.new" || true

  pkg_add=$(comm -13 "$TMP/pkg.old" "$TMP/pkg.new" | wc -l)
  pkg_del=$(comm -23 "$TMP/pkg.old" "$TMP/pkg.new" | wc -l)
  f_add=$(comm -13 "$TMP/f.old" "$TMP/f.new" | wc -l)
  f_del=$(comm -23 "$TMP/f.old" "$TMP/f.new" | wc -l)

  # A file with no package behind it is what an SBOM cannot show and a backdoor needs.
  comm -13 "$TMP/f.old" "$TMP/f.new" | grep -E '^(usr/local/bin|usr/bin|bin|sbin|usr/sbin)/' > "$TMP/f.exec" || true
  n_exec=$(grep -c . "$TMP/f.exec" || true)

  {
    echo "### \`$repo\`"
    echo
    oldtag="${old%%@*}"; oldtag="${oldtag##*:}"
    newtag="${new%%@*}"; newtag="${newtag##*:}"
    echo "\`$oldtag\` → \`$newtag\`"
    echo
    echo "| | Added | Removed |"
    echo "|---|---:|---:|"
    echo "| Packages | $pkg_add | $pkg_del |"
    echo "| Files | $f_add | $f_del |"
    echo
    if [[ "$n_exec" -gt 0 ]]; then
      echo "**$n_exec new executable path(s)** — these carry no package metadata, so no SBOM shows them:"
      echo
      echo '```'
      head -"$MAX_ROWS" "$TMP/f.exec"
      [[ "$n_exec" -gt "$MAX_ROWS" ]] && echo "... and $((n_exec - MAX_ROWS)) more"
      echo '```'
      echo
    fi
    if [[ "$pkg_add" -gt 0 ]]; then
      echo "<details><summary>$pkg_add package(s) added</summary>"; echo; echo '```'
      comm -13 "$TMP/pkg.old" "$TMP/pkg.new" | head -"$MAX_ROWS"
      [[ "$pkg_add" -gt "$MAX_ROWS" ]] && echo "... and $((pkg_add - MAX_ROWS)) more"
      echo '```'; echo; echo "</details>"; echo
    fi
  } >> "$TMP/md"
  echo "  $repo: +$pkg_add/-$pkg_del packages, +$f_add/-$f_del files, $n_exec new exec paths"
done < "$TMP/pairs.tsv"

cat "$TMP/md" > "$SUMMARY"
