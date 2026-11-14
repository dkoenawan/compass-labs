# Requirements: Triage scheduled-run fixes

> Part of [index](index.md) · Define

## Requirements

EARS syntax. Each requirement has one acceptance criterion in Given/When/Then form. IDs are never reused; a dropped requirement is struck through, not deleted. A Won't meaning "never" is struck through with its reason; a Won't meaning "later" moves to the Deferred table below.

- **"The installer"** means `skills/triage/scripts/install-schedule.sh`; **"a scheduled run"** means `skills/triage/scripts/run-scheduled.sh` started by one of the installer's cron lines.
- **"Local run date"** means the date, in the schedule's `--tz` zone, that a scheduled run's day-and-time guard computed; the report's title `Triage {date}` and the run log's file name already use it.
- **"Without resolving symlinks"** means every symlink in the path, including the last component, is kept as written; the path is only made absolute.

| ID | Requirement | Priority | Serves | Acceptance criterion |
|---|---|---|---|---|
| REQ-001 | When the installer finds `claude` or `gh` on PATH, the installer shall write that binary's absolute path, without resolving symlinks, into every cron line it installs. | Must | OUT-01 | Given a PATH directory whose `claude` is a symlink to `{tmp}/versions/1.0.0/claude` (an executable stub), and likewise for `gh`, when the installer runs with no `TRIAGE_CLAUDE_BIN` or `TRIAGE_GH_BIN`, then every installed line holds `TRIAGE_CLAUDE_BIN='{PATH dir}/claude'` and `TRIAGE_GH_BIN='{PATH dir}/gh'`, and no line holds `versions/1.0.0`. |
| REQ-002 | Where `TRIAGE_CLAUDE_BIN` or `TRIAGE_GH_BIN` is set when the installer runs, the installer shall write that path, made absolute without resolving symlinks, into every cron line it installs. | Must | OUT-01 | Given the current directory holds `bin/claude`, a symlink to an executable stub elsewhere, when the installer runs with `TRIAGE_CLAUDE_BIN=bin/claude`, then every installed line holds `TRIAGE_CLAUDE_BIN='{current directory}/bin/claude'`, not the stub's target path. |
| REQ-003 | If the binary a cron line's symlinked `claude` path pointed to at install has been removed and the symlink now points to another version, then a scheduled run shall pass preflight and run the stock-take with the version the symlink now points to. | Must | OUT-01 | Given a schedule installed with `claude` a symlink to stub version 1.0.0, and then 1.0.0 deleted and the symlink pointed at stub version 1.0.1, when a scheduled run is started with that cron line's environment and arguments at the installed local day and time, then the run log shows preflight ok and the 1.0.1 stub was the one invoked. |
| REQ-004 | When a scheduled run starts the headless stock-take, the scheduled run shall give the model the local run date as the date to put in the report header's `Run date`. | Must | OUT-02 | Given a schedule for `sat 01:00 Pacific/Auckland` and `TRIAGE_NOW="2026-11-20 12:00Z"` (a Friday in UTC, Saturday 2026-11-21 locally), when the scheduled run starts the stock-take, then the prompt the `claude` stub receives names `2026-11-21` as the report's run date. |
| REQ-005 | When a scheduled run publishes a report, the published report's header `Run date` shall be the local run date. | Should | OUT-02 | Given the same schedule and `TRIAGE_NOW` as REQ-004, and a `claude` stub whose report header says `- Run date: 2026-11-20`, when the run publishes, then the created issue's title is `Triage 2026-11-21` and its body's header says `- Run date: 2026-11-21`. |
| REQ-006 | The triage docs shall no longer describe #91 or #93 as known limitations, and shall tell a maintainer with an existing schedule to uninstall and reinstall it to pick up the unresolved binary paths. | Should | NEED-01, NEED-02 | Given the docs after this session, when `docs/explanation/triage/overview.md`, `docs/reference/triage/stock-take-and-schedule.md` and `docs/reference/constructs/TriageSchedule.md` are inspected, then none lists #91 or #93 as an open limitation or open work, and the explanation says to run `uninstall-schedule.sh` then `install-schedule.sh` for a schedule installed before the fix. |

## Deferred

None
