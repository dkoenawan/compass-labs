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
  if [[ "$artifact" == */ ]]; then
    # A folder artifact (#23 DES-020): templates/<dir>/ is a directory
    # holding a template for every file in its fixed artifact_files set.
    [[ -d "$template_path" ]] || fail "template folder missing for phase $phase: $template_path"
    mapfile -t files < <(jq -r --arg p "$phase" '.phases[] | select(.phase == $p) | .artifact_files[]?' "$WORKFLOW")
    [[ ${#files[@]} -gt 0 ]] || fail "folder artifact $artifact for phase $phase has no artifact_files"
    for f in "${files[@]}"; do
      [[ -f "$template_path$f" ]] || fail "template missing for $phase's $artifact$f: $template_path$f"
    done
  else
    [[ -f "$template_path" ]] || fail "template missing for phase $phase: $template_path"
  fi
done < <(jq -r '.phases[] | [.phase, (.artifact // "null")] | @tsv' "$WORKFLOW")

# 4. Session-level file allowlist includes the five artifacts (define/ plus
#    the legacy root requirements.md, D6) + log.md + assets/.
allowlist_str="$(jq -r '.session_level.file_allowlist[]' "$WORKFLOW")"
for entry in "define/" requirements.md design.md tasks.md verification.md release.md log.md "assets/"; do
  grep -qxF "$entry" <<<"$allowlist_str" || fail "file_allowlist missing $entry"
done
assert_eq "requirements.md" "$(jq -r '.phases[] | select(.phase == "define") | .legacy_artifact' "$WORKFLOW")" \
  "define's legacy_artifact should be the root requirements.md"
assert_eq "define/" "$(jq -r '.framing.produces' "$WORKFLOW")" \
  "framing.produces should be the define phase's artifact"

echo "ok: feature.json validated (6 phases, ordered, artifacts present, allowlist complete)"
exit 0
