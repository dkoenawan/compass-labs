#!/usr/bin/env bash
# merge_guard_test.sh
# hooks/merge-guard.sh (ADR-012): blocks gh pr merge, merge API calls and
# pushes to the default branch in every session; allows feature-branch
# pushes (force included); TRELLIS_ALLOW_MERGE=1 opts out; fails open
# without an origin. Runs against throwaway repos with a bare origin.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

HOOK="$REPO_ROOT/hooks/merge-guard.sh"
[[ -f "$HOOK" ]] || fail "hooks/merge-guard.sh not found"
grep -q 'merge-guard.sh' "$REPO_ROOT/hooks/hooks.json" || fail "hooks.json should register merge-guard.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
unset TRELLIS_ALLOW_MERGE

git init -q --bare -b main "$work/origin.git"
repo="$work/repo"
git init -q -b main "$repo"
git -C "$repo" config user.email t@example.com
git -C "$repo" config user.name T
echo seed > "$repo/README"
git -C "$repo" add README && git -C "$repo" commit -qm seed
git -C "$repo" remote add origin "$work/origin.git"
git -C "$repo" push -q origin main
git -C "$repo" remote set-head origin main

expect() {
  local code="$1" cmd="$2" msg="$3"
  run_hook "$HOOK" "$(jq -n --arg c "$cmd" --arg d "$repo" '{tool_name:"Bash", tool_input:{command:$c}, cwd:$d}')"
  assert_eq "$code" "$HOOK_EXIT" "$msg [$cmd]"
}

# 1. gh merges are blocked wherever they appear.
expect 2 'gh pr merge 12 --squash' "gh pr merge should be blocked"
assert_hook_stderr_contains "Only the user merges" "the block should say who merges"
expect 2 'gh pr merge --auto --merge' "gh pr merge --auto should be blocked"
expect 2 'gh -R owner/repo pr merge 3' "gh -R … pr merge should be blocked"
expect 2 'git push -u origin feat/x && gh pr merge 5' "a merge after && should be blocked"
expect 2 'gh api -X PUT repos/o/r/pulls/7/merge' "the REST merge endpoint should be blocked"
expect 2 'gh api repos/{owner}/{repo}/pulls/{number}/merge -X PUT' "a templated merge endpoint should be blocked"
expect 2 'gh api -X POST repos/o/r/merges -f base=main -f head=x' "the merges endpoint should be blocked"
expect 0 'gh pr view 12 --json mergeable' "reading a PR's mergeability should be allowed"
expect 0 'gh pr create --fill' "opening a PR should be allowed"
expect 0 'gh api repos/o/r/pulls/7' "reading a PR through the API should be allowed"
expect 0 'echo "gh pr merge 1"' "a merge inside a quoted string should be allowed"

# 2. Pushes to the default branch are blocked; feature pushes are not.
expect 2 'git push origin main' "pushing main should be blocked"
expect 2 'git push' "a bare push on main should be blocked"
expect 2 'git push --force origin +HEAD:main' "a forced push to main should be blocked"
expect 2 'git push origin :main' "deleting main should be blocked"
expect 2 'git push --all origin' "--all should be blocked"
git -C "$repo" switch -q -c feat/x
expect 0 'git push -u origin feat/x' "pushing a feature branch should be allowed"
expect 0 'git push --force-with-lease origin feat/x' "force-pushing a feature branch should be allowed"
expect 0 'git push' "a bare push on a feature branch should be allowed"
expect 2 'git push origin HEAD:main' "HEAD:main from a feature branch should be blocked"
expect 2 "git -C $repo push origin main" "git -C … push main should be blocked"
expect 0 'git merge main' "a local merge (no push) should be allowed"

# 3. The user's opt-out.
TRELLIS_ALLOW_MERGE=1 run_hook "$HOOK" "$(jq -n --arg d "$repo" '{tool_name:"Bash", tool_input:{command:"gh pr merge 1"}, cwd:$d}')"
assert_eq 0 "$HOOK_EXIT" "TRELLIS_ALLOW_MERGE=1 should allow a merge"

# 4. Fail open without an origin; other tools pass.
lone="$work/lone"; git init -q -b main "$lone"
run_hook "$HOOK" "$(jq -n --arg d "$lone" '{tool_name:"Bash", tool_input:{command:"git push origin main"}, cwd:$d}')"
assert_eq 0 "$HOOK_EXIT" "no origin should fail open"
assert_hook_stderr_contains "fail open" "fail-open should warn"
run_hook "$HOOK" "$(jq -n --arg d "$repo" '{tool_name:"Write", tool_input:{file_path:"x", content:"gh pr merge"}, cwd:$d}')"
assert_eq 0 "$HOOK_EXIT" "a non-Bash tool should be allowed"

echo "ok: merge-guard.sh validated"
