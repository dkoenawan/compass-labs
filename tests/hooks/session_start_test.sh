#!/usr/bin/env bash
# session_start_test.sh
# Exercises hooks/session-start.sh: the "Active sessions" list only
# appears for the orchestrator agent_type, never touches archive/, and
# always exits 0.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

HOOK="$REPO_ROOT/hooks/session-start.sh"

build_input() {
  local agent_type="$1" cwd="$2"
  if [[ -n "$agent_type" ]]; then
    jq -n --arg at "$agent_type" --arg c "$cwd" '{agent_type:$at, cwd:$c}'
  else
    jq -n --arg c "$cwd" '{cwd:$c}'
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

# 1. compass-labs:orchestrator sees active + paused, not archived/closed.
repo="$(new_fixture_repo)"
make_session_fixture "$repo" "2026-01-01-active-one" implement active none >/dev/null
make_session_fixture "$repo" "2026-01-02-paused-one" test paused test >/dev/null
make_session_fixture "$repo" "2026-01-03-closed-one" close archived close >/dev/null
git_commit_all "$repo" "fixture sessions"

run_hook "$HOOK" "$(build_input compass-labs:orchestrator "$repo")"
assert_eq "0" "$HOOK_EXIT" "hook should always exit 0"
assert_contains "$HOOK_STDOUT" "2026-01-01-active-one" "active session should be listed"
assert_contains "$HOOK_STDOUT" "2026-01-02-paused-one" "paused session should be listed"
assert_not_contains "$HOOK_STDOUT" "2026-01-03-closed-one" "archived session should NOT be listed"

# 2. Bare "orchestrator" agent_type is also accepted (namespacing tolerance).
run_hook "$HOOK" "$(build_input orchestrator "$repo")"
assert_eq "0" "$HOOK_EXIT" "hook should always exit 0"
assert_contains "$HOOK_STDOUT" "2026-01-01-active-one" "bare 'orchestrator' agent_type should also get the list"

# 3. Any other agent_type: no output, still exit 0.
run_hook "$HOOK" "$(build_input compass-labs:implement "$repo")"
assert_eq "0" "$HOOK_EXIT" "hook should always exit 0"
assert_eq "" "$HOOK_STDOUT" "non-orchestrator agent_type should print nothing"

# 4. No agent_type at all (plain session start): no output, exit 0.
run_hook "$HOOK" "$(build_input "" "$repo")"
assert_eq "0" "$HOOK_EXIT" "hook should always exit 0"
assert_eq "" "$HOOK_STDOUT" "no agent_type should print nothing"

# 5. No sessions at all -> explicit "none" message, still exit 0.
empty_repo="$(new_fixture_repo)"
run_hook "$HOOK" "$(build_input compass-labs:orchestrator "$empty_repo")"
assert_eq "0" "$HOOK_EXIT" "hook should always exit 0"
assert_contains "$HOOK_STDOUT" "Active sessions: none" "empty session list should say so explicitly"
assert_contains "$HOOK_STDOUT" "/compass-labs:session new" \
  "the none message should name the real slash command (VER-020)"

# 6. docs/sessions/archive/<slug>/log.md is never scanned even if malformed.
archive_repo="$(new_fixture_repo)"
mkdir -p "$archive_repo/docs/sessions/archive/2020-01-01-old"
cat > "$archive_repo/docs/sessions/archive/2020-01-01-old/log.md" <<'EOF'
---
session: 2020-01-01-old
status: active
phase: close
next_step: "should never appear"
---
EOF
git_commit_all "$archive_repo" "archive fixture"
run_hook "$HOOK" "$(build_input compass-labs:orchestrator "$archive_repo")"
assert_eq "0" "$HOOK_EXIT" "hook should always exit 0"
assert_not_contains "$HOOK_STDOUT" "should never appear" "archive/ must never be scanned"

# 7. Fail open (silently) when jq is unavailable.
nojq_bin="$(mktemp -d)"
cleanup_dirs+=("$nojq_bin")
make_path_without_jq "$nojq_bin"
saved_path="$PATH"
PATH="$nojq_bin"
run_hook "$HOOK" "$(PATH="$saved_path" build_input compass-labs:orchestrator "$repo")"
PATH="$saved_path"
assert_eq "0" "$HOOK_EXIT" "missing jq should still exit 0 (fail open)"

# 8. #37 DES-008 (component): the list is built from list-sessions.sh's
#    output, with `on {branch}` for a session that isn't in the working
#    tree. The lister is a test double here: the hook is copied into a
#    scratch plugin layout whose list-sessions.sh prints $STUB_SESSIONS.
plugin="$(mktemp -d)"
cleanup_dirs+=("$plugin")
mkdir -p "$plugin/hooks" "$plugin/skills/session/scripts"
cp "$HOOK" "$plugin/hooks/"
cat > "$plugin/skills/session/scripts/list-sessions.sh" <<'EOF'
#!/usr/bin/env bash
echo "$1" >> "${STUB_CALLS:-/dev/null}"
[[ -n "${STUB_SESSIONS:-}" ]] && printf '%s\n' "$STUB_SESSIONS"
exit 0
EOF
STUB_HOOK="$plugin/hooks/session-start.sh"

branch_repo="$(new_fixture_repo)"
git -C "$branch_repo" checkout -q -b main 2>/dev/null || git -C "$branch_repo" switch -q -c main
echo seed > "$branch_repo/README"
git_commit_all "$branch_repo" seed
git -C "$branch_repo" switch -q -c feat/5-widget
make_session_fixture "$branch_repo" "2026-01-05-widget" design active define >/dev/null
git_commit_all "$branch_repo" "widget session"
git -C "$branch_repo" switch -q main
make_session_fixture "$branch_repo" "2026-01-06-here" define paused none >/dev/null

export STUB_CALLS="$plugin/calls"
export STUB_SESSIONS=$'2026-01-06-here\tpaused\tmain\t-\n2026-01-05-widget\tactive\tfeat/5-widget\tfeat/5-widget'
run_hook "$STUB_HOOK" "$(build_input compass-labs:orchestrator "$branch_repo")"
assert_eq "0" "$HOOK_EXIT" "hook should always exit 0"
assert_contains "$HOOK_STDOUT" "- 2026-01-05-widget (#1, active) — on feat/5-widget — phase: design — next: test fixture" \
  "a session only on another branch should be listed with its branch, read from that branch's log.md"
assert_contains "$HOOK_STDOUT" "- 2026-01-06-here (#1, paused) — phase: define — next: test fixture" \
  "a working-tree session should be listed without 'on {branch}'"
assert_contains "$(cat "$STUB_CALLS")" "$branch_repo" "the hook should ask list-sessions.sh about the repo root"
assert_eq "main" "$(git -C "$branch_repo" branch --show-current)" "the hook must not switch branches"

# Empty lister output -> the "none" message.
export STUB_SESSIONS=""
run_hook "$STUB_HOOK" "$(build_input compass-labs:orchestrator "$branch_repo")"
assert_contains "$HOOK_STDOUT" "Active sessions: none" "no listed session should give the none message"

# No lister at all -> nothing printed, still exit 0 (never a misleading "none").
rm "$plugin/skills/session/scripts/list-sessions.sh"
run_hook "$STUB_HOOK" "$(build_input compass-labs:orchestrator "$branch_repo")"
assert_eq "0" "$HOOK_EXIT" "a missing lister should still exit 0"
assert_eq "" "$HOOK_STDOUT" "a missing lister should print nothing"
unset STUB_SESSIONS STUB_CALLS

echo "ok: session-start.sh validated"
exit 0
