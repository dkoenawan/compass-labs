---
name: TriageSchedule
type: Utility
layer: Shared
file: skills/triage/scripts/install-schedule.sh
status: built
planned_in: null
last_verified: null
---

# TriageSchedule

> Origin: #86

## Does

Installs and uninstalls a repository's weekly triage schedule in the user's crontab (`install-schedule.sh`, `uninstall-schedule.sh`). The install converts a local day, time and IANA zone to every UTC slot it maps to over a year and writes one marked line per slot. It refuses a second schedule for the same repository and creates the `triage` label. The uninstall removes only that repository's marked lines. It does NOT run the stock-take ([TriageScheduledRun](TriageScheduledRun.md) does).

## Functional Requirements

- [ ] Installing Saturday 01:00 Pacific/Auckland on a crontab with two other jobs adds exactly `0 12 * * 5` and `0 13 * * 5` lines, carrying the binary paths and the marker, and keeps the other lines byte for byte. Asia/Kolkata gives one line.
- [ ] A second install for the same repository exits non-zero, prints the existing line, leaves the crontab unchanged and creates no label.
- [ ] Uninstall leaves every other line identical (`cmp`), says so when there was nothing to remove, and keeps `/repo` and `/repo-two` separate.
- [ ] Install creates the `triage` label when it's missing, and not when it exists.
- [ ] A local time in a daylight-saving gap is warned about. A bad day, time or zone, an unauthenticated `gh`, or a path holding `%`, a single quote or a newline is refused.
- [ ] Install prints the next local run time, the run-log directory and the uninstall command.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/triage/schedule_test.sh

## Interface

```text
install-schedule.sh <repo> --day D --time HH:MM --tz ZONE     D: sun..sat or 0..6 (0 = Sunday)
uninstall-schedule.sh <repo>
cron line: {m} {h} * * {w} TRIAGE_CLAUDE_BIN='…' TRIAGE_GH_BIN='…' /bin/bash '{run-scheduled.sh}' '{repo}' --day … --time … --tz … # compass-labs:triage: {repo}
```

## Dependencies

- Calls: `crontab`, `gh auth status`, [TriageLabel](TriageLabel.md), `date` (zone conversion)
- Called by: [TriageSkill](TriageSkill.md) (install, uninstall), the user directly
- Reads: the current crontab
- Writes: the user's crontab (its own marked lines only)

## Patterns Applied

- (none)

## Key Decisions

- Local time is mapped to UTC slots with a guard in the runner, because Debian and Ubuntu cron ignore `CRON_TZ`. See the [triage overview](../../explanation/triage/overview.md#internal-architecture).
- `claude` is resolved with `realpath`, which pins a versioned binary that an auto-update removes (#93).
