#!/usr/bin/env bash
# schedule_test.sh
# DES-006: install-schedule.sh and uninstall-schedule.sh against a stub
# crontab backed by a file under TMPDIR, and a stub gh.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
triage_setup
INSTALL="$TRIAGE_SCRIPTS/install-schedule.sh"
UNINSTALL="$TRIAGE_SCRIPTS/uninstall-schedule.sh"
repo="$(make_triage_repo)"
marker="# compass-labs:triage: $repo"
export TRIAGE_NOW="2026-11-14 00:00Z"

# The maintainer's existing crontab: a doc-maintainer job and the midnight job.
cat >"$CRONTAB_STUB_FILE" <<CRON
15 13 * * * /bin/bash /opt/compass/skills/doc-maintainer/scripts/maintain.sh /home/me/proj # doc-maintainer: /home/me/proj
0 11,12 * * * /home/me/bin/midnight-job.sh
CRON
cp "$CRONTAB_STUB_FILE" "$T/before"
jq -n '[{name:"bug"}]' >"$GH_STUB_DIR/labels.json"

# Install Saturday 01:00 Pacific/Auckland: exactly two lines, the rest kept.
out="$(bash "$INSTALL" "$repo" --day sat --time 01:00 --tz Pacific/Auckland 2>&1)" \
  || fail "install should succeed: $out"
mapfile -t added < <(grep -F "$marker" "$CRONTAB_STUB_FILE")
assert_eq "2" "${#added[@]}" "exactly two triage lines"
assert_eq "0 12 * * 5" "$(cut -d' ' -f1-5 <<<"${added[0]}")" "NZDT slot"
assert_eq "0 13 * * 5" "$(cut -d' ' -f1-5 <<<"${added[1]}")" "NZST slot"
assert_eq "$(cat "$T/before")" "$(head -2 "$CRONTAB_STUB_FILE")" "the other lines are kept byte for byte, first"
cmp -s "$T/before" <(grep -vF "$marker" "$CRONTAB_STUB_FILE") || fail "the other lines are byte-for-byte unchanged"
for l in "${added[@]}"; do
  assert_contains "$l" "TRIAGE_CLAUDE_BIN='$TRIAGE_STUBS/claude'" "the claude path found at install"
  assert_contains "$l" "TRIAGE_GH_BIN='$TRIAGE_STUBS/gh'" "the gh path found at install"
  assert_contains "$l" "/bin/bash '$TRIAGE_SCRIPTS/run-scheduled.sh' '$repo' --day sat --time 01:00 --tz Pacific/Auckland" "runs the guarded runner"
  [[ "$l" == *"$marker" ]] || fail "each line ends with the marker"
  assert_not_contains "$l" "%" "no % in a cron line"
done
assert_contains "$out" "Next run: Sat 2026-11-21 01:00 NZDT" "prints the next local run time"
assert_eq "1" "$(grep -c '^label create triage' "$GH_STUB_LOG")" "no label: one label create triage"
assert_contains "$(gh_calls)" "auth status" "checks gh auth"

# The cron line, run by sh at a slot time, reaches the runner's guard (the
# runner then exits at the guard because TRIAGE_NOW is off-slot).
cmd="$(sed -E 's/^([^ ]+ ){5}//' <<<"${added[0]}")"
TRIAGE_NOW="2026-11-14 00:00Z" sh -c "$cmd" || fail "the cron command line should run under sh"

# A second install for Sunday 02:00: refused, names the Saturday line, unchanged.
cp "$CRONTAB_STUB_FILE" "$T/installed"
: >"$GH_STUB_LOG"
out="$(bash "$INSTALL" "$repo" --day sun --time 02:00 --tz Pacific/Auckland 2>&1)" && fail "a second install should fail"
assert_contains "$out" "already has a triage schedule" "refusal message"
assert_contains "$out" "${added[0]}" "names the existing Saturday line"
cmp -s "$T/installed" "$CRONTAB_STUB_FILE" || fail "the crontab is unchanged after a refused install"
assert_eq "" "$(grep '^label create' "$GH_STUB_LOG")" "a refused install creates no label"

