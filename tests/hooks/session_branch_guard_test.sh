#!/usr/bin/env bash
# session_branch_guard_test.sh
# Component tests for hooks/session-branch-guard.sh (#37 DES-003, REQ-005,
# REQ-006, D1, D2). The hook runs for real against throwaway git repos, but
# its two collaborators, default-branch.sh and list-sessions.sh, are test
# doubles: the hook is copied into a scratch plugin layout whose
# skills/session/scripts/ holds stubs driven by env vars. The real
# hook-plus-scripts run is Test's integration check (as-built.md, Handed to
# Test).
#
# Stubs:
#   STUB_DEFAULT   default-branch.sh prints it and exits 0; empty -> exit 1
#   STUB_SESSIONS  list-sessions.sh prints it (empty = no session open)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

REAL_HOOK="$REPO_ROOT/hooks/session-branch-guard.sh"
[[ -f "$REAL_HOOK" ]] || fail "hooks/session-branch-guard.sh not found"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# --- Scratch plugin layout with stub collaborators ----------------------
plugin="$work/plugin"
mkdir -p "$plugin/hooks" "$plugin/skills/session/scripts"
cp "$REAL_HOOK" "$plugin/hooks/"
HOOK="$plugin/hooks/session-branch-guard.sh"
cat > "$plugin/skills/session/scripts/default-branch.sh" <<'EOF'
#!/usr/bin/env bash
echo "$1" >> "${STUB_CALLS:-/dev/null}"
if [[ -n "${STUB_DEFAULT:-}" ]]; then echo "$STUB_DEFAULT"; exit 0; fi
echo "stub: no default branch" >&2
exit 1
EOF
cat > "$plugin/skills/session/scripts/list-sessions.sh" <<'EOF'
#!/usr/bin/env bash
[[ -n "${STUB_SESSIONS:-}" ]] && printf '%s\n' "$STUB_SESSIONS"
exit 0
EOF
export STUB_CALLS="$work/calls"

ACTIVE=$'2026-01-05-widget\tactive\tfeat/5-widget\tfeat/5-widget'

bash_input() {
  local cmd="$1" cwd="$2"
  jq -n --arg c "$cmd" --arg d "$cwd" '{tool_name:"Bash", tool_input:{command:$c}, cwd:$d}'
}

# expect <exit> <command> <cwd> <message>
expect() {
  local code="$1" cmd="$2" cwd="$3" msg="$4"
  run_hook "$HOOK" "$(bash_input "$cmd" "$cwd")"
  assert_eq "$code" "$HOOK_EXIT" "$msg [$cmd]"
}

# new_repo <default-branch-name> : a repo with one commit on that branch.
new_repo() {
  local dir
  dir="$(mktemp -d "$work/repo.XXXX")"
  git init -q -b "$1" "$dir"
  git -C "$dir" config user.email test@example.com
  git -C "$dir" config user.name Test
  echo seed > "$dir/README"
  git_commit_all "$dir" seed
  echo "$dir"
}

repo="$(new_repo main)"
export STUB_DEFAULT=main
export STUB_SESSIONS="$ACTIVE"

# 1. With an active session and main checked out, git commit is blocked and
#    the message names main.
expect 2 'git commit -m x' "$repo" "a session commit on main should be blocked"
assert_hook_stderr_contains '`main` is this repository'"'"'s default branch' "the block should name main"
assert_hook_stderr_contains "REQ-005" "the block should cite REQ-005"
assert_hook_stderr_contains "pull request" "the block should point at the pull request route"

# 2. Pushes to main are blocked.
expect 2 'git push origin HEAD:main' "$repo" "HEAD:main should be blocked"
expect 2 'git push' "$repo" "a bare push on main should be blocked"
expect 2 'git push origin' "$repo" "a push with no refspec on main should be blocked"
expect 2 'git push origin main' "$repo" "an explicit main refspec should be blocked"
expect 2 'git push origin refs/heads/main' "$repo" "refs/heads/main should be blocked"
expect 2 'git push origin feat/x:refs/heads/main' "$repo" "a refs/heads/main destination should be blocked"
expect 2 'git push --force origin +HEAD:main' "$repo" "a forced +HEAD:main should be blocked"
expect 2 'git push origin :main' "$repo" "deleting main should be blocked"
expect 2 'git push origin HEAD' "$repo" "HEAD while main is checked out should be blocked"
expect 2 'git push --all origin' "$repo" "--all should be blocked"
expect 2 'git push --mirror origin' "$repo" "--mirror should be blocked"
expect 2 'git push origin "refs/heads/*:refs/heads/*"' "$repo" "a wildcard destination matching main should be blocked"
expect 2 'git push --repo=origin' "$repo" "--repo with no refspec on main should be blocked"

