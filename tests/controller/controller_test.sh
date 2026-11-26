#!/usr/bin/env bash
# controller_test.sh
# skills/controller (ADR-012): cadence, task picking, slot and daily-limit
# gating, dry run, a full run with stub claude/gh (brief ∥ pstack, close,
# branch, PR, log line), dirty-tree skip, and schedule install/uninstall
# with a stub crontab. Nothing touches the real ~/.config, ~/.local or cron.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"
S="$REPO_ROOT/skills/controller/scripts"

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT

# --- cadence ---------------------------------------------------------------
assert_eq side "$(bash "$S/cadence.sh" 2026-11-23)" "Nov 23 is week 3 (side)"
assert_eq compass "$(bash "$S/cadence.sh" 2026-11-24)" "Nov 24 is in the last 7 days (compass)"
assert_eq compass "$(bash "$S/cadence.sh" 2026-02-28)" "Feb 28 is compass"
assert_eq side "$(bash "$S/cadence.sh" 2026-02-21)" "Feb 21 is side"

# --- fixtures: a side repo with a bare origin -------------------------------
git init -q --bare -b main "$work/origin.git"
repo="$work/side"; git init -q -b main "$repo"
git -C "$repo" config user.email t@e.com; git -C "$repo" config user.name T
echo a > "$repo/README"; git -C "$repo" add . && git -C "$repo" commit -qm seed
git -C "$repo" remote add origin "$work/origin.git"; git -C "$repo" push -q origin main; git -C "$repo" remote set-head origin main

export COMPASS_STATE_DIR="$work/state" COMPASS_CONTROLLER_CONFIG="$work/controller.json"
jq -n --arg r "$repo" '{timezone:"UTC", slots:["02:00"], runs_per_day:1, max_minutes:5, model:"sonnet", label:"compass:ready",
  projects:[{repo:$r, role:"side"}], compass_repo:$r, brief_repo:$r}' > "$COMPASS_CONTROLLER_CONFIG"

# stub gh: issues 4 and 7 ready; 4 already has an open compass PR; pr list --head returns PR 12 once created.
cat > "$work/gh" <<STUB
#!/usr/bin/env bash
case "\$*" in
  "pr list --state open --json headRefName"*) echo "compass/4-old-work" ;;
  "issue list"*) printf '4\tOld work\n7\tPage One Skips Items!\n' ;;
  "pr list --head"*) [[ -f "$work/pr-made" ]] && echo 12 ;;
esac
STUB
# stub claude: records argv; pstack commits a change, close writes docs.
cat > "$work/claude" <<STUB
#!/usr/bin/env bash
echo "\$2" | cut -c1-40 >> "$work/claude-calls"
case "\$2" in
  /pstack:poteto-mode*) echo fix > fix.txt; git add fix.txt; git commit -qm fix; touch "$work/pr-made"
    echo '{"type":"result","modelUsage":{"claude-sonnet-5-5":{"outputTokens":100},"claude-opus-5-5":{"outputTokens":50}}}' ;;
  /compass-labs:problem-statement*) mkdir -p docs/briefs; echo brief > docs/briefs/b.md
    echo '{"type":"result","modelUsage":{"claude-sonnet-5-5":{"outputTokens":10}}}' ;;
  /compass-labs:close*) git add -A; git commit -qm 'docs: close'; echo '{"type":"result","modelUsage":{"claude-sonnet-5-5":{"outputTokens":5}}}' ;;
esac
STUB
chmod +x "$work/gh" "$work/claude"
export GH_BIN="$work/gh" CLAUDE_BIN="$work/claude"

# --- pick-task ---------------------------------------------------------------
assert_eq $'7\tPage One Skips Items!' "$(bash "$S/pick-task.sh" "$repo" compass:ready)" "issue 4 is busy, so 7 is picked"

# --- slot gating and dry run ----------------------------------------------------
COMPASS_NOW="2026-11-10 05:00" bash "$S/run.sh"; assert_eq 0 $? "outside a slot should exit 0"
[[ ! -f "$work/claude-calls" ]] || fail "outside a slot, claude must not run"
plan="$(COMPASS_NOW="2026-11-10 02:00" bash "$S/run.sh" --dry-run)"
assert_eq "compass/7-page-one-skips-items" "$(jq -r .branch <<<"$plan")" "branch from issue number and title slug"
assert_eq side "$(jq -r .role <<<"$plan")" "week 2 is a side week"
assert_eq "main" "$(git -C "$repo" branch --show-current)" "a dry run changes nothing"

# --- full run ------------------------------------------------------------------
COMPASS_NOW="2026-11-10 02:00" bash "$S/run.sh"; assert_eq 0 $? "a full run should succeed"
calls="$(cat "$work/claude-calls")"
assert_contains "$calls" "/compass-labs:problem-statement #7" "the brief should run"
assert_contains "$calls" "/pstack:poteto-mode" "pstack should run"
assert_eq "/compass-labs:close compass/7-page-one-s" "$(tail -1 "$work/claude-calls")" "close should run last"
git -C "$repo" rev-parse -q --verify refs/heads/compass/7-page-one-skips-items >/dev/null || fail "the run branch should exist"
assert_eq "main" "$(git -C "$repo" branch --show-current)" "the checkout should be restored when clean"
assert_eq "" "$(git -C "$repo" log main --oneline -1 | grep fix)" "nothing may land on main"
last="$(tail -1 "$COMPASS_STATE_DIR/runs.jsonl")"
assert_eq ran "$(jq -r .status <<<"$last")" "status ran"
assert_eq 12 "$(jq -r .pr <<<"$last")" "the PR number is logged"
assert_eq 165 "$(jq -r .output_tokens <<<"$last")" "output tokens across the three steps"
assert_eq side "$(jq -r .role <<<"$last")" "the cadence role is logged"

# --- daily limit and dirty tree -------------------------------------------------
COMPASS_NOW="2026-11-10 02:00" bash "$S/run.sh"
assert_eq "daily limit reached" "$(tail -1 "$COMPASS_STATE_DIR/runs.jsonl" | jq -r .reason)" "a second run the same day is skipped"
echo dirty > "$repo/x"
COMPASS_NOW="2026-11-11 02:00" bash "$S/run.sh"
assert_eq "working tree not clean" "$(tail -1 "$COMPASS_STATE_DIR/runs.jsonl" | jq -r .reason)" "a dirty tree is skipped"
rm "$repo/x"

# --- schedule install / uninstall -----------------------------------------------
cat > "$work/crontab" <<STUB
#!/usr/bin/env bash
if [[ "\$1" == "-l" ]]; then cat "$work/cron" 2>/dev/null; else cat > "$work/cron"; fi
STUB
chmod +x "$work/crontab"; echo "5 4 * * * other-job" > "$work/cron"
CRONTAB_BIN="$work/crontab" bash "$S/install-schedule.sh" --env-file /tmp/x.env >/dev/null || fail "install should succeed"
assert_contains "$(cat "$work/cron")" "0 * * * * [ -r '/tmp/x.env' ] && . '/tmp/x.env'; " "hourly line with the env file"
assert_contains "$(cat "$work/cron")" "other-job" "other lines stay"
CRONTAB_BIN="$work/crontab" bash "$S/install-schedule.sh" >/dev/null 2>&1 && fail "a second install should be refused"
CRONTAB_BIN="$work/crontab" bash "$S/uninstall-schedule.sh" >/dev/null
assert_eq "5 4 * * * other-job" "$(cat "$work/cron")" "uninstall removes only the controller line"

echo "ok: controller validated"
