# Define: Triage scheduled-run fixes

> Phase: Define | Started: 2026-11-14 | Status: Draft
> Relates to: Issue #93 (also #91) · Session history: [`log.md`](../log.md)

## Contents

- [Requirements](requirements.md): the `REQ-*` table and any deferred requirements
- [Framing](framing.md): problem checks, anchor verdict and overlaps
- [Problem](problem.md): need, stakeholders, evidence and success outcomes

## Framing

- **Tier:** short: two contained bugs in two triage scripts (`install-schedule.sh`, `run-scheduled.sh`) with known causes, but both break a promise of the unattended run (a report every week, dated correctly), so the need, evidence and success signal are worth a quick check. Proposed by the Define agent and taken as the default because the user asked for the session to run to Close without stopping.
- **Verdict:** aligns with the project anchor. See [framing.md](framing.md).

## Problem statement

A maintainer's weekly scheduled triage stops producing reports as soon as Claude Code auto-updates itself, and the reports it does produce can carry a header run date a day off from their title. Needs: NEED-01, NEED-02. Outcomes: OUT-01, OUT-02. See [problem.md](problem.md).

## Scope

- Binary paths the installer writes into the cron lines stay valid across an in-place update of the tool behind them: [REQ-001 to REQ-003](requirements.md#requirements).
- A scheduled report's header run date is the run's local date, the same date as its title: [REQ-004, REQ-005](requirements.md#requirements).
- The triage docs stop listing #91 and #93 as known limitations and tell existing installs how to pick up the fix: [REQ-006](requirements.md#requirements).

### Non-goals

- Rewriting existing crontab lines automatically. A maintainer with an existing schedule reinstalls it (REQ-006 documents how).
- The interactive stock-take's run date. In a user's own session the model's date is the user's date; only the scheduled run changes.
- Cron's PATH and the OAuth token file on the maintainer's VM (#92), and the other headless runners (`doc-maintainer`, `task-executor`) and their installers.
- Any change to the headless session's isolation (ADR-010): tools, flags and write authority stay as they are.

## Constraints

- ADR-010 holds: the headless model only reads and prints; deterministic scripts make every GitHub write; the prompt stays `reference/stock-take.md` with the scripted preamble before it.
- Cron lines are run by `/bin/sh` and hold single-quoted paths; the existing refusal of paths containing `%`, `'` or a newline stays.
- Everything is testable with the bash + jq harness (`tests/run.sh`) and the stub `claude`, `gh` and `crontab` in `tests/triage/stubs/`, with `TRIAGE_NOW` standing in for the clock.

## Open questions

All questions resolved. Defaults taken without asking (the user asked to run to Close): short tier; the fix applies to `gh` as well as `claude`, since both go through the same path resolution; the published header's date is guaranteed by the run itself (REQ-005, Should), not only requested of the model (REQ-004).