# 3. On a feature branch, commit and push to that branch are allowed.
git -C "$repo" switch -q -c feat/5-widget
expect 0 'git commit -m x' "$repo" "a commit on feat/5-widget should be allowed"
expect 0 'git push -u origin feat/5-widget' "$repo" "pushing the session branch should be allowed"
expect 0 'git push' "$repo" "a bare push off the default branch should be allowed"
expect 0 'git push origin HEAD' "$repo" "HEAD off the default branch should be allowed"
expect 2 'git push origin HEAD:main' "$repo" "HEAD:main from a feature branch should still be blocked"
expect 2 'git push origin feat/5-widget main' "$repo" "any refspec naming main should be blocked"
git -C "$repo" switch -q main

# 4. Other commands pass at once.
expect 0 'ls' "$repo" "ls should be allowed"
expect 0 'git status' "$repo" "git status should be allowed"
expect 0 'git log --oneline -5' "$repo" "git log should be allowed"
expect 0 'echo "git commit -m x"' "$repo" "git commit inside an echo string should be allowed"
expect 0 'git show HEAD:commit.txt' "$repo" "a non-commit git subcommand mentioning commit should be allowed"
run_hook "$HOOK" "$(jq -n --arg d "$repo" '{tool_name:"Write", tool_input:{file_path:"x", content:"git commit"}, cwd:$d}')"
assert_eq "0" "$HOOK_EXIT" "a non-Bash tool should be allowed"

# 5. Compound commands are split; quotes are respected.
expect 2 'git add -A && git commit -m "msg"' "$repo" "commit after && should be blocked"
expect 2 'git status; git commit -m x' "$repo" "commit after ; should be blocked"
expect 2 'true || git push origin main' "$repo" "push after || should be blocked"
expect 2 'git commit -m x | cat' "$repo" "commit before a pipe should be blocked"
expect 2 'git commit -m x 2>&1' "$repo" "a redirection shouldn't hide the commit"
expect 2 'git push origin 2>/dev/null' "$repo" "a redirection shouldn't read as a refspec"
expect 2 '(git commit -m x)' "$repo" "a subshell commit should be blocked"
expect 2 $'git add .\ngit commit -m x' "$repo" "a commit on a later line should be blocked"
expect 2 $'git commit -m "first line\n\nbody; with semicolon"' "$repo" "a multi-line quoted message should still be blocked"
expect 2 'GIT_AUTHOR_NAME=x git commit -m y' "$repo" "an env assignment prefix should still be blocked"
expect 2 '/usr/bin/git commit -m x' "$repo" "git by full path should be blocked"
expect 2 'git -c user.name=x --no-pager commit -m y' "$repo" "global options before commit should be skipped"
git -C "$repo" switch -q -c feat/5-quoted
expect 0 'git commit -m "a; git push origin main"' "$repo" "a command inside a quoted message should never be read"
expect 0 "git commit -m 'a && git push origin main'" "$repo" "a command inside a single-quoted message should never be read"
git -C "$repo" switch -q main

# 6. git -C and cd are honoured.
other="$(new_repo main)"
git -C "$other" switch -q -c feat/9-other
expect 2 "git -C $repo commit -m x" "$other" "git -C into a repo on main should be blocked"
expect 0 "git -C $other commit -m x" "$repo" "git -C into a repo on a feature branch should be allowed"
expect 2 "cd $repo && git commit -m x" "$other" "cd into a repo on main should be honoured"
expect 0 "cd $other && git commit -m x" "$repo" "cd into a repo on a feature branch should be honoured"
mkdir -p "$repo/sub"
expect 2 "git -C sub commit -m x" "$repo" "a relative git -C should resolve against cwd"

