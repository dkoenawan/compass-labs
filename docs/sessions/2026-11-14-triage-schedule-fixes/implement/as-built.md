<!-- The as-built record in the implement/ folder (skills/implement/SKILL.md). Four sections, tables only: never a checklist line here, so nothing in this file can be read as a task. Frozen define/ and design/ are never edited; a difference from the design is recorded as a variation below and decided at the Implement gate. -->
# As built: Triage scheduled-run fixes

> Phase: Implement | Started: 2026-11-14 | Status: ready for the Implement gate
> Design: [`design/index.md`](../design/index.md) · Plan: [`tasks.md`](tasks.md) · Session history: [`log.md`](../log.md)

## As-built

<!-- One row per DES-* item in the design, each with exactly one status: built as designed | built with variation | not built. A reason is required for any status other than built as designed. A layer with no Implement guidance records "no Implement guidance for {layer}" and its follow-up issue in the Reason. Name the unit and component tests (files or test names), or "none" with the reason. -->

| DES | Status | Reason | Unit tests | Component tests |
|---|---|---|---|---|
| DES-001 | built as designed | No Implement guidance for plugin/tooling (#89; the Design path is #51): built with the repository's conventions (Bash, `tests/run.sh`). `resolve_bin` ends with `[[ "$found" = /* ]] \|\| found="$PWD/$found"` and `echo "$found"`, for the PATH lookup and the override alike; the executable check, the `%`/`'`/newline refusal and the cron line shape are unchanged. The header comment says the paths are absolute and not symlink-resolved. The new cases fail against the old `realpath` code | none: one script tested through its interface | `tests/triage/schedule_test.sh`: (a) `claude` and `gh` on PATH as symlinks to `versions/1.0.0` stubs, overrides unset, give `TRIAGE_CLAUDE_BIN='{dir}/claude'`, `TRIAGE_GH_BIN='{dir}/gh'` and no `versions/1.0.0`; (b) `TRIAGE_CLAUDE_BIN=bin/claude` from a directory holding that symlink gives `'{cwd}/bin/claude'` on both lines; the existing cases still pass |
| DES-002 | built as designed | No Implement guidance for plugin/tooling (#89; the Design path is #51). No change to `run-scheduled.sh`, as designed: its preflight checks `-x` and runs the path, following the symlink at run time. The test installs with `claude` found on PATH as a symlink to a `versions/1.0.0` stub, deletes 1.0.0, repoints the symlink at `versions/1.0.1`, then runs the installed cron line's command under `sh -c` at Sat 01:00 NZDT. Against the old `realpath` installer it fails | none: no code changed | `tests/triage/run_scheduled_test.sh` (version swap): the day's log has `step preflight: ok`, and the recorded version is 1.0.1 |
| DES-003 | built as designed | No Implement guidance for plugin/tooling (#89; the Design path is #51). The preamble heredoc gains the design's example line word for word: `The run's local date is $LOCAL_DATE ($ZONE). Write it in the header as "- Run date: $LOCAL_DATE"; don't use a date from your own clock.` `stock-take.md` is still appended unchanged (D2). The header comment's Stock-take step says so | none: one script tested through its interface | `tests/triage/run_scheduled_test.sh`: at `TRIAGE_NOW="2026-11-20 12:00Z"` for `sat 01:00 Pacific/Auckland`, `$CLAUDE_STUB_LOG.prompt` names `2026-11-21 (Pacific/Auckland)` in the preamble, and its tail is byte-identical (`cmp`) to `stock-take.md` |
| DES-004 | built as designed | No Implement guidance for plugin/tooling (#89; the Design path is #51). While building the body, before the label note and the length check, two `awk` passes find the `## Header` section by the validator's rule (up to the next `## ` heading): its first `- Run date:` line becomes `- Run date: <date>`, or, with none, one is added before the header's first list item. Validation still runs on the report as given. One stdout line (the run log) says when the date was changed or added; none when it was already right. The usage comment's step 3 documents it. The rest of the report is kept byte for byte, including a missing final newline | none: one script tested through its interface | `tests/triage/publish_report_test.sh`: a header saying 2026-11-20 published with 2026-11-21 gives a body equal (`cmp`) to the report with only that line changed, an entry's quoted `- Run date:` line untouched, and the change message; a header with no Run date gets one as its first item and nothing else changes; a report with no final newline gets none; the right date gives no message. `tests/triage/run_scheduled_test.sh`: a run whose stub report says 2026-11-20 at Sat 01:00 NZDT creates `Triage 2026-11-21` with `- Run date: 2026-11-21` in the header, and the run log has the message |
| DES-005 | built as designed | No Implement guidance for plugin/tooling (#89; the Design path is #51). Overview: the versioned-binary and model's-run-date gotchas are replaced by one gotcha telling a schedule installed before 2026-11-14 to run `uninstall-schedule.sh <repo>`, then `install-schedule.sh <repo> …`; #91 and #93 leave Open work; a changelog line records the fix. Reference: the #91 and #93 Open work rows are gone; the Schedule section says the paths are absolute and not symlink-resolved (with the reinstall note); the run's Stock-take and Publish steps and the publisher's Interface cell name the prompt date and the header date. `TriageSchedule.md`: the `realpath` key decision is replaced by the unresolved-path one, plus a requirement line. `TriageScheduledRun.md` and `TriageReportPublisher.md`: one requirement line each. #91 and #93 are still cited where the docs describe the fix (the overview changelog, `TriageSchedule.md`'s key decision), not as open work | none: documentation | `tests/triage/docs_test.sh`: the overview's Open work line and the reference's Open work table hold neither #91 nor #93, no overview gotcha cites them, the old workaround and `realpath` decision are gone, the overview says uninstall then install, and the reference says the paths aren't symlink-resolved; it fails against the old docs. `bash tests/run.sh`: 52 passed, 0 failed |

## Variations

<!-- One row per difference between the design and what was built. IDs V1, V2 … are local to this file. Every variation is decided at the Implement gate: accepted as built, or sent back for rework. Write "None." under the heading when there are none. -->

None.

## Layer artifacts

<!-- One subsection per layer this session built, shaped by that layer's guidance (skills/{layer}/reference/implement.md). Delete the example subsection when no layer has an artifact. -->

No layer artifact: the only layer is plugin/tooling, which has no Implement guidance yet (#89).

## Handed to Test

<!-- One row per DES-* Check that needs a Test-owned test (integration, ui, playwright or inspection). Implement never writes those tests. -->

None. Every Check is met by a unit or component test above: REQ-006's inspection criterion is checked mechanically by `tests/triage/docs_test.sh`, and no Check needs a real `claude`, `gh` or cron.
