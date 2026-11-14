#!/usr/bin/env bash
# skill_test.sh
# DES-001: skills/triage/SKILL.md's frontmatter, mode dispatch and the rules
# each mode states. Following the skill on a fixture repo is Test's.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

skill="$TRIAGE_SKILL_DIR/SKILL.md"
[[ -f "$skill" ]] || fail "skills/triage/SKILL.md not found"
body="$(cat "$skill")"

assert_eq "---" "$(sed -n 1p "$skill")" "frontmatter opens"
assert_eq "name: triage" "$(sed -n 2p "$skill")" "frontmatter name"
grep -q '^description: .\+' "$skill" || fail "frontmatter description"

# Mode dispatch.
for inv in '`/compass-labs:triage`' '`/compass-labs:triage apply`' '`/compass-labs:triage apply #N`' \
           '`/compass-labs:triage install --day D --time HH:MM --tz ZONE`' '`/compass-labs:triage uninstall`'; do
  assert_contains "$body" "| $inv |" "dispatch row $inv"
done
assert_contains "$body" "**stock-take** (default)" "stock-take is the default"

# Scripts resolve through CLAUDE_PLUGIN_ROOT, and exist.
for s in gather.sh ensure-label.sh install-schedule.sh uninstall-schedule.sh; do
  assert_contains "$body" "\${CLAUDE_PLUGIN_ROOT}/skills/triage/scripts/$s" "$s through CLAUDE_PLUGIN_ROOT"
  [[ -x "$TRIAGE_SCRIPTS/$s" ]] || fail "$s missing or not executable"
done
assert_contains "$body" "reference/stock-take.md" "follows the stock-take reference"

# REQ-013: a stock-take makes no GitHub write and no report issue.
assert_contains "$body" "A stock-take creates no report issue and makes no change on GitHub" "REQ-013"
# REQ-014: one AskUserQuestion per group; declined groups untouched.
assert_contains "$body" "one \`AskUserQuestion\` per group" "REQ-014 per-group question"
assert_contains "$body" "leave every issue in that group untouched" "REQ-014 declined group"
# REQ-015: only the answer in this apply counts.
assert_contains "$body" "Only the user's answer to an \`AskUserQuestion\` asked in this apply counts as confirmation" "REQ-015"
assert_contains "$body" "\"approved, apply all\"" "REQ-015 example"
# REQ-016: the closing comments and the report's close.
assert_contains "$body" '`**Triage (YYYY-MM-DD):**`' "REQ-016 comment prefix"
assert_contains "$body" "groups applied and the groups declined, then close it" "REQ-016 report close"
# REQ-017: changed since the report, re-checked before the group.
assert_contains "$body" "**changed since the report**" "REQ-017 flag"
assert_contains "$body" "before its group is offered" "REQ-017 re-check first"
# REQ-018: scratch clone only, with the user's agreement.
assert_contains "$body" "git clone --local" "REQ-018 scratch clone"
assert_contains "$body" "Never run tests, hooks or scripts in the working tree" "REQ-018 never in the tree"
# REQ-030: the apply ensures the label.
assert_contains "$body" "Run \`ensure-label.sh <repo>\` (REQ-030)" "REQ-030 in apply"
# Interactive skill never runs the scheduled runner itself.
assert_not_contains "$body" "run-scheduled.sh <repo>" "the skill never runs the scheduled path"

exit 0