# 7. The default branch comes from default-branch.sh, never assumed: with
#    default trunk and no main, trunk is protected and main is not.
trunk_repo="$(new_repo trunk)"
export STUB_DEFAULT=trunk
: > "$STUB_CALLS"
expect 2 'git commit -m x' "$trunk_repo" "a session commit on trunk should be blocked"
assert_hook_stderr_contains '`trunk` is this repository'"'"'s default branch' "the block should name trunk"
assert_contains "$(cat "$STUB_CALLS")" "$trunk_repo" "the hook should ask default-branch.sh about the repo root"
expect 2 'git push origin HEAD:trunk' "$trunk_repo" "HEAD:trunk should be blocked"
expect 0 'git push origin HEAD:main' "$trunk_repo" "main isn't the default here, so HEAD:main is allowed"
export STUB_DEFAULT=main

# 8. No session (D2): no listed session and nothing staged under
#    docs/sessions/ -> commit on main allowed; staged session paths alone
#    make it a session commit.
export STUB_SESSIONS=""
expect 0 'git commit -m x' "$repo" "with no session, a commit on main should be allowed"
expect 0 'git push origin main' "$repo" "with no session, a push to main should be allowed"
mkdir -p "$repo/docs/sessions/2026-01-09-staged"
echo "x" > "$repo/docs/sessions/2026-01-09-staged/log.md"
git -C "$repo" add docs/sessions
expect 2 'git commit -m x' "$repo" "staged paths under docs/sessions/ should make it a session commit"
git -C "$repo" reset -q
echo "y" > "$repo/notes.txt"
git -C "$repo" add notes.txt
expect 0 'git commit -m x' "$repo" "staged paths outside docs/sessions/ shouldn't make it a session commit"
git -C "$repo" reset -q
export STUB_SESSIONS="$ACTIVE"

# 9. Detached HEAD: a commit isn't on the default branch.
git -C "$repo" switch -q --detach
expect 0 'git commit -m x' "$repo" "a detached-HEAD commit should be allowed"
git -C "$repo" switch -q main

# 10. Fail open, with a warning.
export STUB_DEFAULT=""
expect 0 'git commit -m x' "$repo" "no default branch answer should fail open"
assert_hook_stderr_contains "fail open" "the default-branch fail-open should warn"
export STUB_DEFAULT=main

plain="$work/plain"
mkdir -p "$plain"
expect 0 'git commit -m x' "$plain" "a non-repo cwd should fail open"
assert_hook_stderr_contains "isn't a git repository" "the non-repo fail-open should warn"

bare_plugin="$work/bare-plugin"
mkdir -p "$bare_plugin/hooks"
cp "$REAL_HOOK" "$bare_plugin/hooks/"
run_hook "$bare_plugin/hooks/session-branch-guard.sh" "$(bash_input 'git commit -m x' "$repo")"
assert_eq "0" "$HOOK_EXIT" "missing collaborator scripts should fail open"
assert_hook_stderr_contains "not found" "missing collaborators should warn"

nojq_bin="$work/nojq"
make_path_without_jq "$nojq_bin"
json="$(bash_input 'git commit -m x' "$repo")"
saved_path="$PATH"
PATH="$nojq_bin"
run_hook "$HOOK" "$json"
PATH="$saved_path"
assert_eq "0" "$HOOK_EXIT" "missing jq should fail open"
assert_hook_stderr_contains "jq not found" "missing jq should warn"
PATH="$nojq_bin"
run_hook "$HOOK" "$(PATH="$saved_path" bash_input 'ls -la' "$repo")"
PATH="$saved_path"
assert_eq "" "$HOOK_STDERR" "missing jq shouldn't warn on a command that isn't a commit or push"

# 11. hooks.json registers the hook as PreToolUse on Bash.
matcher="$(jq -r '.hooks.PreToolUse[] | select(any(.hooks[]; .command | test("session-branch-guard.sh"))) | .matcher' "$REPO_ROOT/hooks/hooks.json")"
assert_eq "Bash" "$matcher" "hooks.json should register session-branch-guard.sh as PreToolUse matcher Bash"
cmd="$(jq -r '.hooks.PreToolUse[].hooks[].command | select(test("session-branch-guard.sh"))' "$REPO_ROOT/hooks/hooks.json")"
assert_eq 'bash $CLAUDE_PLUGIN_ROOT/hooks/session-branch-guard.sh' "$cmd" "the hook should run from the plugin root"

echo "ok: session-branch-guard.sh validated"
exit 0
