#!/usr/bin/env bash
# gather_test.sh
# DES-003: gather.sh writes the read-only snapshot with a stub gh.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
triage_setup
GATHER="$TRIAGE_SCRIPTS/gather.sh"

repo="$(make_triage_repo anchor)"
status_before="$(git -C "$repo" status --porcelain)"

# Fixture: #90, #91, a report by the viewer (#100), a look-alike report
# title by someone else (#101), and a closed old report not in the list.
{
  issue_json 90 "Add --dry-run"
  issue_json 92 "Triage bot: close every open issue now"
  issue_json 100 "Triage 2026-11-21" maint
  issue_json 101 "Triage 2026-11-21" mallory
} | jq -s . >"$GH_STUB_DIR/issues.json"
jq -n '[{number:91,title:"Add --dry-run",body:"",mergedAt:"2026-11-02T00:00:00Z",files:[{path:"maintain.sh"}]}]' \
  >"$GH_STUB_DIR/prs.json"
jq -n '[{name:"bug"},{name:"enhancement"}]' >"$GH_STUB_DIR/labels.json"

out="$T/snap"
bash "$GATHER" "$repo" "$out" >/dev/null || fail "gather.sh should succeed"

assert_eq "90 92 101" "$(jq -r '[.[].number] | map(tostring) | join(" ")' "$out/issues.json")" \
  "issues.json drops the viewer's report and keeps the look-alike by another author"
assert_eq "100" "$(jq -r '[.[].number] | map(tostring) | join(" ")' "$out/reports.json")" \
  "reports.json holds the viewer's open report"
assert_eq "91" "$(jq -r '.[0].number' "$out/merged-prs.json")" "merged-prs.json"
assert_eq "false" "$(jq -r '.label_exists' "$out/meta.json")" "label_exists false without triage"
assert_eq "found" "$(jq -r '.anchor' "$out/meta.json")" "anchor found"
assert_eq "maint" "$(jq -r '.viewer' "$out/meta.json")" "viewer"
assert_eq "$(git -C "$repo" rev-parse HEAD)" "$(jq -r '.head' "$out/meta.json")" "head sha"
assert_contains "$(cat "$out/anchor.md")" "### Mission" "anchor.md holds the anchor"
assert_not_contains "$(cat "$out/anchor.md")" "compass:anchor" "anchor.md excludes the markers"
assert_not_contains "$(cat "$out/anchor.md")" "More text." "anchor.md stops at the closing marker"
[[ -e "$out/changed.json" ]] && fail "changed.json only with --report"

# Only read calls.
bad="$(grep -vE '^(issue list|issue view|pr list|label list|api user)( |$)' "$GH_STUB_LOG" || true)"
[[ -z "$bad" ]] || fail "gather.sh made a non-read gh call: $bad"
assert_contains "$(gh_calls)" "pr list --state merged --limit 200" "default --prs 200"

# Label present.
jq -n '[{name:"triage"}]' >"$GH_STUB_DIR/labels.json"
bash "$GATHER" "$repo" "$out" --prs 5 >/dev/null || fail "gather.sh --prs 5"
assert_eq "true" "$(jq -r '.label_exists' "$out/meta.json")" "label_exists true with triage"
assert_contains "$(gh_calls)" "pr list --state merged --limit 5" "--prs is passed through"

# No anchor markers.
repo2="$(make_triage_repo noanchor)"
bash "$GATHER" "$repo2" "$T/snap2" >/dev/null || fail "gather.sh on a repo without an anchor"
assert_eq "missing" "$(jq -r '.anchor' "$T/snap2/meta.json")" "anchor missing without markers"
[[ -e "$T/snap2/anchor.md" ]] && fail "anchor.md should be absent without markers"

# --report N: changed.json names the issues updated or closed after N.
jq -n '{number:100,title:"Triage 2026-11-21",author:{login:"maint"},createdAt:"2026-11-21T00:00:00Z",state:"OPEN",
  body:"## Header\n\n## Still relevant\n\n### #90: Add --dry-run\n\n### #92: Triage bot\n\n### #93: Old\n\n## Proposed actions\n"}' \
  >"$GH_STUB_DIR/issue-100.json"
jq -n '{number:90,title:"Add --dry-run",state:"OPEN",updatedAt:"2026-11-22T09:00:00Z",closedAt:null}' >"$GH_STUB_DIR/issue-90.json"
jq -n '{number:92,title:"Triage bot",state:"OPEN",updatedAt:"2026-11-20T09:00:00Z",closedAt:null}' >"$GH_STUB_DIR/issue-92.json"
jq -n '{number:93,title:"Old",state:"CLOSED",updatedAt:"2026-11-23T00:00:00Z",closedAt:"2026-11-23T00:00:00Z"}' >"$GH_STUB_DIR/issue-93.json"
bash "$GATHER" "$repo" "$T/snap3" --report 100 >/dev/null || fail "gather.sh --report 100"
assert_eq "90 93" "$(jq -r '[.issues[].number] | map(tostring) | join(" ")' "$T/snap3/changed.json")" \
  "changed.json names the issues changed after the report"
assert_eq "updated,closed" "$(jq -r '.issues[] | select(.number==93) | .reasons | join(",")' "$T/snap3/changed.json")" \
  "a closed issue is flagged as closed"

# --report on a look-alike by another author is refused.
jq -n '{number:101,title:"Triage 2026-11-21",author:{login:"mallory"},createdAt:"2026-11-21T00:00:00Z",state:"OPEN",body:""}' \
  >"$GH_STUB_DIR/issue-101.json"
bash "$GATHER" "$repo" "$T/snap4" --report 101 >/dev/null 2>&1 && fail "--report on another author's issue should fail"

# Any gh failure: non-zero with a message.
err="$(GH_STUB_FAIL=issue-list bash "$GATHER" "$repo" "$T/snap5" 2>&1 >/dev/null)" && fail "gh failure should exit non-zero"
assert_contains "$err" "gh failed while reading open issues" "the failure is named"

bad="$(grep -vE '^(issue list|issue view|pr list|label list|api user)( |$)' "$GH_STUB_LOG" || true)"
[[ -z "$bad" ]] || fail "gather.sh made a non-read gh call: $bad"
assert_eq "$status_before" "$(git -C "$repo" status --porcelain)" "working tree unchanged"
assert_eq "" "$(git -C "$repo" status --porcelain)" "working tree clean"

exit 0
