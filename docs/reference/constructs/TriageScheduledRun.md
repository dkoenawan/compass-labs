---
name: TriageScheduledRun
type: Utility
layer: Shared
file: skills/triage/scripts/run-scheduled.sh
status: built
planned_in: null
last_verified: null
---

# TriageScheduledRun

> Origin: #86

## Does

The cron entry point for a weekly unattended stock-take. It guards on the installed local day and time, takes a lock, logs outside the repository, checks its binaries and `gh auth status`, and takes a snapshot. It then runs `claude -p` headless with only Read, Grep and Glob in a `--restricted`, plugin-free session, and hands the report to the publisher. It does NOT run any `gh` write itself, apply anything, run repository code, or write in the repository.

## Functional Requirements

- [ ] Installed for Saturday 01:00 Pacific/Auckland, it proceeds at Fri 2026-11-20 12:00 UTC and Fri 2027-07-02 13:00 UTC, and at Fri 2026-11-20 13:00 UTC exits 0 with no log and no `gh` call.
- [ ] The `claude` argv holds `--tools Read,Grep,Glob`, `--restricted`, `--strict-mcp-config`, `--permission-prompts none` and `--add-dir`, and none of `--dangerously-skip-permissions`, `--plugin-dir`, `--settings`, `--mcp-config`, `--setting-sources` or `--bare`.
- [ ] On a repository whose project hook and test command write a marker file, a real run leaves no marker and an unchanged `git status`.
- [ ] With `gh` not authenticated, the day's log names the failure and no report issue is created. The same goes for a missing binary or a non-git folder.
- [ ] Under `env -i HOME=… PATH=/usr/bin:/bin`, with `TRIAGE_CLAUDE_BIN` and `TRIAGE_GH_BIN` set, it finds both binaries and publishes.
- [ ] An invalid report is kept as `{date}.report.md` beside the log, and every step's outcome and duration are logged.
- [ ] The prompt's preamble names the local run date (for example `2026-11-21` for Fri 2026-11-20 12:00 UTC at Saturday 01:00 Pacific/Auckland) as the header's Run date, and the rest of the prompt is `stock-take.md` byte for byte.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/triage/run_scheduled_test.sh

## Interface

```text
run-scheduled.sh <repo> --day D --time HH:MM --tz ZONE
env: TRIAGE_CLAUDE_BIN, TRIAGE_GH_BIN (set by the installer), TRIAGE_NOW (tests)
log: ${XDG_STATE_HOME:-$HOME/.local/state}/compass-labs/triage/{repo-slug}/{local-date}.log
exit 0 ok, wrong slot, or lock held · 1 failure (logged) · 2 bad arguments
```

## Dependencies

- Calls: [TriageSnapshot](TriageSnapshot.md), `claude -p` under `timeout 50m`, [TriageReportPublisher](TriageReportPublisher.md), `gh auth status`
- Called by: cron, through the lines [TriageSchedule](TriageSchedule.md) writes
- Reads: [StockTakeProcedure](StockTakeProcedure.md) (as the prompt), the working tree
- Writes: the run log and lock outside the repository

## Patterns Applied

- [An unattended model run reads; scripts write](../../registry/patterns.md#an-unattended-model-run-reads-scripts-write)

## Key Decisions

- [ADR-010](../../registry/decisions/010-read-only-scheduled-triage-run.md): read-only headless model, `--restricted` isolation, scripts own every write.
