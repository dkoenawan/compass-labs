#!/usr/bin/env bash
# bump_version_test.sh
# Component test for .github/scripts/bump-version.sh (#30 DES-010,
# REQ-005), run on a copy in a temp tree so the real plugin.json is never
# touched: 2.2.1 with minor gives 2.3.0 and only the version changes; patch
# and major step correctly; a bad level exits 1 and changes nothing; the
# script makes no commit.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/.github/scripts/bump-version.sh"
[[ -x "$SCRIPT" ]] || fail ".github/scripts/bump-version.sh not found or not executable"

tree="$(make_temp_git_repo)"
trap 'rm -rf "$tree"' EXIT
mkdir -p "$tree/.github/scripts" "$tree/.claude-plugin"
cp "$SCRIPT" "$tree/.github/scripts/bump-version.sh"
cp "$REPO_ROOT/.claude-plugin/plugin.json" "$tree/.claude-plugin/plugin.json"
pj="$tree/.claude-plugin/plugin.json"
jq '.version = "2.2.1"' "$pj" >"$pj.tmp" && mv "$pj.tmp" "$pj"
git_commit_all "$tree" "fixture"
before="$(cat "$pj")"

# minor: 2.2.1 -> 2.3.0, printed, only the version line differs, no commit.
out="$(bash "$tree/.github/scripts/bump-version.sh" minor 2>&1)"
assert_eq 0 $? "minor should succeed"
assert_eq "2.3.0" "$out" "minor on 2.2.1 should print 2.3.0"
assert_eq "2.3.0" "$(jq -r .version "$pj")" "plugin.json should read 2.3.0"
assert_eq "$(sed 's/"2.2.1"/"2.3.0"/' <<<"$before")" "$(cat "$pj")" "only the version should change"
assert_eq 1 "$(git -C "$tree" rev-list --count HEAD)" "bump-version.sh should not commit"

# patch and major.
assert_eq "2.3.1" "$(bash "$tree/.github/scripts/bump-version.sh" patch)" "patch on 2.3.0 should give 2.3.1"
assert_eq "3.0.0" "$(bash "$tree/.github/scripts/bump-version.sh" major)" "major on 2.3.1 should give 3.0.0"

# A bad level, and no level: exit 1, nothing changes.
snapshot="$(cat "$pj")"
for bad in huge ""; do
  out="$(bash "$tree/.github/scripts/bump-version.sh" $bad 2>&1)"
  status=$?
  assert_eq 1 "$status" "level '$bad' should exit 1"
  assert_contains "$out" "patch, minor or major" "the error should name the allowed levels"
  assert_eq "$snapshot" "$(cat "$pj")" "level '$bad' should change nothing"
done

echo "ok: bump-version.sh checked"
exit 0
