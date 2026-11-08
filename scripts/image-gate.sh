#!/usr/bin/env bash
# What a change does to the images that reach the cluster: vulnerabilities,
# packages, files. Fails only on CRITICAL findings; everything else informs.
#
# Images come from the difference between the rendered cluster at each ref, not
# from the diff of the files: a reference is split across `repository` and `tag`,
# and usually only one of the two shows up in a diff.
#
# Writes a markdown report to $SUMMARY (default stdout).
#
# Usage (from repo root):
#   ./scripts/image-gate.sh <base-ref> <head-ref>
set -euo pipefail

PLATFORM="${PLATFORM:-linux/arm64}"
SEVERITY="${SEVERITY:-CRITICAL}"
SUMMARY="${SUMMARY:-/dev/stdout}"
MAX_ROWS="${MAX_ROWS:-25}"
ENTRYPOINT="kubernetes/clusters/home/entrypoint"

[[ $# -eq 2 ]] || { echo "usage: $0 <base-ref> <head-ref>" >&2; exit 2; }
base="$1"; head="$2"

for bin in flate trivy syft crane jq git; do
  command -v "$bin" >/dev/null || { echo "error: $bin not found" >&2; exit 2; }
done

for ref in "$base" "$head"; do
  [[ -n "$ref" ]] || { echo "error: empty ref" >&2; exit 2; }
  git rev-parse --verify --quiet "$ref^{commit}" >/dev/null \
    || { echo "error: unknown ref '$ref' (shallow checkout? needs fetch-depth: 0)" >&2; exit 2; }
done

ROOT="$(git rev-parse --show-toplevel)"; cd "$ROOT"
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

# Pair by digest, not by reference: a retag moves the tag and not the bytes.
python3 - "$TMP/base.txt" "$TMP/head.txt" > "$TMP/pairs.tsv" <<'PY'
import sys, collections

def load(path):
    by_repo = collections.defaultdict(set)
    for line in open(path):
        ref = line.strip()
        if not ref:
            continue
        head = ref.split('@')[0]
        repo = head.rsplit(':', 1)[0] if ':' in head else head
        by_repo[repo].add((ref.split('@')[1] if '@' in ref else '', ref))
    return by_repo

base, head = load(sys.argv[1]), load(sys.argv[2])
for repo, entries in sorted(head.items()):
    old = base.get(repo, set())
    old_digests = {d for d, _ in old}
    new_digests = {d for d, _ in entries}
    for digest, ref in sorted(entries):
        if digest in old_digests:
            continue
        prev = sorted(r for d, r in old if d not in new_digests)
        print(f"{repo}\t{prev[0] if prev else ''}\t{ref}")
PY

count=$(grep -c . "$TMP/pairs.tsv" || true)
if [[ "$count" -eq 0 ]]; then
  printf '## Image gate\n\nNo image reaching the cluster changed between `%s` and `%s`.\n' "$base" "$head" > "$SUMMARY"
  exit 0
fi

tag_of() { local r="${1%%@*}"; [[ "$r" == *:* ]] && echo "${r##*:}" || echo "—"; }

rc=0; blocked=0
: > "$TMP/rows"; : > "$TMP/details"

while IFS=$'\t' read -r repo old new; do
  [[ -z "$new" ]] && continue
  echo "  $repo"

  # Vulnerabilities — the only thing that decides the verdict.
  cve="?"; mark="⚠️"
  if trivy image --quiet --image-src remote --format json --severity "$SEVERITY" \
       --platform "$PLATFORM" "$new" > "$TMP/t.json" 2>"$TMP/t.err" && [[ -s "$TMP/t.json" ]]; then
    cve=$(jq '[.Results[]?.Vulnerabilities[]?] | unique_by(.VulnerabilityID + .PkgName) | length' "$TMP/t.json")
    if [[ "$cve" -gt 0 ]]; then mark="❌"; rc=1; blocked=$((blocked+1)); else mark="✅"; fi
  else
    rc=1; blocked=$((blocked+1))
    { echo "<details><summary><code>$repo</code> — scan failed</summary>"; echo; echo '```'
      tail -12 "$TMP/t.err"; echo '```'; echo; echo "</details>"; echo; } >> "$TMP/details"
  fi

  # Contents — informational.
  pkg="—"; files="—"; bins=0; bins_cell="—"
  if [[ -n "$old" ]]; then
    syft scan --platform "$PLATFORM" -q -o json "$old" 2>/dev/null | jq -r '.artifacts[] | "\(.name)@\(.version)"' | sort -u > "$TMP/p.old" || true
    syft scan --platform "$PLATFORM" -q -o json "$new" 2>/dev/null | jq -r '.artifacts[] | "\(.name)@\(.version)"' | sort -u > "$TMP/p.new" || true
    [[ -s "$TMP/p.old" && -s "$TMP/p.new" ]] && pkg="+$(comm -13 "$TMP/p.old" "$TMP/p.new" | wc -l) −$(comm -23 "$TMP/p.old" "$TMP/p.new" | wc -l)"

    files_ok=1
    for side in old new; do
      ref=$([[ "$side" == old ]] && echo "$old" || echo "$new")
      crane export --platform "$PLATFORM" "$ref" - 2>/dev/null | tar -tf - 2>/dev/null | sort -u > "$TMP/f.$side" || true
      [[ -s "$TMP/f.$side" ]] || files_ok=0
    done
    if [[ "$files_ok" -eq 1 ]]; then
      files="+$(comm -13 "$TMP/f.old" "$TMP/f.new" | wc -l) −$(comm -23 "$TMP/f.old" "$TMP/f.new" | wc -l)"
      comm -13 "$TMP/f.old" "$TMP/f.new" | grep -E '^(usr/local/bin|usr/bin|bin|sbin|usr/sbin)/' > "$TMP/f.exec" || true
      bins=$(grep -c . "$TMP/f.exec" || true)
      bins_cell=$([[ "$bins" -gt 0 ]] && echo "**$bins**" || echo "0")
    else
      files="n/a"; bins_cell="n/a"
    fi
  fi

  ver=$([[ -n "$old" ]] && echo "$(tag_of "$old") → $(tag_of "$new")" || echo "$(tag_of "$new") (new)")
  printf '| `%s` | %s | %s | %s | %s | %s | %s |\n' \
    "${repo##*/}" "$ver" "$cve" "$pkg" "$files" "$bins_cell" "$mark" >> "$TMP/rows"

  # A path with no package behind it is what an SBOM cannot show.
  if [[ "$bins" -gt 0 ]]; then
    { echo "<details open><summary><code>$repo</code> — $bins new executable path(s), carrying no package metadata</summary>"; echo
      echo '```'; head -"$MAX_ROWS" "$TMP/f.exec"
      [[ "$bins" -gt "$MAX_ROWS" ]] && echo "... and $((bins - MAX_ROWS)) more"
      echo '```'; echo; echo "</details>"; echo; } >> "$TMP/details"
  fi
  if [[ "$cve" != "?" && "$cve" -gt 0 ]]; then
    { echo "<details><summary><code>$repo</code> — $cve $SEVERITY</summary>"; echo
      echo "| CVE | Package | Installed | Fixed in |"; echo "|---|---|---|---|"
      jq -r '[.Results[]?.Vulnerabilities[]?] | unique_by(.VulnerabilityID + .PkgName) | sort_by(.VulnerabilityID)
             | .[] | "| [\(.VulnerabilityID)](\(.PrimaryURL // "https://nvd.nist.gov/vuln")) | \(.PkgName) | \(.InstalledVersion) | \(.FixedVersion // "—") |"' "$TMP/t.json"
      echo; echo "</details>"; echo; } >> "$TMP/details"
  fi
  if [[ -n "$old" && "$pkg" != "—" && "$pkg" != "+0 −0" ]]; then
    { echo "<details><summary><code>$repo</code> — package changes</summary>"; echo; echo '```'
      comm -13 "$TMP/p.old" "$TMP/p.new" | sed 's/^/+ /' | head -"$MAX_ROWS"
      comm -23 "$TMP/p.old" "$TMP/p.new" | sed 's/^/- /' | head -"$MAX_ROWS"
      echo '```'; echo; echo "</details>"; echo; } >> "$TMP/details"
  fi
done < "$TMP/pairs.tsv"

plural=$([[ "$count" -eq 1 ]] && echo image || echo images)
{
  if [[ "$rc" -eq 0 ]]; then
    echo "## ✅ Image gate — $count $plural, no $SEVERITY findings"
  else
    echo "## ❌ Image gate — $blocked of $count $plural blocked"
  fi
  echo
  echo "| Image | Version | $SEVERITY | Packages | Files | New bins | |"
  echo "|---|---|--:|--:|--:|--:|:-:|"
  cat "$TMP/rows"
  echo
  [[ -s "$TMP/details" ]] && cat "$TMP/details"
} > "$SUMMARY"

exit "$rc"
