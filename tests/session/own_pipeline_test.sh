#!/usr/bin/env bash
# own_pipeline_test.sh
# compass-labs' own merge-triggered pipeline (#30 DES-016, D12): the
# committed .github/workflows/release.yml and .github/scripts/release-tag.sh
# are exactly what a fresh install-starter.sh run writes from this repo's
# .claude/deploy.json, into a temp copy with a GitHub origin. So they were
# installed from the starter and not edited by hand. Their runs on PR #77
# and after the merge are Test's and Deploy's.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

INSTALL="$REPO_ROOT/skills/deploy/scripts/install-starter.sh"
for f in .github/workflows/release.yml .github/scripts/release-tag.sh .claude/deploy.json; do
  [[ -f "$REPO_ROOT/$f" ]] || fail "$f not found"
done
[[ -x "$REPO_ROOT/.github/scripts/release-tag.sh" ]] || fail ".github/scripts/release-tag.sh should be executable"

copy="$(make_temp_git_repo)"
trap 'rm -rf "$copy"' EXIT
mkdir -p "$copy/.claude" "$copy/.claude-plugin"
cp "$REPO_ROOT/.claude/deploy.json" "$copy/.claude/deploy.json"
cp "$REPO_ROOT/.claude-plugin/plugin.json" "$copy/.claude-plugin/plugin.json"
git -C "$copy" remote add origin https://github.com/dkoenawan/compass-labs.git

out="$(bash "$INSTALL" "$copy" 2>&1)"
assert_eq 0 $? "a fresh install-starter.sh run should succeed ($out)"
for f in .github/workflows/release.yml .github/scripts/release-tag.sh; do
  cmp -s "$REPO_ROOT/$f" "$copy/$f" || fail "$f should match a fresh install-starter.sh run byte for byte"
done

echo "ok: compass-labs' pipeline matches the starter"
exit 0
