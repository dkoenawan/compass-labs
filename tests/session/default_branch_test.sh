#!/usr/bin/env bash
# default_branch_test.sh
# Component tests for skills/session/scripts/default-branch.sh (#37
# DES-001, REQ-006): the script runs for real against throwaway repos whose
# "remote" is a local bare repository, so no network is touched. It must
# read the default branch from the repository and never assume `main`.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/session/scripts/default-branch.sh"
[[ -x "$SCRIPT" ]] || fail "default-branch.sh not found or not executable"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

git_q() { git -c user.email=test@example.com -c user.name=Test "$@"; }

# run_script <repo> : sets OUT, ERR, CODE.
run_script() {
  set +e
  OUT="$(bash "$SCRIPT" "$1" 2>"$work/err")"
  CODE=$?
  set -e 2>/dev/null || true
  ERR="$(cat "$work/err")"
}

# A bare remote whose HEAD is `trunk`, with no `main` anywhere.
git init -q --bare -b trunk "$work/remote.git"
git init -q -b trunk "$work/seed"
echo seed > "$work/seed/README"
git_q -C "$work/seed" add README
git_q -C "$work/seed" commit -q -m seed
git -C "$work/seed" remote add origin "$work/remote.git"
git -C "$work/seed" push -q origin trunk 2>/dev/null

git clone -q "$work/remote.git" "$work/clone" 2>/dev/null
[[ -z "$(git -C "$work/clone" branch -a --list '*main*')" ]] || fail "fixture should have no main branch"

# 1. origin/HEAD set by the clone -> trunk.
run_script "$work/clone"
assert_eq "0" "$CODE" "should exit 0 with origin/HEAD set"
assert_eq "trunk" "$OUT" "should print trunk from origin/HEAD"

# 2. origin/HEAD removed -> falls back to ls-remote, still trunk.
git -C "$work/clone" remote set-head origin -d
git -C "$work/clone" symbolic-ref --quiet refs/remotes/origin/HEAD >/dev/null 2>&1 \
  && fail "fixture: origin/HEAD should be gone"
run_script "$work/clone"
assert_eq "0" "$CODE" "should exit 0 via the ls-remote fallback"
assert_eq "trunk" "$OUT" "should print trunk from ls-remote --symref"

# 3. Works from a subdirectory path too, and with no argument from cwd.
mkdir -p "$work/clone/sub/dir"
run_script "$work/clone/sub/dir"
assert_eq "trunk" "$OUT" "should resolve the repo from a subdirectory"
OUT="$(cd "$work/clone" && bash "$SCRIPT" 2>/dev/null)"
assert_eq "trunk" "$OUT" "no argument should mean the current directory"

# 4. Remote HEAD that isn't main or trunk: never assumes a name.
git init -q --bare -b develop "$work/remote2.git"
git -C "$work/seed" branch -q -m trunk develop
git -C "$work/seed" remote add r2 "$work/remote2.git"
git -C "$work/seed" push -q r2 develop 2>/dev/null
git clone -q "$work/remote2.git" "$work/clone2" 2>/dev/null
run_script "$work/clone2"
assert_eq "develop" "$OUT" "should print the remote's actual default branch"

# 5. No remote at all -> exit 1 with a reason.
git init -q -b main "$work/noremote"
run_script "$work/noremote"
assert_eq "1" "$CODE" "no origin remote should exit 1"
assert_eq "" "$OUT" "no origin remote should print nothing on stdout"
assert_contains "$ERR" "no 'origin' remote" "the reason should name the missing remote"

# 6. origin points nowhere and origin/HEAD is unset -> exit 1.
git init -q -b main "$work/deadremote"
git -C "$work/deadremote" remote add origin "$work/does-not-exist.git"
run_script "$work/deadremote"
assert_eq "1" "$CODE" "an unreachable origin with no origin/HEAD should exit 1"
assert_contains "$ERR" "neither origin/HEAD nor" "the reason should say neither source answered"

# 7. Not a git repository -> exit 1.
mkdir -p "$work/plain"
run_script "$work/plain"
assert_eq "1" "$CODE" "a non-repo should exit 1"
assert_contains "$ERR" "not a git repository" "the reason should say it isn't a repo"

echo "ok: default-branch.sh validated"
exit 0
