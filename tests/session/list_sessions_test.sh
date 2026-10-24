#!/usr/bin/env bash
# list_sessions_test.sh
# Component tests for skills/session/scripts/list-sessions.sh (#37 DES-002,
# REQ-004, REQ-005): the script runs for real against throwaway repos. It
# lists active and paused sessions from the working tree (untracked files
# included) and from the tip of every local branch, never archive/, and a
# working-tree copy wins over a branch copy.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/session/scripts/list-sessions.sh"
[[ -x "$SCRIPT" ]] || fail "list-sessions.sh not found or not executable"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

TAB=$'\t'

# write_log <repo> <slug> <status> [branch-field]
write_log() {
  local repo="$1" slug="$2" status="$3" branch="${4:-}"
  mkdir -p "$repo/docs/sessions/$slug"
  {
    echo "---"
    echo "session: $slug"
    echo "type: feature"
    echo "issue: 5"
    [[ -n "$branch" ]] && echo "branch: $branch"
    echo "phase: define"
    echo "status: $status"
    echo "milestone: none"
    echo "---"
    echo "# Session Log: $slug"
  } > "$repo/docs/sessions/$slug/log.md"
}

run_script() {
  set +e
  OUT="$(bash "$SCRIPT" "$1" 2>"$work/err")"
  CODE=$?
  set -e 2>/dev/null || true
  ERR="$(cat "$work/err")"
}

repo="$work/repo"
git init -q -b main "$repo"
git -C "$repo" config user.email test@example.com
git -C "$repo" config user.name Test
echo seed > "$repo/README"
git_commit_all "$repo" seed

# 0. No sessions anywhere: empty output, exit 0.
run_script "$repo"
assert_eq "0" "$CODE" "empty repo should exit 0"
assert_eq "" "$OUT" "empty repo should print nothing"

# A session committed only on feat/5-widget, plus an archived session there.
git -C "$repo" switch -q -c feat/5-widget
write_log "$repo" "2026-01-05-widget" active feat/5-widget
mkdir -p "$repo/docs/sessions/archive/2025-12-01-old"
cat > "$repo/docs/sessions/archive/2025-12-01-old/log.md" <<'EOF'
---
session: 2025-12-01-old
status: active
---
EOF
write_log "$repo" "2026-01-04-closed" archived feat/5-widget
git_commit_all "$repo" "widget session"
git -C "$repo" switch -q main
[[ -d "$repo/docs/sessions/2026-01-05-widget" ]] && fail "fixture: widget session should not be in main's tree"

# 1. With main checked out, the branch-only session is listed with its branch.
run_script "$repo"
assert_eq "0" "$CODE" "should exit 0"
assert_contains "$OUT" "2026-01-05-widget${TAB}active${TAB}feat/5-widget${TAB}feat/5-widget" \
  "a session committed only on feat/5-widget should be listed with that branch"
assert_not_contains "$OUT" "2025-12-01-old" "an archived session must never be listed"
assert_not_contains "$OUT" "2026-01-04-closed" "a status: archived session must not be listed"
assert_eq "$(git -C "$repo" branch --show-current)" "main" "the script must not switch branches"

# 2. An untracked new log.md with status: active is listed (found on main),
#    and a session without a branch: field prints "-".
write_log "$repo" "2026-01-06-fresh" active
run_script "$repo"
assert_contains "$OUT" "2026-01-06-fresh${TAB}active${TAB}main${TAB}-" \
  "an untracked active log.md should be listed, found on the checked-out branch"

# 3. Paused sessions are listed; archived ones in the working tree aren't.
write_log "$repo" "2026-01-07-paused" paused main
mkdir -p "$repo/docs/sessions/archive/2026-01-01-gone"
printf -- '---\nstatus: active\n---\n' > "$repo/docs/sessions/archive/2026-01-01-gone/log.md"
run_script "$repo"
assert_contains "$OUT" "2026-01-07-paused${TAB}paused${TAB}main${TAB}main" "a paused session should be listed"
assert_not_contains "$OUT" "2026-01-01-gone" "archive/ in the working tree must never be listed"

# 4. A slug in the working tree wins over its branch copy.
write_log "$repo" "2026-01-05-widget" paused feat/5-widget
run_script "$repo"
assert_contains "$OUT" "2026-01-05-widget${TAB}paused${TAB}main${TAB}feat/5-widget" \
  "the working-tree copy should win"
assert_eq "1" "$(grep -c '^2026-01-05-widget' <<<"$OUT")" "a slug should be listed once"
rm -rf "$repo/docs/sessions/2026-01-05-widget" "$repo/docs/sessions/2026-01-06-fresh" \
  "$repo/docs/sessions/2026-01-07-paused" "$repo/docs/sessions/archive"

# 5. Same session on two branches: the copy on its recorded branch wins.
git -C "$repo" switch -q -c aaa-early feat/5-widget
write_log "$repo" "2026-01-05-widget" paused feat/5-widget
git_commit_all "$repo" "older copy on aaa-early"
git -C "$repo" switch -q main
run_script "$repo"
assert_contains "$OUT" "2026-01-05-widget${TAB}active${TAB}feat/5-widget${TAB}feat/5-widget" \
  "the copy on the recorded branch should win over another branch's copy"
assert_eq "1" "$(grep -c '^2026-01-05-widget' <<<"$OUT")" "a slug found on two branches should be listed once"

# 6. Works from a subdirectory and with no argument.
mkdir -p "$repo/sub"
run_script "$repo/sub"
assert_contains "$OUT" "2026-01-05-widget" "should resolve the repo root from a subdirectory"
OUT="$(cd "$repo" && bash "$SCRIPT")"
assert_contains "$OUT" "2026-01-05-widget" "no argument should mean the current directory"

# 7. Not a git repository: reads the working tree only, exit 0.
plain="$work/plain"
write_log "$plain" "2026-01-08-plain" active
run_script "$plain"
assert_eq "0" "$CODE" "a non-repo should still exit 0"
assert_contains "$OUT" "2026-01-08-plain${TAB}active${TAB}HEAD${TAB}-" "a non-repo's working tree should still be read"

# 8. A path that doesn't exist: exit 0, nothing listed.
run_script "$work/nowhere"
assert_eq "0" "$CODE" "a missing path should still exit 0"
assert_eq "" "$OUT" "a missing path should print nothing"

echo "ok: list-sessions.sh validated"
exit 0
