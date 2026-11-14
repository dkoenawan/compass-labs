#!/usr/bin/env bash
# deploy_gate_test.sh
# Content assertions for the Deploy gate and relay in
# skills/session/SKILL.md (#30 DES-007, REQ-015, REQ-025, REQ-027): the
# tier is confirmed or changed before the checks, a change is relayed to
# the Deploy agent to rewrite the record, a2 stays, check-release.sh runs
# after it and exit 1 refuses the milestone, the script is in the scripts
# table, and Deploy's one needs_input is relayed with its decision entry
# and declaration change committed together. Running the gate is Test's.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SKILL="$REPO_ROOT/skills/session/SKILL.md"
s="$(cat "$SKILL")"

assert_contains "$s" "a1. **Deploy milestone only, the tier** (REQ-025)" "the gate should confirm the tier"
assert_contains "$s" "confirm it or change it to skip, short or full" "the user should confirm or change the tier"
assert_contains "$s" "relay it to the Deploy agent to rewrite the record" "a tier change should be relayed to Deploy"
assert_contains "$s" "a2. **Deploy milestone only** (never ship an incomplete product)" "a2 should stay"
assert_contains "$s" 'skills/session/scripts/check-release.sh {session-dir}' "the gate should run check-release.sh"
assert_contains "$s" "\`milestone\` stays at \`test\`" "a refused Deploy milestone should leave milestone at test"
assert_contains "$s" "| \`check-release.sh\` |" "check-release.sh should be in the scripts table"
assert_contains "$s" "Deploy's one question (REQ-027)" "the Deploy offer should be relayed"
assert_contains "$s" "commit that entry and the \`.claude/deploy.json\` change together" "the offer's yes should be committed with its decision"

# Order: tier confirmation, then a2, then check-release.
pos() { grep -n -F "$1" "$SKILL" | head -1 | cut -d: -f1; }
a1="$(pos 'a1. **Deploy milestone only, the tier**')" a2="$(pos 'a2. **Deploy milestone only**')" a2b="$(pos 'a2b. **Deploy milestone only, the sections**')"
[[ -n "$a1" && -n "$a2" && -n "$a2b" && "$a1" -lt "$a2" && "$a2" -lt "$a2b" ]] \
  || fail "the Deploy gate should confirm the tier, then run a2, then check-release.sh"

echo "ok: Deploy gate and relay checked"
exit 0
