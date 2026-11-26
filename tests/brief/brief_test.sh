#!/usr/bin/env bash
# brief_test.sh
# skills/brief (ADR-012): gather + render build the weekly brief from the run
# log, trellis/* PRs and the month's findings (cadence share vs the 3:1
# target, per-project table, usage, findings, appendix); publish creates one
# issue and closes the earlier one; the controller publishes it once on
# brief_day. gh is a stub; nothing real is touched.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"
B="$REPO_ROOT/skills/brief/scripts"

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
for n in mycelia trellis; do git init -q -b main "$work/$n"; mkdir -p "$work/$n/docs/findings"; done
printf -- '---\ndate: 2026-11-08\ntype: risk\ntitle: Cache may go stale\n---\n' > "$work/mycelia/docs/findings/2026-11-08-cache.md"
printf -- '---\ndate: 2026-11-09\ntype: trellis\ntitle: close missed a layer\n---\n' > "$work/mycelia/docs/findings/2026-11-09-close.md"
printf -- '---\ndate: 2026-10-30\ntype: learning\ntitle: last month\n---\n' > "$work/mycelia/docs/findings/2026-10-30-old.md"

export TRELLIS_STATE_DIR="$work/state" TRELLIS_CONTROLLER_CONFIG="$work/controller.json"
mkdir -p "$TRELLIS_STATE_DIR"
jq -n --arg m "$work/mycelia" --arg c "$work/trellis" '{timezone:"UTC", slots:["02:00"], runs_per_day:1, brief_day:"mon",
  max_minutes:5, model:"sonnet", label:"trellis:ready", projects:[{repo:$m, role:"side"}], compass_repo:$c, brief_repo:$c}' > "$TRELLIS_CONTROLLER_CONFIG"
{
  echo '{"date":"2026-11-03","status":"ran","role":"side","repo":"'"$work"'/mycelia","issue":3,"pr":10,"output_tokens":900,"minutes":20}'
  echo '{"date":"2026-11-05","status":"ran","role":"side","repo":"'"$work"'/mycelia","issue":4,"pr":11,"output_tokens":700,"minutes":15}'
  echo '{"date":"2026-11-06","status":"failed","role":"side","repo":"'"$work"'/mycelia","issue":5,"pr":"none","output_tokens":300,"minutes":9}'
  echo '{"date":"2026-11-07","status":"idle","role":"side","repo":"'"$work"'/mycelia"}'
  echo '{"date":"2026-10-28","status":"ran","role":"compass","repo":"'"$work"'/trellis","issue":1,"pr":2,"output_tokens":1,"minutes":1}'
} > "$TRELLIS_STATE_DIR/runs.jsonl"

cat > "$work/gh" <<STUB
#!/usr/bin/env bash
case "\$*" in
  "pr list --state all"*) if [[ "\$PWD" == *mycelia ]]; then
     echo '[{"number":11,"title":"Validate pages","url":"https://x/11","state":"OPEN","headRefName":"trellis/4-validate","mergedAt":null},
            {"number":10,"title":"Fix paging","url":"https://x/10","state":"MERGED","headRefName":"trellis/3-paging","mergedAt":"2026-11-06T01:00:00Z"},
            {"number":9,"title":"Human PR","url":"https://x/9","state":"OPEN","headRefName":"feat/human","mergedAt":null}]'
   else echo '[]'; fi ;;
  "issue list"*) echo 41 ;;
  "issue create"*) echo "https://x/issues/42"; echo "\$*" >> "$work/gh-writes" ;;
  "issue close"*|"label create"*) echo "\$*" >> "$work/gh-writes" ;;
esac
STUB
chmod +x "$work/gh"; export GH_BIN="$work/gh" CLAUDE_BIN=/bin/false

bash "$B/gather.sh" "$work/snap" 2026-11-09 >/dev/null || fail "gather should succeed"
out="$(bash "$B/render.sh" "$work/snap")"
assert_contains "$out" "# Trellis brief · 2026-11-03 → 2026-11-09" "title with the week"
assert_contains "$out" "**Your call:** 1 PR(s) to review." "only trellis/* open PRs count"
assert_contains "$out" "- [mycelia #11](https://x/11) Validate pages" "the PR to review is linked"
assert_not_contains "$out" "Human PR" "non-compass PRs aren't listed"
assert_contains "$out" '"Side projects" : 2' "two side runs completed this month"
assert_contains "$out" '"trellis" : 0' "last month's compass run isn't counted"
assert_contains "$out" "**100%** of this month's runs went to side projects (on target" "cadence share and verdict"
assert_contains "$out" "| mycelia | side | 2 | 1 / 1 | 1 | 1 |" "per-project table"
assert_contains "$out" "**Usage this week:** 1900 output tokens over 44 run-minutes." "usage from the log"
assert_contains "$out" "**1 trellis** (for the trellis week)" "compass findings counted"
assert_not_contains "$out" "last month" "findings from earlier months are excluded"
assert_contains "$out" "⚠ 1 new risk finding(s)" "a new risk is flagged in Your call"
assert_contains "$out" "<details><summary>Appendix: run log this week</summary>" "collapsed appendix"
assert_contains "$out" "This week is a **side** week. Next week is **side**." "cadence roles"

echo "$out" > "$work/brief.md"
url="$(bash "$B/publish.sh" "$work/brief.md" 2026-11-09)"
assert_eq "https://x/issues/42" "$url" "publish returns the new issue"
assert_contains "$(cat "$work/gh-writes")" "issue close 41 --comment Superseded by https://x/issues/42" "the earlier brief is closed"

# The controller publishes it once on brief_day (2026-11-09 is a Monday).
: > "$work/gh-writes"
TRELLIS_NOW="2026-11-09 02:00" bash "$REPO_ROOT/skills/controller/scripts/run.sh" >/dev/null 2>&1
grep -q '"status":"brief"' "$TRELLIS_STATE_DIR/runs.jsonl" || fail "the controller should log the brief"
TRELLIS_NOW="2026-11-09 02:00" bash "$REPO_ROOT/skills/controller/scripts/run.sh" >/dev/null 2>&1
assert_eq 1 "$(grep -c 'issue create' "$work/gh-writes")" "the brief is published once per day"

echo "ok: brief validated"
