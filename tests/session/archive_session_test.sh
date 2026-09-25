#!/usr/bin/env bash
# archive_session_test.sh
# Exercises skills/session/scripts/archive-session.sh: refuses unless
# log.md says status: archived and the tree is clean, otherwise moves
# the folder into docs/sessions/archive/.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/session/scripts/archive-session.sh"

cleanup_dirs=()
trap 'for d in "${cleanup_dirs[@]:-}"; do rm -rf "$d"; done' EXIT

new_fixture_repo() {
  local dir
  dir="$(make_temp_git_repo)"
  cleanup_dirs+=("$dir")
  echo "$dir"
}

# 1. status not "archived" -> refused.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" close active none)"
git_commit_all "$repo" "initial"
out="$(bash "$SCRIPT" "$session_dir" 2>&1)"
status=$?
assert_eq "1" "$status" "status != archived should be refused"
assert_contains "$out" "not 'archived'" "reason should name the status problem"
[[ -d "$session_dir" ]] || fail "session dir should NOT have moved"

# 2. status archived but dirty tree -> refused.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-02-sess" close archived close)"
git_commit_all "$repo" "initial"
echo "uncommitted change" >> "$session_dir/log.md"
out="$(bash "$SCRIPT" "$session_dir" 2>&1)"
status=$?
assert_eq "1" "$status" "a dirty tree should be refused"
assert_contains "$out" "dirty" "reason should mention the dirty tree"
[[ -d "$session_dir" ]] || fail "session dir should NOT have moved"

# 3. status archived, clean tree -> archived successfully.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-03-sess" close archived close)"
git_commit_all "$repo" "initial, already archived + clean"
out="$(bash "$SCRIPT" "$session_dir" 2>&1)"
status=$?
assert_eq "0" "$status" "a clean, already-archived-status session should move successfully"
assert_contains "$out" "ok:" "should print an ok message"
[[ -d "$session_dir" ]] && fail "original session dir should no longer exist"
[[ -d "$repo/docs/sessions/archive/2026-01-03-sess" ]] || fail "session should now be under docs/sessions/archive/"
[[ -f "$repo/docs/sessions/archive/2026-01-03-sess/log.md" ]] || fail "log.md should have moved with it"

# 4. Already-archived path (session-dir itself under archive/) -> refused.
out="$(bash "$SCRIPT" "$repo/docs/sessions/archive/2026-01-03-sess" 2>&1)"
status=$?
assert_eq "1" "$status" "archiving an already-archived path should be refused"

# 5. No log.md at all -> refused.
repo="$(new_fixture_repo)"
mkdir -p "$repo/docs/sessions/2026-01-04-nolog"
out="$(bash "$SCRIPT" "$repo/docs/sessions/2026-01-04-nolog" 2>&1)"
status=$?
assert_eq "1" "$status" "a session with no log.md should be refused"

echo "ok: archive-session.sh validated"
exit 0
