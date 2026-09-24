#!/usr/bin/env bash
# session_commit_guard_test.sh
# Exercises hooks/session-commit-guard.sh (Stop, D8/REQ-016): blocks an
# uncommitted decision/milestone log entry, allows once committed, allows
# plain artifact edits with no such heading, allows after 2 consecutive
# blocks (loop guard), ignores archive/, and fails open outside git.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

HOOK="$REPO_ROOT/hooks/session-commit-guard.sh"
STATE_DIR="${TMPDIR:-/tmp}/compass-session-commit-guard"

cleanup_dirs=()
cleanup_state_files=()
trap '
  for d in "${cleanup_dirs[@]:-}"; do rm -rf "$d"; done
  for f in "${cleanup_state_files[@]:-}"; do rm -f "$f"; done
' EXIT

new_fixture_repo() {
  local dir
  dir="$(make_temp_git_repo)"
  cleanup_dirs+=("$dir")
  echo "$dir"
}

# build_input <session_id> <cwd>
build_input() {
  local session_id="$1" cwd="$2"
  jq -n --arg sid "$session_id" --arg c "$cwd" '{session_id:$sid, cwd:$c}'
}

fresh_session_id() {
  local sid
  sid="test-$$-$RANDOM-$RANDOM"
  cleanup_state_files+=("$STATE_DIR/$sid.count")
  echo "$sid"
}

# 1. Uncommitted decision entry -> blocked.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial"
cat >> "$session_dir/log.md" <<'EOF'

### 2026-01-02 — main — decision: something changed
- test-only decision entry
EOF
sid="$(fresh_session_id)"
assert_hook_exit "$HOOK" "$(build_input "$sid" "$repo")" 2 \
  "an uncommitted decision entry should block the stop"
assert_hook_stderr_contains "decision" "reason should mention the uncommitted entry"

# 2. Uncommitted milestone entry -> blocked.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial"
cat >> "$session_dir/log.md" <<'EOF'

### 2026-01-02 — main — milestone: something completed
- test-only milestone entry
EOF
sid="$(fresh_session_id)"
assert_hook_exit "$HOOK" "$(build_input "$sid" "$repo")" 2 \
  "an uncommitted milestone entry should block the stop"

# 3. Committed -> allowed.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
cat >> "$session_dir/log.md" <<'EOF'

### 2026-01-02 — main — decision: something changed
- test-only decision entry, committed
EOF
git_commit_all "$repo" "includes the decision entry"
sid="$(fresh_session_id)"
assert_hook_exit "$HOOK" "$(build_input "$sid" "$repo")" 0 \
  "a committed decision entry should not block the stop"

# 4. Plain uncommitted artifact edit, no decision/milestone heading -> allowed.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial"
echo "- some uncommitted requirement tweak" >> "$session_dir/requirements.md"
sid="$(fresh_session_id)"
assert_hook_exit "$HOOK" "$(build_input "$sid" "$repo")" 0 \
  "an uncommitted artifact edit with no decision/milestone heading should not block"

# 5. 3rd consecutive block for the same session -> allowed with a warning.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial"
cat >> "$session_dir/log.md" <<'EOF'

### 2026-01-02 — main — decision: something changed
- test-only decision entry
EOF
sid="$(fresh_session_id)"
input="$(build_input "$sid" "$repo")"
assert_hook_exit "$HOOK" "$input" 2 "1st block"
assert_hook_exit "$HOOK" "$input" 2 "2nd block"
assert_hook_exit "$HOOK" "$input" 0 "3rd attempt should be allowed with a warning"
assert_hook_stderr_contains "WARNING" "3rd attempt should print a warning"
# A 4th attempt (counter reset to 0 after the warning) should block again.
assert_hook_exit "$HOOK" "$input" 2 "4th attempt (counter reset) should block again"

# 6. archive/ is never scanned, even with an UNCOMMITTED decision heading
#    (appended after the initial commit, so the archive-skip is the only
#    thing that could allow the stop here — without it, this would block).
repo="$(new_fixture_repo)"
mkdir -p "$repo/docs/sessions/archive/2020-01-01-old"
cat > "$repo/docs/sessions/archive/2020-01-01-old/log.md" <<'EOF'
---
session: 2020-01-01-old
status: archived
---
# Session Log
EOF
git_commit_all "$repo" "archive fixture"
cat >> "$repo/docs/sessions/archive/2020-01-01-old/log.md" <<'EOF'

### 2020-01-02 — main — decision: should never be seen
- archived, must be ignored
EOF
sid="$(fresh_session_id)"
assert_hook_exit "$HOOK" "$(build_input "$sid" "$repo")" 0 \
  "archive/ log.md must never trigger the commit guard, even with an uncommitted decision heading"

# 7. Fail open outside a git repository.
nogit_dir="$(mktemp -d)"
cleanup_dirs+=("$nogit_dir")
sid="$(fresh_session_id)"
assert_hook_exit "$HOOK" "$(build_input "$sid" "$nogit_dir")" 0 \
  "outside a git repo, the hook should fail open"

echo "ok: session-commit-guard.sh validated"
exit 0
