#!/usr/bin/env bash
# find_active_plan_test.sh
# skills/task-executor/scripts/find-active-plan.sh finds an in-progress
# plan in both session layouts (#28 DES-011): the implement/ folder
# artifact (implement/tasks.md) and a past session's root tasks.md.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

FIND="$REPO_ROOT/skills/task-executor/scripts/find-active-plan.sh"

repo="$(make_temp_git_repo)"
trap 'rm -rf "$repo"' EXIT

write_plan() {
  local path="$1" status="$2"
  mkdir -p "$(dirname "$path")"
  printf -- '---\nissue: 1\nstatus: %s\n---\n\n- [ ] a task [DES-001]\n' "$status" >"$path"
}

# 1. No plan at all.
assert_eq "none" "$(bash "$FIND" "$repo")" "an empty repo has no active plan"

# 2. One in-progress plan in the implement/ folder layout.
write_plan "$repo/docs/sessions/2026-02-01-new/implement/tasks.md" in-progress
assert_eq "docs/sessions/2026-02-01-new/implement/tasks.md" "$(bash "$FIND" "$repo")" \
  "an implement/tasks.md plan should be found"

# 3. A complete plan in the legacy root layout isn't active.
write_plan "$repo/docs/sessions/2026-01-01-old/tasks.md" complete
assert_eq "docs/sessions/2026-02-01-new/implement/tasks.md" "$(bash "$FIND" "$repo")" \
  "a complete root tasks.md should not be found"

# 4. One in-progress plan in each layout -> both are reported.
write_plan "$repo/docs/sessions/2026-01-01-old/tasks.md" in-progress
out="$(bash "$FIND" "$repo")"
assert_contains "$out" "multiple:" "two in-progress plans should be reported as multiple"
assert_contains "$out" "docs/sessions/2026-01-01-old/tasks.md" "the legacy root plan should be found"
assert_contains "$out" "docs/sessions/2026-02-01-new/implement/tasks.md" "the implement/ plan should be found"

# 5. Only the legacy root plan in progress.
write_plan "$repo/docs/sessions/2026-02-01-new/implement/tasks.md" complete
assert_eq "docs/sessions/2026-01-01-old/tasks.md" "$(bash "$FIND" "$repo")" \
  "a legacy root tasks.md plan should be found"

# 6. doc-maintainer's fold-back eligibility reads both layouts.
dm="$(cat "$REPO_ROOT/skills/doc-maintainer/SKILL.md")"
assert_contains "$dm" '`implement/tasks.md`, or a root `tasks.md`' \
  "doc-maintainer's eligibility should read implement/tasks.md or a root tasks.md"

echo "ok: find-active-plan.sh finds plans in both layouts"
exit 0
