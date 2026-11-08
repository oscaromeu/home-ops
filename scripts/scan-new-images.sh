#!/usr/bin/env bash
# Scan the container images a change introduces, and fail on any CRITICAL.
#
# Images are taken from the difference between the rendered cluster at each ref,
# not from the diff of the files: an image reference is split across `repository`
# and `tag`, and only one of the two usually shows up in a diff.
#
# Writes a markdown report to $SUMMARY (default stdout; in CI, $GITHUB_STEP_SUMMARY).
#
# Usage (from repo root):
#   ./scripts/scan-new-images.sh <base-ref> <head-ref>
set -euo pipefail

PLATFORM="${PLATFORM:-linux/arm64}"
SEVERITY="${SEVERITY:-CRITICAL}"
SUMMARY="${SUMMARY:-/dev/stdout}"
ENTRYPOINT="kubernetes/clusters/home/entrypoint"

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <base-ref> <head-ref>" >&2
  exit 2
fi
base="$1"; head="$2"

# In CI these come from the pull_request event; empty means the event payload
# was not there, which git would otherwise report as an unhelpful bad revision.
for ref in "$base" "$head"; do
  [[ -n "$ref" ]] || { echo "error: empty ref" >&2; exit 2; }
  git rev-parse --verify --quiet "$ref^{commit}" >/dev/null \
    || { echo "error: unknown ref '$ref' (shallow checkout? needs fetch-depth: 0)" >&2; exit 2; }
done

for bin in flate trivy jq git; do
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

comm -13 "$TMP/base.txt" "$TMP/head.txt" > "$TMP/new.txt"
count=$(grep -c . "$TMP/new.txt" || true)

{
  echo "## Image scan"
  echo
} > "$TMP/md"

if [[ "$count" -eq 0 ]]; then
  echo "No image reaching the cluster changed between \`$base\` and \`$head\`." >> "$TMP/md"
  cat "$TMP/md" > "$SUMMARY"
  exit 0
fi

plural=$([[ "$count" -eq 1 ]] && echo image || echo images)
echo "scanning $count new $plural on $PLATFORM"
rc=0
: > "$TMP/rows"
: > "$TMP/details"

while read -r image; do
  [[ -z "$image" ]] && continue
  name="${image%%@*}"; name="${name%%:*}"
  ver="${image#*:}"; ver="${ver%%@*}"
  [[ "$ver" == "$image" ]] && ver="—"

  trivy image --quiet --format json --severity "$SEVERITY" \
    --platform "$PLATFORM" "$image" > "$TMP/report.json" 2>"$TMP/err" || true

  if [[ ! -s "$TMP/report.json" ]]; then
    printf '| `%s` | %s | — | ⚠️ scan failed |\n' "$name" "$ver" >> "$TMP/rows"
    { echo "<details><summary><code>$name</code> — scan failed</summary>"; echo
      echo '```'; tail -20 "$TMP/err"; echo '```'; echo "</details>"; echo; } >> "$TMP/details"
    rc=1
    echo "  scan failed: $image"
    continue
  fi

  n=$(jq '[.Results[]?.Vulnerabilities[]?] | unique_by(.VulnerabilityID + .PkgName) | length' "$TMP/report.json")
  if [[ "$n" -eq 0 ]]; then
    printf '| `%s` | %s | 0 | ✅ |\n' "$name" "$ver" >> "$TMP/rows"
    echo "  clean: $image"
  else
    printf '| `%s` | %s | **%s** | ❌ |\n' "$name" "$ver" "$n" >> "$TMP/rows"
    { echo "<details><summary><code>$name</code> — $n $SEVERITY</summary>"; echo
      echo "| CVE | Package | Installed | Fixed in |"
      echo "|---|---|---|---|"
      jq -r '[.Results[]?.Vulnerabilities[]?]
             | sort_by(.VulnerabilityID) | unique_by(.VulnerabilityID + .PkgName)
             | .[] | "| [\(.VulnerabilityID)](\(.PrimaryURL // "https://nvd.nist.gov/vuln")) | \(.PkgName) | \(.InstalledVersion) | \(.FixedVersion // "—") |"' \
             "$TMP/report.json"
      echo; echo "</details>"; echo; } >> "$TMP/details"
    rc=1
    echo "  $n $SEVERITY: $image"
  fi
done < "$TMP/new.txt"

{
  if [[ "$rc" -eq 0 ]]; then
    echo "All $count new $plural clean — no $SEVERITY findings on \`$PLATFORM\`."
  else
    echo "$SEVERITY findings in new images. This blocks the merge."
  fi
  echo
  echo "| Image | Version | $SEVERITY | |"
  echo "|---|---|---:|:-:|"
  cat "$TMP/rows"
  echo
  [[ -s "$TMP/details" ]] && cat "$TMP/details"
} >> "$TMP/md"

cat "$TMP/md" > "$SUMMARY"
exit "$rc"
