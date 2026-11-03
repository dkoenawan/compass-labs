#!/usr/bin/env bash
# deploy_offer_test.sh
# Content assertions for the declaration offer (#30 DES-014, REQ-026,
# REQ-028): one procedure in the Deploy standard with the skip rule, three
# answers and the starter offer after "declare now"; the starter mode;
# both init modes call it before their commit, and the session skill's
# one-time setup calls it as step 3, only in its first run. Running the
# offers on a fixture is Test's.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

STD="$REPO_ROOT/skills/deploy/SKILL.md"
INIT="$REPO_ROOT/skills/init/SKILL.md"
SESSION="$REPO_ROOT/skills/session/SKILL.md"

offer="$(awk '/^## 8. Declaration offer/{on=1; next} /^## 9\./{on=0} on' "$STD")"
[[ -n "$offer" ]] || fail "the standard should have a '## 8. Declaration offer' section"
assert_contains "$offer" "If \`.claude/deploy.json\` exists, make no offer of either kind" "the procedure should have the skip rule"
for answer in '**later:** write nothing' '**nothing to deploy:** write `.claude/deploy.json` as `{"deployment": "none"}`' '**declare now:**'; do
  assert_contains "$offer" "$answer" "the procedure should offer '$answer'"
done
assert_contains "$offer" "check-declaration.sh {repo}" "declare now should validate the result"
assert_contains "$offer" "After \"declare now\" only, if \`git remote get-url origin\` is a GitHub URL" "the starter should follow declare now, on GitHub only"
assert_contains "$offer" "Only on a yes, run \`bash \${CLAUDE_PLUGIN_ROOT}/skills/deploy/scripts/install-starter.sh {repo}\`" "the starter should be installed only on a yes"
assert_contains "$offer" "never runs an L1 setup step" "initiation should run no setup step"
assert_contains "$offer" "merge-triggered pipeline" "a yes should add the pipeline part to l1.parts"

mode="$(awk '/^## 9. Starter mode/{on=1; next} /^## /{on=0} on' "$STD")"
assert_contains "$mode" "/compass-labs:deploy starter" "the starter mode should be invocable"
assert_contains "$mode" "never runs a setup or release step" "the starter mode should run no deploy step"
assert_contains "$(grep -m1 '^argument-hint:' "$STD")" "starter" "the standard should take 'starter' as an argument"

# init: both modes call the procedure just before their commit step.
for pair in "Step 6b|Step 7: Commit registry files" "Step 8b|Step 9: Commit"; do
  offer_step="${pair%%|*}" commit_step="${pair#*|}"
  o="$(grep -n "^### $offer_step: Offer a deploy declaration" "$INIT" | cut -d: -f1)"
  c="$(grep -n "^### $commit_step" "$INIT" | cut -d: -f1)"
  [[ -n "$o" && -n "$c" && "$o" -lt "$c" ]] || fail "init should offer a declaration ($offer_step) just before '$commit_step'"
done
[[ "$(grep -c 'skills/deploy/SKILL.md` (section 8)' "$INIT")" -eq 2 ]] || fail "both init modes should follow the Deploy standard's procedure"

# session one-time setup: step 3, first run only.
setup="$(awk '/^## One-time setup/{on=1; next} /^## /{on=0} on' "$SESSION")"
assert_contains "$setup" "3. **Offer a deploy declaration**, only in the same run that copies the commit-point rule" \
  "one-time setup should offer the declaration in its first run only"
assert_contains "$setup" 'skills/deploy/SKILL.md` (section 8)' "one-time setup should follow the Deploy standard's procedure"

echo "ok: declaration offer checked"
exit 0
