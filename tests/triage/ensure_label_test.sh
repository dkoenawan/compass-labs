#!/usr/bin/env bash
# ensure_label_test.sh
# DES-007: ensure-label.sh creates `triage` only when it's missing, and no
# scheduled-run script calls it.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
triage_setup
ENSURE="$TRIAGE_SCRIPTS/ensure-label.sh"
repo="$(make_triage_repo)"

# No label: exactly one create.
jq -n '[{name:"bug"}]' >"$GH_STUB_DIR/labels.json"
bash "$ENSURE" "$repo" >/dev/null || fail "should succeed when the label is missing"
assert_eq "1" "$(grep -c '^label create' "$GH_STUB_LOG")" "exactly one label create"
assert_contains "$(gh_calls)" 'label create triage --description Triage report' "create call"

# Existing label: no create.
: >"$GH_STUB_LOG"
jq -n '[{name:"triage"}]' >"$GH_STUB_DIR/labels.json"
bash "$ENSURE" "$repo" >/dev/null || fail "should succeed when the label exists"
assert_eq "0" "$(grep -c '^label create' "$GH_STUB_LOG")" "no create when the label exists"

# Failures: non-zero with the reason.
jq -n '[]' >"$GH_STUB_DIR/labels.json"
err="$(GH_STUB_FAIL=label-create bash "$ENSURE" "$repo" 2>&1)" && fail "a failed create should exit non-zero"
assert_contains "$err" "could not create the 'triage' label" "create failure reason"
err="$(GH_STUB_FAIL=label-list bash "$ENSURE" "$repo" 2>&1)" && fail "a failed list should exit non-zero"
assert_contains "$err" "could not list labels" "list failure reason"

# The scheduled path never calls it (or creates a label).
for f in run-scheduled.sh publish-report.sh; do
  [[ -f "$TRIAGE_SCRIPTS/$f" ]] || continue
  code="$(grep -vE '^[[:space:]]*#' "$TRIAGE_SCRIPTS/$f")"  # comments may name it
  grep -q 'ensure-label' <<<"$code" && fail "$f must not call ensure-label.sh"
  grep -qE 'label[[:space:]]+create' <<<"$code" && fail "$f must not create a label"
done

exit 0
