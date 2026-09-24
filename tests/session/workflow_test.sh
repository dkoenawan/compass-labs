#!/usr/bin/env bash
# workflow_test.sh
# Validates skills/session/workflows/feature.json: it parses as JSON, has
# the 6 Feature phases in order, and every non-close phase's artifact
# exists as a template in skills/session/templates/.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

WORKFLOW="$REPO_ROOT/skills/session/workflows/feature.json"
TEMPLATES_DIR="$REPO_ROOT/skills/session/templates"

[[ -f "$WORKFLOW" ]] || fail "workflow file not found: $WORKFLOW"

# 1. It parses as JSON.
jq empty "$WORKFLOW" >/dev/null 2>&1 || fail "feature.json is not valid JSON"

# 2. It has exactly 6 phases, in the expected order.
expected_phases=(define design implement test deploy close)
actual_phases_str="$(jq -r '.phases[].phase' "$WORKFLOW")"
mapfile -t actual_phases <<<"$actual_phases_str"

assert_eq "${#expected_phases[@]}" "${#actual_phases[@]}" "expected 6 phases"

for i in "${!expected_phases[@]}"; do
  assert_eq "${expected_phases[$i]}" "${actual_phases[$i]}" "phase order mismatch at index $i"
done

# Also check the `order` field matches position (1-based).
for i in "${!expected_phases[@]}"; do
  phase="${expected_phases[$i]}"
  order="$(jq -r --arg p "$phase" '.phases[] | select(.phase == $p) | .order' "$WORKFLOW")"
  assert_eq "$((i + 1))" "$order" "order field mismatch for phase $phase"
done

# 3. Every non-close phase's artifact exists as a template.
while IFS=$'\t' read -r phase artifact; do
  if [[ "$phase" == "close" ]]; then
    assert_eq "null" "$artifact" "close phase should have a null artifact"
    continue
  fi
  [[ "$artifact" != "null" && -n "$artifact" ]] || fail "phase $phase has no artifact filename"
  template_path="$TEMPLATES_DIR/$artifact"
  [[ -f "$template_path" ]] || fail "template missing for phase $phase: $template_path"
done < <(jq -r '.phases[] | [.phase, (.artifact // "null")] | @tsv' "$WORKFLOW")

# 4. Session-level file allowlist includes the five artifacts + log.md + assets/.
allowlist_str="$(jq -r '.session_level.file_allowlist[]' "$WORKFLOW")"
for entry in requirements.md design.md tasks.md verification.md release.md log.md "assets/"; do
  assert_contains "$allowlist_str" "$entry" "file_allowlist missing $entry"
done

echo "ok: feature.json validated (6 phases, ordered, artifacts present, allowlist complete)"
exit 0
