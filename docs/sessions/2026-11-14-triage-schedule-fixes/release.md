<!-- The release record, written by the Deploy agent from the Deploy standard (skills/deploy/SKILL.md). The Deploy tier line sets which sections are required (the standard's tier table); the Deploy gate's check-release.sh refuses a record missing one. Delete a section only if the confirmed tier doesn't require it. A record with no Deploy tier line is a past record and gets no check. -->
# Release: Triage scheduled-run fixes

> Phase: Deploy | Started: 2026-11-14 | Status: Draft
> Deploy tier: short: every step that ran is routine and pre-authorised by the declaration (a PATCH version bump, its commit, the branch push and marking the PR ready); the merge is the user's and doesn't count
> Requirements: [`define/index.md`](define/index.md) · Verification: [`verification.md`](verification.md) · Declaration: `.claude/deploy.json`

## Lifecycles run and why

- **L1:** not needed, because no deployable part changed. I read the frozen design's delta list ([`design/index.md`](design/index.md), *Delta list*) against `l1.parts`, which lists one part, `merge-triggered pipeline` (`.github/workflows/release.yml`, `.github/scripts/release-tag.sh`). The rows marked `changed` are `install-schedule.sh` `resolve_bin` and header comment, the `run-scheduled.sh` prompt preamble, the `publish-report.sh` body build, the tests `schedule_test.sh`, `run_scheduled_test.sh` and `publish_report_test.sh`, and the docs `overview.md`, `stock-take-and-schedule.md`, `TriageSchedule.md`, `TriageReportPublisher.md` and `TriageScheduledRun.md`. The rows marked `unchanged` are the `run-scheduled.sh` preflight, `reference/stock-take.md`, and `gather.sh` with the cron line shape, the marker and `uninstall-schedule.sh`. None of these rows is a C4 container, service or deployed resource: they're components and docs inside the triage skill, which ships as part of the plugin. No row touches the merge-triggered pipeline. The branch diff against `main` (outside `docs/sessions/`) matches this: it changes 12 files, none of them under `.github/`.
- **Added to the declaration at this Deploy (REQ-027):** none.
- **L1 setup run:** none.
- **L2:** the release ran in this session (`release_mode: in_session`). The merge is waiting for the user.

## Release strategy

Tagged release (the declared `l2.strategy`). After the user merges, the merge-triggered pipeline creates the tag `compass-labs--v2.4.1` and publishes the release.

## Completeness

I checked the release manifest as it ships: `.claude-plugin/marketplace.json`'s `plugins[0].skills` list. A marketplace install reads that list, while `claude --plugin-dir` ignores it, so I checked the file itself.

- **Every listed component exists and is complete:** all 18 listed skill folders (`adr`, `backend`, `bootstrap-new-project`, `brand-designer`, `deploy`, `design`, `doc-maintainer`, `explore`, `framing`, `implement`, `init`, `post-hook-validator`, `problem-statement`, `requirements`, `session`, `task-executor`, `triage`, `verification`) have a non-empty `SKILL.md` with a `name:` that matches the folder. No `SKILL.md` has a TODO or TBD body, and no folder under `skills/` is `.gitkeep`-only. `backend` is the shortest at 13 lines. It's a complete index, and the file it points to, `reference/implement.md`, exists. Its row for the unwritten `reference/design.md` is open work tracked in dkoenawan/compass-labs#47, not a placeholder.
- **Nothing complete is left out:** every folder under `skills/` is in the list (18 of 18). This session added no component. It changed the existing `triage` skill's scripts (`install-schedule.sh`, `run-scheduled.sh`, `publish-report.sh`), and `./skills/triage` is listed.

## Steps run

Source: the deploy declaration, `.claude/deploy.json`, word for word. All steps ran on the session branch `feat/93-triage-schedule-fixes`, and the plan came from `check-declaration.sh --plan` (exit 0, valid).

| # | Step | Kind | Command | Result |
|---|---|---|---|---|
| 1 | bump the version | routine | `bash .github/scripts/bump-version.sh patch` | Passed (exit 0): printed `2.4.1`. `.claude-plugin/plugin.json` went from 2.4.0 to 2.4.1 |
| 2 | commit the version bump | routine | `git add .claude-plugin/plugin.json && git commit -m "chore(release): v2.4.1 — #93"` | Passed (exit 0): commit `f2d6c62`, 1 file changed. `log.md` was left unstaged |
| 3 | push the session branch | routine | `git push -u origin feat/93-triage-schedule-fixes` | Passed (exit 0): `ea14700..f2d6c62`, and the branch now tracks `origin` |
| 4 | mark the PR ready | routine | `gh pr ready 94` | Passed (exit 0): "Pull request dkoenawan/compass-labs#94 is marked as "ready for review"" |

**Waiting for the user's instruction:**

- merge the pull request (production_affecting, merge): waiting for the user's instruction. The user merges PR 94, and then the pipeline tags and publishes the release. Deploy never merges.

**The user's steps after the merge:**

- update the local checkout: `git switch main && git pull`
- refresh the local plugin install: `claude plugin update compass-labs@compass-labs`
- restart Claude Code to load the new version: `exit Claude Code and start it again`

## Confirmation

The declared check is `bash .github/scripts/release-tag.sh --check`, run after steps 1 to 4:

```
release-tag: would create compass-labs--v2.4.1 for version 2.4.1 at f2d6c6287f568911b32d57ec56e62c32671b5488
```

Result: passed (exit 0). The bumped version is new, and a merge of the pushed head would create the tag `compass-labs--v2.4.1`.

## Rollback

From the declaration's `rollback`. It never runs automatically.

- **Before the merge:** run `gh pr ready 94 --undo`, then revert the version bump on the session branch (`git revert f2d6c62`, then `git push`). Deploy or the user runs these.
- **After the merge:** the user opens a revert pull request with a new version. Tags and releases are never overwritten.

## Change record

- **What changed:** fixes in the triage skill's scheduled run.
  - #93: the installer keeps symlinked `claude` and `gh` paths absolute and unresolved, so a `claude` version update no longer breaks the cron line (REQ-001, REQ-002, REQ-003).
  - #91: the headless run gets the local run date, and the publisher sets the header's `- Run date:` to the title's date (REQ-004, REQ-005).
  - The triage docs were updated to match, with one-off reinstall guidance for older schedules (REQ-006).
  - Requirements are in [`define/index.md`](define/index.md) and the evidence is in [`verification.md`](verification.md).
- **Version:** 2.4.0 to 2.4.1. **PATCH:** bug fixes and documentation updates, under the declared `versioning.rule` (CLAUDE.md, Version Management). No skill interface changed, and no skill was added.
- **Change type:** standard change. Every step that ran is routine and pre-authorised by the declaration.
- **Change authority:** the user at the Deploy gate. The user also owns the merge of PR 94.