# A schedule for another repo whose path starts with this one's is separate.
other="${repo}-two"
mkdir -p "$other" && git -C "$other" init -q
bash "$INSTALL" "$other" --day mon --time 09:30 --tz UTC >/dev/null 2>&1 || fail "another repo can be scheduled"
assert_eq "30 9 * * 1" "$(grep -F "# compass-labs:triage: $other" "$CRONTAB_STUB_FILE" | cut -d' ' -f1-5)" "UTC: one slot"

# Uninstall: only this repo's lines go, the others are identical (cmp).
out="$(bash "$UNINSTALL" "$repo" 2>&1)" || fail "uninstall should succeed: $out"
assert_eq "" "$(grep -E "# compass-labs:triage: $repo\$" "$CRONTAB_STUB_FILE")" "this repo's lines are gone"
cmp -s "$T/before" <(head -2 "$CRONTAB_STUB_FILE") || fail "the other two lines are identical after uninstall"
assert_eq "1" "$(grep -c "# compass-labs:triage: $other" "$CRONTAB_STUB_FILE")" "the other repo's schedule stays"
bash "$UNINSTALL" "$other" >/dev/null || fail "uninstall the other repo"
cmp -s "$T/before" "$CRONTAB_STUB_FILE" || fail "after both uninstalls the crontab is byte-for-byte the original"

# Nothing to remove: said so, unchanged.
out="$(bash "$UNINSTALL" "$repo" 2>&1)" || fail "uninstall with nothing to remove exits 0"
assert_contains "$out" "Nothing to remove" "says there was nothing to remove"
cmp -s "$T/before" "$CRONTAB_STUB_FILE" || fail "unchanged when nothing to remove"

# An existing label: no create. No crontab at all: install creates one.
rm -f "$CRONTAB_STUB_FILE"; : >"$GH_STUB_LOG"
jq -n '[{name:"triage"}]' >"$GH_STUB_DIR/labels.json"
bash "$INSTALL" "$repo" --day sat --time 01:00 --tz Pacific/Auckland >/dev/null 2>&1 || fail "install on an empty crontab"
assert_eq "2" "$(grep -c . "$CRONTAB_STUB_FILE")" "two lines in a new crontab"
assert_eq "" "$(grep '^label create' "$GH_STUB_LOG")" "an existing label isn't created again"
bash "$UNINSTALL" "$repo" >/dev/null

# A half-hour zone, and a DST gap warning (Auckland 02:30 on Sunday 2027-09-26).
out="$(bash "$INSTALL" "$repo" --day sun --time 02:30 --tz Pacific/Auckland 2>&1)" || fail "install 02:30: $out"
assert_contains "$out" "Warning: 02:30 on 2027-09-26 doesn't exist in Pacific/Auckland" "warns about the DST gap"
bash "$UNINSTALL" "$repo" >/dev/null
bash "$INSTALL" "$repo" --day 6 --time 01:00 --tz Asia/Kolkata >/dev/null 2>&1 || fail "numeric day, half-hour zone"
assert_eq "30 19 * * 5" "$(grep -F "$marker" "$CRONTAB_STUB_FILE" | cut -d' ' -f1-5)" "Kolkata Sat 01:00 is Fri 19:30 UTC"
bash "$UNINSTALL" "$repo" >/dev/null

# Validation: bad day, time, zone, unauthenticated gh: non-zero, crontab unchanged.
cp "$CRONTAB_STUB_FILE" "$T/now" 2>/dev/null || : >"$T/now"
for args in "--day funday --time 01:00 --tz UTC" "--day sat --time 25:00 --tz UTC" \
            "--day sat --time 01:00 --tz Mars/Base" "--day sat --time 1:00 --tz UTC"; do
  # shellcheck disable=SC2086
  bash "$INSTALL" "$repo" $args >/dev/null 2>&1 && fail "should reject: $args"
done
GH_STUB_FAIL=auth bash "$INSTALL" "$repo" --day sat --time 01:00 --tz UTC >/dev/null 2>&1 && fail "should refuse without gh auth"
cmp -s "$T/now" "$CRONTAB_STUB_FILE" 2>/dev/null || [[ ! -s "$T/now" && ! -s "$CRONTAB_STUB_FILE" ]] \
  || fail "a rejected install leaves the crontab unchanged"
assert_eq "" "$(git -C "$repo" status --porcelain --ignored)" "nothing written in the repository"

exit 0
