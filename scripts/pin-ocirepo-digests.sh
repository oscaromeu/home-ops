#!/usr/bin/env bash
# Resolve every Flux OCIRepository chart under kubernetes/apps/ to a SHA256
# digest and write a `digest:` field next to the existing `tag:`. Run once.
#
# After this script runs, Renovate's flux manager keeps both `tag` and
# `digest` in sync on future version bumps (because the field already
# exists — the broken auto-pin behaviour only kicks in when adding a
# digest from scratch).
#
# Requires: crane (https://github.com/google/go-containerregistry)
#   brew install crane
#   # or
#   go install github.com/google/go-containerregistry/cmd/crane@latest
#
# Usage (from repo root):
#   ./scripts/pin-ocirepo-digests.sh           # rewrite all
#   ./scripts/pin-ocirepo-digests.sh --dry-run # show what would change
set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

if ! command -v crane >/dev/null 2>&1; then
  echo "error: crane not found. Install with one of:" >&2
  echo "  brew install crane" >&2
  echo "  go install github.com/google/go-containerregistry/cmd/crane@latest" >&2
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

FILES=()
while IFS= read -r line; do
  FILES+=("$line")
done < <(find kubernetes/apps -name 'ocirepository.yaml' | sort)
echo "Found ${#FILES[@]} OCIRepository files."

UPDATED=0
SKIPPED=0
FAILED=0

for f in "${FILES[@]}"; do
  url=$(awk '/^[[:space:]]*url:/ { sub("^[[:space:]]*url:[[:space:]]*",""); sub("^oci://",""); print; exit }' "$f")
  tag=$(awk '/^[[:space:]]*tag:/ { sub("^[[:space:]]*tag:[[:space:]]*",""); print; exit }' "$f")

  # Strip any potential `@sha256:...` Renovate may have left in `tag:` (PR #923 broken state)
  tag="${tag%@*}"

  if [[ -z "$url" || -z "$tag" ]]; then
    echo "[warn] $f: missing url/tag; skipping"
    SKIPPED=$((SKIPPED+1))
    continue
  fi

  ref="${url}:${tag}"
  printf "  %s -> %s ... " "$f" "$ref"

  digest=$(crane digest "$ref" 2>/dev/null || true)
  if [[ -z "$digest" ]]; then
    echo "FAILED (could not resolve)"
    FAILED=$((FAILED+1))
    continue
  fi

  if (( DRY_RUN == 1 )); then
    echo "$digest (dry-run)"
    continue
  fi

  python3 - "$f" "$tag" "$digest" <<'PYEOF'
import sys, re, pathlib

path = pathlib.Path(sys.argv[1])
tag, digest = sys.argv[2], sys.argv[3]
text = path.read_text()

# Indented `tag: ...` line — capture indent.
m = re.search(r'^(?P<indent>\s*)tag:\s*\S+\s*$', text, flags=re.M)
if not m:
    raise SystemExit(f"{path}: no `tag:` line found")
indent = m.group('indent')

# Replace the tag line with a clean tag-only line.
text = re.sub(r'^\s*tag:\s*\S+\s*$',
              f'{indent}tag: {tag}',
              text, count=1, flags=re.M)

# If a digest line already exists, replace it. Otherwise insert one right after tag.
if re.search(r'^\s*digest:\s*\S+\s*$', text, flags=re.M):
    text = re.sub(r'^\s*digest:\s*\S+\s*$',
                  f'{indent}digest: {digest}',
                  text, count=1, flags=re.M)
else:
    text = re.sub(r'^(\s*tag:\s*\S+\s*\n)',
                  rf'\1{indent}digest: {digest}\n',
                  text, count=1, flags=re.M)

path.write_text(text)
PYEOF

  echo "$digest"
  UPDATED=$((UPDATED+1))
done

echo
echo "Updated: $UPDATED   Skipped: $SKIPPED   Failed: $FAILED"
echo
echo "Review with:  git diff -- kubernetes/apps"
