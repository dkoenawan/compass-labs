#!/usr/bin/env bash
# gh_setup_test.sh
# Exercises skills/session/scripts/gh-setup.sh against a stub `gh` on
# PATH. No real GitHub calls.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/session/scripts/gh-setup.sh"

bin_dir="$(mktemp -d)"
log_file="$(mktemp)"
trap 'rm -rf "$bin_dir" "$log_file"' EXIT

install_stub_gh "$bin_dir"

export PATH="$bin_dir:$PATH"
export GH_STUB_LOG="$log_file"
export CLAUDE_PLUGIN_ROOT="$REPO_ROOT"

# 1. Runs cleanly against the real feature.json and creates every label.
out="$(bash "$SCRIPT" --type feature 2>&1)"
status=$?
assert_eq "0" "$status" "gh-setup.sh should exit 0 on success"
assert_contains "$out" "type:feature" "should create the type label"
assert_contains "$out" "phase:define" "should create phase:define"
assert_contains "$out" "phase:close" "should create phase:close"
assert_not_contains "$out" "SYNC_PENDING" "no gh failures expected"

label_calls="$(grep -c '^label create' "$log_file" || true)"
# type:feature + 6 phase labels = 7 `gh label create` calls.
assert_eq "7" "$label_calls" "expected 7 label create calls"

# 2. --repo is forwarded to every label create call.
: > "$log_file"
bash "$SCRIPT" --type feature --repo acme/widgets >/dev/null 2>&1
repo_calls="$(grep -c -- '--repo acme/widgets' "$log_file" || true)"
assert_eq "7" "$repo_calls" "every label create call should carry --repo acme/widgets"

# 3. gh failures are reported as SYNC_PENDING, script still exits 0.
: > "$log_file"
export GH_STUB_FAIL=label
out="$(bash "$SCRIPT" --type feature 2>&1)"
status=$?
unset GH_STUB_FAIL
assert_eq "0" "$status" "gh-setup.sh should still exit 0 when gh fails (fail-open sync)"
assert_contains "$out" "SYNC_PENDING" "a gh failure should be reported as SYNC_PENDING"

# 4. Unreadable/missing workflow file exits non-zero (a real config error,
#    not a soft gh failure — this is a script misuse, not gh being down).
: > "$log_file"
bash "$SCRIPT" --type does-not-exist >/dev/null 2>&1
status=$?
if [[ $status -eq 0 ]]; then
  fail "gh-setup.sh should fail when the workflow file for --type does not exist"
fi

echo "ok: gh-setup.sh validated"
exit 0
