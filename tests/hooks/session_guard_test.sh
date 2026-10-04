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
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/design/index.md" "$repo" agent-1 compass-labs:define)" 2 \
  "define agent writing design/index.md should be blocked (wrong owner)"
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
#    Cases 9 and 10 use a past session's root requirements.md (the legacy
#    layout, D6), which must exist for the root path to be writable.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" design active design)"
echo "# Requirements" > "$session_dir/requirements.md"
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
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/./define/requirements.md" "$repo" agent-1 compass-labs:define)" 0 \
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

# --- Folder artifacts: define/ (#23 DES-020) -----------------------------

# 16. The define agent writes define/index.md in a new session -> allowed.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" define active none)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/index.md" "$repo" agent-1 compass-labs:define)" 0 \
  "define agent writing define/index.md in a new session should be allowed"

# 17. A file outside define/'s fixed set -> blocked.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/notes.md" "$repo" agent-1 compass-labs:define)" 2 \
  "define/notes.md is not one of define/'s files and should be blocked"
assert_hook_stderr_contains "not one of define/'s files"

# 18. Nested deeper than one level inside define/ -> unknown subdirectory.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/sub/x.md" "$repo" agent-1 compass-labs:define)" 2 \
  "define/sub/x.md should be blocked as an unknown subdirectory"
assert_hook_stderr_contains "unknown subdirectory"

# 18b. A subdirectory that isn't a declared folder artifact -> unknown subdirectory.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/notes/x.md" "$repo" agent-1 compass-labs:design)" 2 \
  "notes/x.md should be blocked: notes/ is not a folder artifact"
assert_hook_stderr_contains "unknown subdirectory"

# 19. The folder is owned as a unit: the design agent can't write in it.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/requirements.md" "$repo" agent-1 compass-labs:design)" 2 \
  "design agent writing define/requirements.md should be blocked (wrong owner)"
assert_hook_stderr_contains "owned by"

# 20. define/../notes.txt collapses to a top-level file -> allowlist block.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/../notes.txt" "$repo" agent-1 compass-labs:define)" 2 \
  "define/../notes.txt should be blocked by the allowlist"
assert_hook_stderr_contains "not in this workflow's session file set"

# 21. A new session (no root requirements.md) can't create one.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/requirements.md" "$repo" agent-1 compass-labs:define)" 2 \
  "a new session creating a root requirements.md should be blocked"
assert_hook_stderr_contains "new sessions write define/"

# 22. Frozen as a unit: after the define milestone, a subagent can't write
#     any file in define/, and the main session can with a decision.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" design active define)"
mkdir -p "$session_dir/define"
echo "# Define" > "$session_dir/define/index.md"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/problem.md" "$repo" agent-1 compass-labs:define)" 2 \
  "a subagent writing define/problem.md after the define milestone should be blocked"
assert_hook_stderr_contains "frozen"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/problem.md" "$repo")" 2 \
  "the main session amending frozen define/ without a decision should be blocked"
cat >> "$session_dir/log.md" <<'EOF'

### 2026-01-02 — main — decision: amend the problem statement after freeze
- test-only decision entry
EOF
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/problem.md" "$repo")" 0 \
  "the main session amending frozen define/ with an uncommitted decision should be allowed"

# 23. A past (legacy-layout) session can't start a define/ folder.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" define active none)"
echo "# Requirements" > "$session_dir/requirements.md"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/index.md" "$repo" agent-1 compass-labs:define)" 2 \
  "a legacy session writing define/index.md should be blocked"
assert_hook_stderr_contains "this session uses the root layout"

# 23b. ...and it keeps editing its root requirements.md as before.
assert_hook_exit "$HOOK" "$(build_input Edit "$session_dir/requirements.md" "$repo" agent-1 compass-labs:define)" 0 \
  "a legacy session editing its own root requirements.md should be allowed"

# 23c. Other top-level artifacts are unaffected by the layout rule.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/tasks.md" "$repo" agent-1 compass-labs:implement)" 0 \
  "tasks.md in a legacy session should be allowed for the implement agent"

# 24. Unreadable workflow + a path with a / -> still blocked (unknown subdirectory).
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" define active none)"
git_commit_all "$repo" "initial fixture"
CLAUDE_PLUGIN_ROOT="$repo" assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/define/index.md" "$repo")" 2 \
  "with an unreadable workflow, define/index.md should still be blocked"
assert_hook_stderr_contains "unknown subdirectory"

# --- Folder artifacts: design/ (#27 DES-010) ------------------------------

# 25. The design agent writes design/index.md in a new session -> allowed.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" design active define)"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/design/index.md" "$repo" agent-1 compass-labs:design)" 0 \
  "design agent writing design/index.md in a new session should be allowed"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/design/backend.md" "$repo" agent-1 compass-labs:design)" 0 \
  "design agent writing design/backend.md in a new session should be allowed"

# 26. A file outside design/'s fixed set -> blocked.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/design/notes.md" "$repo" agent-1 compass-labs:design)" 2 \
  "design/notes.md is not one of design/'s files and should be blocked"
assert_hook_stderr_contains "not one of design/'s files"

# 27. A new session (no root design.md) can't create one.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/design.md" "$repo" agent-1 compass-labs:design)" 2 \
  "a new session creating a root design.md should be blocked"
assert_hook_stderr_contains "new sessions write design/"

# 28. design/ is owned as a unit: another phase's agent can't write in it.
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/design/index.md" "$repo" agent-1 compass-labs:implement)" 2 \
  "implement agent writing design/index.md should be blocked (wrong owner)"
assert_hook_stderr_contains "owned by compass-labs:design"

# 29. Frozen as a unit after the design milestone.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" implement active design)"
mkdir -p "$session_dir/design"
echo "# Design" > "$session_dir/design/index.md"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/design/solution.md" "$repo" agent-1 compass-labs:design)" 2 \
  "a subagent writing design/solution.md after the design milestone should be blocked"
assert_hook_stderr_contains "frozen"

# 30. A past session with a root design.md keeps it and can't start design/.
repo="$(new_fixture_repo)"
session_dir="$(make_session_fixture "$repo" "2026-01-01-sess" design active define)"
echo "# Design" > "$session_dir/design.md"
git_commit_all "$repo" "initial fixture"
assert_hook_exit "$HOOK" "$(build_input Edit "$session_dir/design.md" "$repo" agent-1 compass-labs:design)" 0 \
  "a legacy session editing its own root design.md should be allowed"
assert_hook_exit "$HOOK" "$(build_input Write "$session_dir/design/index.md" "$repo" agent-1 compass-labs:design)" 2 \
  "a legacy session writing design/index.md should be blocked"
assert_hook_stderr_contains "this session uses the root layout"

echo "ok: session-guard.sh validated against all D7 rules"
exit 0
