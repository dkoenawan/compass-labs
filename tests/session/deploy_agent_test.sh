#!/usr/bin/env bash
# deploy_agent_test.sh
# Content assertions for the Deploy agent, agents/deploy.md (#30 DES-004):
# it preloads the Deploy standard, validates with check-declaration.sh
# before anything else, keeps the completeness check, makes the REQ-027
# offer as its only needs_input, never merges, and the old TODO,
# `task release` and "own session" text are gone. Running the agent on
# the fixtures is Test's (handed to Test).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

AGENT="$REPO_ROOT/agents/deploy.md"
[[ -f "$AGENT" ]] || fail "agents/deploy.md not found"
a="$(cat "$AGENT")"

assert_contains "$a" $'skills:\n  - compass-labs:deploy\n' "the agent should preload compass-labs:deploy"
assert_contains "$a" 'skills/deploy/scripts/check-declaration.sh' "the agent should validate with check-declaration.sh"
assert_contains "$a" "Never ship an incomplete product" "the agent should keep the completeness check"
assert_contains "$a" "Deploy clause" "the agent should point to its contract clause"
assert_contains "$a" "\`needs_input\`" "the agent should make the REQ-027 offer"
assert_contains "$a" "only question you ever ask" "the offer should be the only question"
assert_contains "$a" "never merge" "the agent should never merge"
assert_contains "$a" "waiting for the user's instruction" "production-affecting steps should wait"
assert_contains "$a" "added to the declaration at this Deploy" "an added entry should be recorded"
assert_contains "$a" "release: waits for a release session" "own_session should wait for a release session"
assert_contains "$a" "nothing to deploy, per the declaration" "none should be recorded"

# Validation comes before completeness, completeness before L1, L1 before L2.
pos() { grep -n "$1" "$AGENT" | head -1 | cut -d: -f1; }
v="$(pos 'Validate the declaration')" c="$(pos 'Never ship an incomplete product')"
l1="$(pos 'Run L1')" l2="$(pos 'Run L2')"
[[ "$v" -lt "$c" && "$c" -lt "$l1" && "$l1" -lt "$l2" ]] || fail "the steps should run validate, completeness, L1, then L2"

assert_not_contains "$a" "TODO (#30)" "the TODO should be gone"
assert_not_contains "$a" "task release" "the task release text should be gone"
assert_not_contains "$a" "own session" "the 'own session' text should be gone"

echo "ok: Deploy agent checked"
exit 0
