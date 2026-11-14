# Framing: Triage scheduled-run fixes

> Part of [index](index.md) · Define

## Problem checks

### Solution-first (XY)

- **Need behind the request:** #93 asks to "keep an absolute path without resolving symlinks"; the need is that a maintainer's installed schedule keeps running across Claude Code's (or gh's) self-updates without reinstalling or hand-editing the crontab. #91 asks to "pass the local date into the prompt"; the need is that a scheduled report's header date agrees with its title and the local day the run happened.
- **Outcome:** both requested fixes moved to Candidate solutions; the problem statement and requirements state the needs. The #93 fix is very likely the design (it is the direct fix of the shown cause), but Design picks it.

**Candidate solutions:**
- #93: in `install-schedule.sh`'s `resolve_bin`, make the found or overridden path absolute without resolving symlinks (for example `realpath -s`, or prefixing `$PWD` to a relative path), instead of `realpath`. Add a test where the PATH `claude` is a symlink to a versioned stub.
- #91: add the guard's `LOCAL_DATE` to the scripted preamble in `run-scheduled.sh`'s prompt, telling the model to use it as the header's Run date.
- #91, deterministic backstop (proposed here, not in the issue): before publishing, `run-scheduled.sh` or `publish-report.sh` sets the header's `- Run date:` line to the local date, in keeping with ADR-010's "scripts own what must be exact".

### Symptom and cause

- **#93 observed symptom:** after a Claude Code auto-update, every scheduled run fails preflight with "claude not found: TRIAGE_CLAUDE_BIN=… is not an executable file", logged under REQ-022 of the #86 triage session, and no report is published [observed: #93, as relayed in the Define handoff; workaround in `docs/explanation/triage/overview.md:138`].
- **#93 cause:** known. `resolve_bin` ends with `realpath "$found"` (`skills/triage/scripts/install-schedule.sh:83`), so `~/.local/bin/claude`, a symlink, is written into the cron line as its target `~/.local/share/claude/versions/{version}`, which the updater removes [observed: code].
- **#91 observed symptom:** a scheduled report's header says "Run date" of the UTC day (for example Friday) while its title, `Triage {date}`, says the local Saturday [observed: #91; `docs/explanation/triage/overview.md:141`].
- **#91 cause:** partly known. The prompt preamble (`skills/triage/scripts/run-scheduled.sh:166-173`) carries no date, while `reference/stock-take.md:58` asks for `- Run date: YYYY-MM-DD` [observed: code]; the title uses `LOCAL_DATE` from the guard (`run-scheduled.sh:79-80, 202`) [observed: code]. That the model then takes the date from a UTC clock is assumed [assumed].

## Anchor

- **State:** complete: markers present once (README.md:11, :44); Vision, Mission, Scope and Non-goals present and non-empty; no conflicting restatement found in the README.
- **Verdict:** aligns
- **Rests on:** Scope "Supporting skills: … backlog triage …" and "Hooks and scripts that enforce session structure and traceability" (the triage scripts); Non-goal "Replacing user approval at milestones" is untouched, since the scheduled run stays read-only and only proposes (ADR-010).

### Anchor update

- **Action:** none
- **Elements:** none
- **Agreed text:**

none

## Overlaps

- Overlap: none found. The registry constructs touched are `TriageSchedule` (`install-schedule.sh`) and `TriageScheduledRun` (`run-scheduled.sh`), and possibly `TriageReportPublisher` (`publish-report.sh`) if Design puts the date backstop there; this work corrects them rather than duplicating them. `TriageSchedule.md:57` lists #93 as a known limitation, to be updated.
- Conflict: none found. ADR-010 says the prompt is `reference/stock-take.md` "sent unchanged"; the script already sends a preamble before it, and adding the date to that preamble leaves the procedure file as it is. A script that fixes the header's date line stays within "deterministic scripts own every GitHub write". If Design changes `stock-take.md` itself, it should check this sentence of ADR-010.
