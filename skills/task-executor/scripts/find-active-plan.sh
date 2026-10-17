#!/usr/bin/env bash
set -euo pipefail

# find-active-plan.sh <repo-path>
# Finds an in-progress plan (frontmatter status: in-progress) in either
# session layout: docs/sessions/*/implement/tasks.md (the implement/ folder
# artifact) or a past session's root docs/sessions/*/tasks.md (the legacy
# layout, never migrated).
# Stdout: path | "none" | "multiple:<path1>:<path2>..."

REPO="${1:?Usage: find-active-plan.sh <repo-path>}"
cd "$REPO"

mapfile -t FOUND < <(grep -l '^status: in-progress' docs/sessions/*/implement/tasks.md docs/sessions/*/tasks.md 2>/dev/null || true)

case "${#FOUND[@]}" in
  0) echo "none" ;;
  1) echo "${FOUND[0]}" ;;
  *) echo "multiple:$(IFS=:; echo "${FOUND[*]}")" ;;
esac
