#!/usr/bin/env bash
# docs_test.sh
# DES-009: README documents compass-labs:triage and every mode, the install
# example, the scheduled run's limits, the run log and uninstall; the
# marketplace lists ./skills/triage in alphabetical order; the anchor keeps
# the Scope line written at Define.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

readme="$(cat "$REPO_ROOT/README.md")"
assert_contains "$readme" "#### \`/compass-labs:triage\`" "README section for the skill"
assert_contains "$readme" "│   ├── triage/" "README plugin structure lists skills/triage"
for mode in "/compass-labs:triage  " "/compass-labs:triage apply  " "/compass-labs:triage apply #N" \
            "/compass-labs:triage install --day sat --time 01:00 --tz Pacific/Auckland" "/compass-labs:triage uninstall"; do
  assert_contains "$readme" "$mode" "README names the mode: $mode"
done
assert_contains "$readme" "**What a scheduled run may do:**" "what a scheduled run may do"
assert_contains "$readme" "**What it may not do:**" "what it may not do"
assert_contains "$readme" '${XDG_STATE_HOME:-$HOME/.local/state}/compass-labs/triage/' "where the run log is"
assert_contains "$readme" "uninstall-schedule.sh /path/to/repo" "how to uninstall"

# The anchor's Scope line from Define is intact, and the anchor appears once.
anchor="$(awk '/^<!-- \/compass:anchor -->$/ {exit} on {print} /^<!-- compass:anchor -->$/ {on=1}' "$REPO_ROOT/README.md")"
assert_contains "$anchor" "- Supporting skills: scaffolding, planning, codebase exploration, documentation, architecture decisions, task execution, backlog triage, brand design." "anchor Scope line"
assert_eq "1" "$(grep -c '^<!-- compass:anchor -->$' "$REPO_ROOT/README.md")" "one anchor"
assert_not_contains "$anchor" "compass-labs:triage" "the triage docs sit outside the anchor"

# Marketplace: listed, in alphabetical order.
listed="$(jq -r '.plugins[] | select(.name=="compass-labs") | .skills[]' "$REPO_ROOT/.claude-plugin/marketplace.json")"
assert_contains "$listed" "./skills/triage" "marketplace lists ./skills/triage"
assert_eq "$(sort <<<"$listed")" "$listed" "marketplace skills stay in alphabetical order"

# #93 (DES-005): #91 and #93 are no longer open limitations or open work,
# and the overview tells an older schedule to uninstall, then reinstall.
overview="$(cat "$REPO_ROOT/docs/explanation/triage/overview.md")"
reference="$(cat "$REPO_ROOT/docs/reference/triage/stock-take-and-schedule.md")"
schedule_doc="$(cat "$REPO_ROOT/docs/reference/constructs/TriageSchedule.md")"
open_work="$(grep -F -- '- **Open work**' <<<"$overview")"
assert_contains "$open_work" "#88" "the overview still has its Open work line"
for n in 91 93; do
  assert_not_contains "$open_work" "#$n" "overview Open work no longer lists #$n"
  assert_eq "" "$(grep -E "^\| #$n \|" <<<"$reference")" "reference Open work has no #$n row"
  assert_not_contains "$(sed -n '/^## Gotchas/,/^## /p' <<<"$overview")" "(#$n)" "no overview gotcha cites #$n as open"
done
assert_not_contains "$overview" "Until #93 is fixed" "the #93 workaround gotcha is gone"
assert_not_contains "$overview" "run date is the model's own" "the #91 gotcha is gone"
assert_not_contains "$schedule_doc" "resolved with \`realpath\`" "TriageSchedule no longer records realpath as its decision"
assert_contains "$overview" 'run `uninstall-schedule.sh <repo>`, then `install-schedule.sh <repo>' "the overview says uninstall, then install, for an older schedule"
assert_contains "$reference" "not symlink-resolved" "the reference says the paths keep their symlinks"

exit 0
