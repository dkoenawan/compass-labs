---
issue: 93
branch: feat/93-triage-schedule-fixes
status: in-progress
test_command: bash tests/run.sh
last_skill_commit: null
retry_counts:
schedule: null
budget:
  max_tasks_per_run: 3
  max_wall_clock_minutes: 90
  stop_on_first_failure: true
---

<!-- The plan in the implement/ folder: the task checklist only. Tasks come from the design's Components (DES) table by the Implement standard's task rule (skills/implement/SKILL.md): each task names the DES-* it implements, tasks follow the Depends-on order, and an item's last task carries its Check, unless the Check needs a Test-owned test (then it goes under Handed to Test in as-built.md). Statuses, variations, layer artifacts and Handed to Test live in as-built.md, never here. -->

Each task names the `DES-*` item it implements. An item's last task carries its Check.

- [x] Make `install-schedule.sh`'s `resolve_bin` prefix `$PWD/` to a relative path instead of calling `realpath`, update its header comment, and add the symlinked-PATH and relative-override cases to `tests/triage/schedule_test.sh` [DES-001] — check: (a) a PATH dir whose `claude` and `gh` are symlinks to `{tmp}/versions/1.0.0/{claude,gh}` stubs, with both overrides unset, gives lines holding `TRIAGE_CLAUDE_BIN='{dir}/claude'` and `TRIAGE_GH_BIN='{dir}/gh'` and no `versions/1.0.0`; (b) run from a directory holding a `bin/claude` symlink, with `TRIAGE_CLAUDE_BIN=bin/claude`, gives `TRIAGE_CLAUDE_BIN='{cwd}/bin/claude'`; the existing schedule tests still pass
- [x] Add the version-swap case to `tests/triage/run_scheduled_test.sh`: install with `claude` a symlink to a `versions/1.0.0` stub, delete 1.0.0, point the symlink at `versions/1.0.1`, run the installed line's environment and arguments [DES-002] (depends on: 1) — check: the day's log has `step preflight: ok`, and the recorded version is 1.0.1
- [x] Add the local run date line to `run-scheduled.sh`'s prompt preamble, with its case in `tests/triage/run_scheduled_test.sh` [DES-003] — check: with `sat 01:00 Pacific/Auckland` and `TRIAGE_NOW="2026-11-20 12:00Z"`, `$CLAUDE_STUB_LOG.prompt` contains `2026-11-21`, and its tail after the preamble is byte-identical to `stock-take.md`
- [ ] Make `publish-report.sh` set the `## Header` section's `- Run date:` line to `<date>` (adding one if missing) while building the body, print a line when it changes it, document it in the usage comment, with cases in `tests/triage/publish_report_test.sh` and `tests/triage/run_scheduled_test.sh` [DES-004] — check: (a) a report whose header says `- Run date: 2026-11-20`, published with `2026-11-21`, gives a created body whose header says `- Run date: 2026-11-21` with the rest unchanged, and a header with no Run date line gets one; (b) end to end in `run_scheduled_test.sh` the created issue's title is `Triage 2026-11-21` and its body says `- Run date: 2026-11-21`
- [ ] Update the triage docs (overview, reference, `TriageSchedule`, `TriageScheduledRun`, `TriageReportPublisher`) for the unresolved paths, the prompt date and the header date, drop #91 and #93 as open work, add the reinstall gotcha, with assertions in `tests/triage/docs_test.sh` [DES-005] (depends on: 1, 2, 3, 4) — check: none of the three named docs lists #91 or #93 as an open limitation or open work, the overview names `uninstall-schedule.sh` then `install-schedule.sh` for an older schedule, and `bash tests/run.sh` passes
