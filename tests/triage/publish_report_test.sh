#!/usr/bin/env bash
# publish_report_test.sh
# DES-004: publish-report.sh validates, then creates one report issue and
# closes the superseded one, with a stub gh. Also checks that the example
# report in stock-take.md (DES-002) passes the validator, so the headings
# the procedure fixes are the exact strings this script checks.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
triage_setup
PUBLISH="$TRIAGE_SCRIPTS/publish-report.sh"
repo="$(make_triage_repo)"
snap="$T/snap"
mkdir -p "$snap"

{ issue_json 90 "Add --dry-run"; issue_json 50 "Dark mode"; issue_json 51 "Dark mode too"; } | jq -s . >"$snap/issues.json"
jq -n '[{number:80,title:"Triage 2026-11-14",author:{login:"maint"}}]' >"$snap/reports.json"
meta() { jq -n --argjson l "$1" '{repo:"r",viewer:"maint",label_exists:$l,branch:"main",head:"abc",anchor:"found"}' >"$snap/meta.json"; }
meta true

cat >"$T/valid.md" <<'MD'
## Header

- Run date: 2026-11-21

## Covered by merged work

### #90: Add --dry-run

- Proposed action: close #90 as completed, citing PR #91

## Duplicate or cluster

### #50: Dark mode

### #51: Dark mode too

## Proposed actions

### Covered by merged work

- Close #90 as completed, citing PR #91
MD

run_publish() { # <report> -> sets RC, OUT
  OUT="$(bash "$PUBLISH" "$repo" "$snap" "$1" 2026-11-21 2>&1)"; RC=$?
}

# Valid report, label exists: one create with --label, one close of #80.
GH_STUB_NEW_NUMBER=120 run_publish "$T/valid.md"
assert_eq "0" "$RC" "valid report should publish: $OUT"
assert_eq "1" "$(grep -c '^issue create' "$GH_STUB_LOG")" "exactly one issue create"
assert_contains "$(grep '^issue create' "$GH_STUB_LOG")" "--title Triage 2026-11-21" "title"
assert_contains "$(grep '^issue create' "$GH_STUB_LOG")" "--label triage" "labelled when the label exists"
assert_eq "issue close 80 --reason not planned --comment Superseded by #120" "$(grep '^issue close' "$GH_STUB_LOG")" \
  "exactly one close of the earlier report, linking the new one"
cmp -s "$T/valid.md" "$GH_STUB_DIR/created-body.md" || fail "body should be the report unchanged when the label exists"
assert_eq "" "$(grep -E '^(issue (edit|comment)|label)' "$GH_STUB_LOG")" "no edit, comment or label call"

# Missing one issue: no write, non-zero.
: >"$GH_STUB_LOG"
grep -v '### #51' "$T/valid.md" >"$T/missing.md"
run_publish "$T/missing.md"
[[ $RC -ne 0 ]] || fail "a report missing #51 should fail"
assert_contains "$OUT" "no entry for #51" "names the missing issue"
assert_eq "" "$(gh_writes)" "no write call for an invalid report"
assert_eq "" "$(gh_calls)" "no gh call at all for an invalid report"

# Other invalid shapes.
check_invalid() { # <file> <expected reason>
  : >"$GH_STUB_LOG"; run_publish "$1"
  [[ $RC -ne 0 ]] || fail "should be invalid: $2"
  assert_contains "$OUT" "$2" "reason"
  assert_eq "" "$(gh_writes)" "no write for: $2"
}
{ cat "$T/valid.md"; printf '\n## Still relevant\n\n### #77: Extra\n'; } >"$T/x.md"
check_invalid "$T/x.md" "after '## Proposed actions'"
sed 's/^## Duplicate or cluster$/## Still relevant\n\n### #50: Dark mode\n\n## Duplicate or cluster/' "$T/valid.md" >"$T/dup.md"
check_invalid "$T/dup.md" "issue #50 has more than one entry"
sed 's/^### #51: Dark mode too$/### #51: Dark mode too\n\n### #52: Not in snapshot/' "$T/valid.md" >"$T/extra.md"
check_invalid "$T/extra.md" "entries for issues not in the snapshot: #52"
{ echo "Here is the report:"; cat "$T/valid.md"; } >"$T/pre.md"
check_invalid "$T/pre.md" "text before '## Header'"
sed 's/^## Duplicate or cluster$/## Clusters/' "$T/valid.md" >"$T/bad.md"
check_invalid "$T/bad.md" "unexpected heading '## Clusters'"
grep -v '^## Proposed actions' "$T/valid.md" >"$T/noact.md"
check_invalid "$T/noact.md" "no '## Proposed actions' section"
{ cat "$T/valid.md"; head -c 70000 /dev/zero | tr '\0' 'x'; echo; } >"$T/big.md"
check_invalid "$T/big.md" "over GitHub's 65536"

# An existing same-date report (any state): no create.
: >"$GH_STUB_LOG"
jq -n '[{number:119,title:"Triage 2026-11-21",author:{login:"maint"}}]' >"$GH_STUB_DIR/all-issues.json"
run_publish "$T/valid.md"
assert_eq "0" "$RC" "an existing same-date report exits 0"
assert_contains "$OUT" "already published" "says already published"
assert_eq "" "$(gh_writes)" "no create when the same-date report exists"
# A same-date look-alike by someone else doesn't count.
: >"$GH_STUB_LOG"
jq -n '[{number:119,title:"Triage 2026-11-21",author:{login:"mallory"}}]' >"$GH_STUB_DIR/all-issues.json"
run_publish "$T/valid.md"
assert_eq "1" "$(grep -c '^issue create' "$GH_STUB_LOG")" "another author's same-date issue doesn't block"
rm -f "$GH_STUB_DIR/all-issues.json"

