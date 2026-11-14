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

exit 0
