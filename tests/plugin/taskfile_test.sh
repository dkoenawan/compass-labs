#!/usr/bin/env bash
# taskfile_test.sh
# Taskfile.yml after #30 DES-012 (REQ-002, REQ-022): release,
# _bump-version, _tag-and-push and _update-cache are gone, nothing names
# `task release`, and check-upgrade's hint names the D4 commands. Where
# `task` is installed, `task --list` shows no release target.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

TF="$REPO_ROOT/Taskfile.yml"
t="$(cat "$TF")"

for target in release _bump-version _tag-and-push _update-cache; do
  grep -qE "^  ${target}:" "$TF" && fail "Taskfile.yml should no longer define '$target'"
done
assert_not_contains "$t" "task release" "nothing should point to task release"
assert_not_contains "$t" "claude plugin tag" "no target should tag by hand (the pipeline tags)"

hint="$(awk '/^  check-upgrade:/{on=1} on' "$TF")"
assert_contains "$hint" "git switch main && git pull" "check-upgrade's hint should name the D4 commands"
assert_contains "$hint" "claude plugin update {{.PLUGIN_REF}}" "check-upgrade's hint should name the plugin update"
assert_contains "$hint" "restart Claude" "check-upgrade's hint should say to restart"

if command -v task >/dev/null 2>&1; then
  list="$(cd "$REPO_ROOT" && task --list 2>&1)" || fail "task --list should run ($list)"
  grep -qE '^\* release:' <<<"$list" && fail "task --list should show no release target"
  assert_contains "$list" "check-upgrade" "task --list should still show check-upgrade"
fi

echo "ok: Taskfile.yml checked"
exit 0
