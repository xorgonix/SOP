#!/usr/bin/env bash
# dump_source.sh — Dump all source file paths and contents for LLM context.
# Usage: bash dump_source.sh [output_file]
# Recurses all source dirs, ignores cache/history/vendor/IDE folders.

set -euo pipefail

OUTFILE="${1:-/dev/stdout}"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Directories to always skip
SKIP_DIRS=(
  .git
  pb_data
  pb_migrations
  vendor
  node_modules
  .idea
  .vscode
  tmp
  dist
  __pycache__
  .cache
)

# File extensions to include
INCLUDE_EXTS=(
  md
)

is_skipped() {
  local path="$1"
  local rel="${path#$REPO_ROOT/}"
  for skip in "${SKIP_DIRS[@]}"; do
    if [[ "/$rel/" == */"$skip"/* ]]; then
      return 0
    fi
  done
  return 1
}

has_valid_ext() {
  local file="$1"
  local ext="${file##*.}"
  for ie in "${INCLUDE_EXTS[@]}"; do
    if [[ "$ext" == "$ie" ]]; then
      return 0
    fi
  done
  return 1
}

{
  echo "# Source dump from $(date -Iseconds)"
  echo "# Repo: $REPO_ROOT"
  echo ""

  while IFS= read -r -d '' file; do
    if is_skipped "$file" || ! has_valid_ext "$file"; then
      continue
    fi
    relpath="${file#$REPO_ROOT/}"
    size=$(stat -c%s "$file" 2>/dev/null || echo 0)
    if (( size > 100000 )); then
      continue
    fi

    echo "===== $relpath ====="
    cat "$file"
    echo ""
    echo ""
  done < <(find "$REPO_ROOT" -type f -print0 2>/dev/null | head -z -n 5000)
} > "$OUTFILE"

echo "Dumped to $OUTFILE ($(wc -l < "$OUTFILE") lines)"
