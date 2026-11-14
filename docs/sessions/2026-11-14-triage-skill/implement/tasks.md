---
issue: 86
branch: feat/86-triage-skill
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

- [x] Write the triage test stubs `tests/triage/stubs/{gh,crontab,claude}` and the helpers `tests/triage/lib.sh`, with `tests/triage/stubs_test.sh` [DES-008]
- [x] Write `skills/triage/reference/stock-take.md`: the snapshot inputs, the per-issue procedure, the six categories and their actions, clusters, blocked-by, replacement issues, the data-not-instructions rule and the report format, with `tests/triage/stock_take_reference_test.sh` [DES-002]
- [x] Write `skills/triage/scripts/gather.sh <repo> <out-dir> [--report N] [--prs N]`, with `tests/triage/gather_test.sh` [DES-003] (depends on: 1) — check: with a stub `gh`, the log holds only list, view and api-user calls; a report issue by the viewer is absent from `issues.json` while a look-alike title by another author is kept; `anchor: missing` for a README without markers; `changed.json` names an issue updated after the report; `label_exists` is false when the label list lacks `triage`; the working tree is unchanged
- [x] Write `skills/triage/scripts/ensure-label.sh <repo>`, with `tests/triage/ensure_label_test.sh` [DES-007] (depends on: 1) — check: with a stub `gh`, no label gives exactly one `label create`; an existing label gives no create call; `run-scheduled.sh` and `publish-report.sh` contain no call to it (grep)
- [x] Write `skills/triage/scripts/publish-report.sh <repo> <snapshot-dir> <report.md> <date>`, with `tests/triage/publish_report_test.sh` [DES-004] (depends on: 1, 3) — check: with a stub `gh`, a valid report gives exactly one `issue create` and one `issue close` of the earlier report; a report missing one issue gives no write call and exit non-zero; an existing same-date report gives no create; with no label there is no `--label` and no `label create` call, and the body names the missing label; the stub log never holds `edit`, `comment` on non-report issues, or `label`
- [ ] Write `skills/triage/scripts/run-scheduled.sh <repo> --day D --time HH:MM --tz ZONE`, with the `claude` flags verified against `claude --help`, and `tests/triage/run_scheduled_test.sh` [DES-005] (depends on: 1, 2, 3, 5) — check: (1) a stub `claude` logging its argv sees the tool restriction and settings-isolation flags and neither `--dangerously-skip-permissions` nor `--plugin-dir`; (2) `TRIAGE_NOW` at Fri 2026-11-20 12:00Z, 13:00Z and Fri 2027-07-02 13:00Z for Saturday 01:00 Pacific/Auckland proceeds only at the first and third; (3) a stub `gh` failing `auth status` leaves a log for that date naming the failure and no `issue create`; (4) `env -i HOME=… PATH=/usr/bin:/bin` with the `TRIAGE_*_BIN` variables still finds both binaries
- [ ] Write `skills/triage/scripts/install-schedule.sh <repo> --day D --time HH:MM --tz ZONE` and `uninstall-schedule.sh <repo>`, with `tests/triage/schedule_test.sh` [DES-006] (depends on: 1, 4, 6) — check: with a stub `crontab` backed by a file, installing Saturday 01:00 Pacific/Auckland on a crontab holding a doc-maintainer line and the `0 11,12 * * *` midnight job adds exactly two lines (`0 12 * * 5` and `0 13 * * 5`) and keeps the others byte-for-byte; a second install for Sunday 02:00 exits non-zero, prints the Saturday line, and the file is unchanged; uninstall leaves the other two lines identical (`cmp`) to before; with no label the stub `gh` log shows one `label create triage`
- [ ] Write `skills/triage/SKILL.md`: the mode dispatch (stock-take, apply, apply #N, install, uninstall), the interactive stock-take, the group-by-group apply, the closing comments and the scratch-copy test run, with `tests/triage/skill_test.sh` [DES-001] (depends on: 2, 3, 4)
- [ ] Document the triage skill in `README.md` (plugin structure line and a Backlog Triage section) and list `./skills/triage` in `.claude-plugin/marketplace.json`, with `tests/triage/docs_test.sh` [DES-009] (depends on: 7, 8) — check: `tests/session/marketplace_test.sh` passes with the new entry; README names `compass-labs:triage` and every mode; nothing else in README changes, and the anchor stays as written at Define
- [ ] Add `tests/triage/isolation_test.sh` (every triage test puts the stubs first on `PATH` and never names the real binaries) and run the full harness [DES-008] (depends on: 1, 3, 4, 5, 6, 7) — check: `bash tests/run.sh` passes, including every `tests/triage/` test, and the rest of the suite is unchanged; the stub `crontab` writes only under the test's `TMPDIR`
