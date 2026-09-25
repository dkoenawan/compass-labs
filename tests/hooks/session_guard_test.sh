#!/usr/bin/env bash
# session_guard_test.sh
# Exercises hooks/session-guard.sh against tests/lib.sh fixtures: one test
# per D7 rule. Never touches the real repo's docs/sessions/.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

HOOK="$REPO_ROOT/hooks/session-guard.sh"

# build_input <tool_name> <file_path> <cwd> [agent_id] [agent_type]
build_input() {
  local tool_name="$1" file_path="$2" cwd="$3" agent_id="${4:-}" agent_type="${5:-}"
  if [[ -n "$agent_id" ]]; then
    jq -n --arg t "$tool_name" --arg f "$file_path" --arg c "$cwd" --arg ai "$agent_id" --arg at "$agent_type" \
      '{tool_name:$t, tool_input:{file_path:$f}, cwd:$c, agent_id:$ai, agent_type:$at}'
  else
    jq -n --arg t "$tool_name" --arg f "$file_path" --arg c "$cwd" \
      '{tool_name:$t, tool_input:{file_path:$f}, cwd:$c}'
  fi
}

cleanup_dirs=()
trap 'for d in "${cleanup_dirs[@]:-}"; do rm -rf "$d"; done' EXIT

new_fixture_repo() {
  local dir
  dir="$(make_temp_git_repo)"
  cleanup_dirs+=("$dir")
  echo "$dir"
}

# All fixture repos borrow the real plugin's workflows/feature.json unless
# a test deliberately wants a missing one.
export CLAUDE_PLUGIN_ROOT="$REPO_ROOT"

# 1. Non-session path is untouched by the guard.
repo="$(new_fixture_repo)"
echo "hello" > "$repo/README.md"
assert_hook_exit "$HOOK" "$(build_input Write "$repo/README.md" "$repo")" 0 \
  "non-session path should be allowed"

# 2. Archive is always blocked.
repo="$(new_fixture_repo)"
mkdir -p "$repo/docs/sessions/archive/2020-01-01-old"
assert_hook_exit "$HOOK" "$(build_input Write "$repo/docs/sessions/archive/2020-01-01-old/log.md" "$repo")" 2 \
  "archive writes should be blocked"
assert_hook_stderr_contains "archive" "archive block reason should mention archive"

# 3. Brand-new session: only log.md may be created first.
repo="$(new_fixture_repo)"
mkdir -p "$repo/docs/sessions/2026-01-01-new"
assert_hook_exit "$HOOK" "$(build_input Write "$repo/docs/sessions/2026-01-01-new/requirements.md" "$repo")" 2 \
  "writing anything but log.md before log.md exists should be blocked"

# 3b. A plan spec (overview.md) in a folder with no log.md is allowed —
# that's the `plan` skill's output, not a lifecycle session.
assert_hook_exit "$HOOK" "$(build_input Write "$repo/docs/sessions/2026-01-01-new/overview.md" "$repo")" 0 \
  "plan's overview.md should be allowed in a folder without log.md"

# 3c. Once log.md exists, overview.md is outside the lifecycle file set.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/overview.md" "$repo")" 2 \
  "overview.md should be blocked in a lifecycle session (has log.md)"

# 4. Disallowed top-level filename is blocked.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/notes.md" "$repo")" 2 \
  "an out-of-set filename should be blocked"
assert_hook_stderr_contains "not in this workflow's session file set"

# 5. Markdown under assets/ is blocked.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/assets/notes.md" "$repo")" 2 \
  "markdown under assets/ should be blocked"

# 5b. Non-markdown under assets/ is allowed.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/assets/diagram.png" "$repo")" 0 \
  "non-markdown under assets/ should be allowed"

# 6. Wrong-owner subagent is blocked.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" define active none)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/design.md" "$repo" agent-1 compass-labs:define)" 2 \
  "define agent writing design.md should be blocked (wrong owner)"
assert_hook_stderr_contains "owned by"

# 7. Owner subagent is allowed (artifact not yet frozen).
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active design)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/tasks.md" "$repo" agent-1 compass-labs:implement)" 0 \
  "implement agent writing tasks.md should be allowed"

# 8. log.md by a subagent is always blocked.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Edit "$session_dir/log.md" "$repo" agent-1 compass-labs:implement)" 2 \
  "log.md writes by a subagent should be blocked"
assert_hook_stderr_contains "orchestrator"

# 9. Frozen artifact, main session, no decision entry -> blocked.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" design active design)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Edit "$session_dir/requirements.md" "$repo")" 2 \
  "amending a frozen artifact without a logged decision should be blocked"
assert_hook_stderr_contains "frozen"

# 10. Frozen artifact, main session, with an uncommitted decision entry -> allowed.
cat >> "$session_dir/log.md" <<'EOF'

### 2026-01-02 — main — decision: amend requirements after freeze
- test-only decision entry
EOF
assert_hook_exit "$HOOK" "$(build_input Edit "$session_dir/requirements.md" "$repo")" 0 \
  "amending a frozen artifact with an uncommitted decision entry should be allowed"

# 11. Fail open when the workflow file can't be read.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial fixture"
CLAUDE_PLUGIN_ROOT="$repo" assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/tasks.md" "$repo")" 0 \
  "missing workflow file should fail open"

# --- Path-traversal regressions (defect found in batch 2 review) --------
# `docs/sessions/{id}/assets/../notes.txt` must be treated as the
# top-level file it lexically is, NOT as something under assets/ — even
# though assets/ doesn't exist on disk yet, so a `cd`-based normalization
# can't see it. Same rule family for stray `./` segments and a traversal
# that walks into archive/.

# 12. assets/../notes.txt is a disallowed top-level file, not an assets/ write.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active none)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/assets/../notes.txt" "$repo")" 2 \
  "assets/../notes.txt should be blocked like any other disallowed top-level file"
assert_hook_stderr_contains "not in this workflow's session file set" \
  "assets/../notes.txt should hit the allowlist check, not be waved through as an asset"

# 13. A leading ./ in the middle of the path is harmless once normalized.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/./requirements.md" "$repo" agent-1 compass-labs:define)" 0 \
  "./ segments should be collapsed and not change the ownership/allowlist outcome"

# 14. docs/sessions/s1/../s1/notes.txt: traversal that lands back in the
#     same session folder is still a disallowed top-level file.
assert_hook_exit "$HOOK" "$(build_input Write "$repo/docs/sessions/2026-01-01-sess/../2026-01-01-sess/notes.txt" "$repo")" 2 \
  "traversal that resolves back into the same session should still be blocked as an out-of-set file"

# 15. docs/sessions/../sessions/archive/x/log.md: traversal into archive/
#     must still be blocked, not misread as a non-archive path.
mkdir -p "$repo/docs/sessions/archive/x"
assert_hook_exit "$HOOK" "$(build_input Write "$repo/docs/sessions/../sessions/archive/x/log.md" "$repo")" 2 \
  "traversal into archive/ should still be blocked"
assert_hook_stderr_contains "archive"

echo "ok: session-guard.sh validated against all D7 rules"
exit 0
