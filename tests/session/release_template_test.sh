#!/usr/bin/env bash
# release_template_test.sh
# The release template, skills/session/templates/release.md (#30 DES-003,
# REQ-002, REQ-014, REQ-023, REQ-025): a Deploy tier line, and its H2
# headings are exactly the seven sections of the Deploy standard's tier
# table, in the same order. The steps section names the declaration as
# its source and has places for waiting steps and the user's steps after
# the merge; the lifecycles section has a place for an entry added at this
# Deploy (REQ-027). check-release.sh's list is compared in
# check_release_test.sh (DES-006).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

TEMPLATE="$REPO_ROOT/skills/session/templates/release.md"
STD="$REPO_ROOT/skills/deploy/SKILL.md"
[[ -f "$TEMPLATE" ]] || fail "release.md template not found"
t="$(cat "$TEMPLATE")"

grep -qE '^> Deploy tier: \{skip \| short \| full\}: ' "$TEMPLATE" || fail "the template should have a 'Deploy tier: {tier}: {reason}' line"

# The standard's tier-table section rows, in order.
std_sections="$(awk '/^\| Section \| skip \| short \| full \|/{on=1; next} on && /^\|---/{next} on && /^\| /{split($0,a,"|"); gsub(/^ +| +$/,"",a[2]); print a[2]; next} on{exit}' "$STD")"
[[ "$(wc -l <<<"$std_sections")" -eq 7 ]] || fail "the standard's tier table should have seven section rows (got: $std_sections)"
template_sections="$(grep -E '^## ' "$TEMPLATE" | sed 's/^## //')"
assert_eq "$std_sections" "$template_sections" "the template's H2 headings should be the tier table's sections, in order"

# The steps section names the declaration and has the two places.
steps="$(awk '/^## Steps run/{on=1; next} /^## /{on=0} on' "$TEMPLATE")"
assert_contains "$steps" "Source: the deploy declaration, \`.claude/deploy.json\`" "the steps section should name the declaration as its source"
assert_contains "$steps" "Waiting for the user's instruction" "the steps section should have a place for waiting steps"
assert_contains "$steps" "The user's steps after the merge" "the steps section should have a place for the user's steps"
lifecycles="$(awk '/^## Lifecycles run and why/{on=1; next} /^## /{on=0} on' "$TEMPLATE")"
assert_contains "$lifecycles" "Added to the declaration at this Deploy (REQ-027)" "the lifecycles section should have a place for an added entry"

echo "ok: release template checked"
exit 0