# No label: no --label, no label create, the body names the missing label.
: >"$GH_STUB_LOG"
meta false
run_publish "$T/valid.md"
assert_eq "0" "$RC" "publishes without the label"
assert_not_contains "$(grep '^issue create' "$GH_STUB_LOG")" "--label" "no --label without the label"
assert_eq "" "$(grep '^label' "$GH_STUB_LOG")" "no label call"
assert_contains "$(cat "$GH_STUB_DIR/created-body.md")" 'the `triage` label is missing' "body names the missing label"

# A failed create: non-zero, no close.
: >"$GH_STUB_LOG"
GH_STUB_FAIL=issue-create run_publish "$T/valid.md"
[[ $RC -ne 0 ]] || fail "a failed create should exit non-zero"
assert_eq "" "$(grep '^issue close' "$GH_STUB_LOG")" "no close after a failed create"

# A failed close of the superseded report: exit 3, the report stands.
: >"$GH_STUB_LOG"
GH_STUB_FAIL=issue-close run_publish "$T/valid.md"
assert_eq "3" "$RC" "a failed supersede close exits 3"

# No report besides the earlier one: only one close per other open report.
: >"$GH_STUB_LOG"
jq -n '[]' >"$snap/reports.json"
run_publish "$T/valid.md"
assert_eq "" "$(grep '^issue close' "$GH_STUB_LOG")" "nothing to supersede, no close"

# #93 (DES-004): the header's Run date is set to <date>; nothing else changes.
meta true
# A wrong header date, and an entry body quoting a Run date line that must stay.
sed -e 's/^- Run date: 2026-11-21$/- Run date: 2026-11-20/' \
    -e 's/^- Proposed action: close #90 as completed, citing PR #91$/&\n- Run date: 2026-11-20 (quoted from the issue)/' "$T/valid.md" >"$T/wrongdate.md"
assert_contains "$(cat "$T/wrongdate.md")" "- Run date: 2026-11-20 (quoted" "fixture holds the quoted line"
: >"$GH_STUB_LOG"
run_publish "$T/wrongdate.md"
assert_eq "0" "$RC" "a wrong header date still publishes: $OUT"
sed '0,/^- Run date: 2026-11-20$/s//- Run date: 2026-11-21/' "$T/wrongdate.md" >"$T/wrongdate.expected"
cmp -s "$T/wrongdate.expected" "$GH_STUB_DIR/created-body.md" \
  || fail "only the header's Run date changes: $(diff "$T/wrongdate.expected" "$GH_STUB_DIR/created-body.md")"
assert_contains "$(cat "$GH_STUB_DIR/created-body.md")" "- Run date: 2026-11-20 (quoted from the issue)" "the entry's quoted line is untouched"
assert_contains "$OUT" "set the report header's Run date to 2026-11-21 (the report said '2026-11-20')" "says the date was changed"
assert_eq "Triage 2026-11-21" "$(cat "$GH_STUB_DIR/created-title")" "the title uses the same date"
# A header with no Run date line gets one as its first item.
grep -v '^- Run date:' "$T/valid.md" | sed 's/^## Header$/## Header\n\n- Repository: r/' >"$T/nodate.md"
: >"$GH_STUB_LOG"
run_publish "$T/nodate.md"
assert_eq "0" "$RC" "a header with no Run date publishes: $OUT"
assert_eq "- Run date: 2026-11-21" "$(awk '/^- /{print; exit}' "$GH_STUB_DIR/created-body.md")" "the Run date is the header's first item"
assert_eq "1" "$(grep -c '^- Run date:' "$GH_STUB_DIR/created-body.md")" "exactly one Run date line added"
sed '/^- Run date: 2026-11-21$/d' "$GH_STUB_DIR/created-body.md" | cmp -s "$T/nodate.md" - || fail "nothing else changes when the line is added"
assert_contains "$OUT" "had no Run date; added '- Run date: 2026-11-21'" "says the line was added"
# A report with no final newline keeps that byte too.
printf '%s' "$(cat "$T/wrongdate.md")" >"$T/nonl.md"
: >"$GH_STUB_LOG"
run_publish "$T/nonl.md"
printf '%s' "$(cat "$T/wrongdate.expected")" | cmp -s - "$GH_STUB_DIR/created-body.md" || fail "no final newline is added"
# The right date already: no message, body unchanged (checked above with cmp).
: >"$GH_STUB_LOG"
run_publish "$T/valid.md"
assert_not_contains "$OUT" "Run date" "no message when the date is already right"

# The stub log never held an edit, a comment on a non-report issue, or a label call.
assert_eq "" "$(grep -E '^(issue (edit|comment)|label)' "$GH_STUB_LOG")" "never edit, comment or label"

# DES-002: stock-take.md's example report passes this validator.
awk '/^```markdown$/ {on=1; next} /^```$/ {on=0} on' "$TRIAGE_SKILL_DIR/reference/stock-take.md" >"$T/example.md"
assert_contains "$(cat "$T/example.md")" "## Header" "example report extracted"
{ issue_json 90 "Add --dry-run"; issue_json 50 "Fix dark-mode diagrams"; issue_json 51 "Diagrams unreadable in dark mode"; } \
  | jq -s . >"$snap/issues.json"
: >"$GH_STUB_LOG"
run_publish "$T/example.md"
assert_eq "0" "$RC" "stock-take.md's example report should pass the validator: $OUT"

exit 0
