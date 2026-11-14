<!-- The release record, written by the Deploy agent from the Deploy standard (skills/deploy/SKILL.md). The Deploy tier line sets which sections are required (the standard's tier table); the Deploy gate's check-release.sh refuses a record missing one. Delete a section only if the confirmed tier doesn't require it. A record with no Deploy tier line is a past record and gets no check. -->
# Release: Triage skill

> Phase: Deploy | Started: 2026-11-14 | Status: Draft
> Deploy tier: short: every step that ran is routine and pre-authorised by the declaration (a routine plugin version bump); the merge is the user's and doesn't count
> Requirements: [`define/index.md`](define/index.md) · Verification: [`verification.md`](verification.md) · Declaration: `.claude/deploy.json`

## Lifecycles run and why

- **L1:** not needed, no deployable part changed. The only declared part is `merge-triggered pipeline` (`.github/workflows/release.yml`, `.github/scripts/release-tag.sh`), and no delta row touches it (`git diff origin/main...HEAD -- .github .claude` is empty). Delta rows read from [`design/index.md`](design/index.md#delta-list):
  - `new`: `skills/triage/SKILL.md`, `skills/triage/reference/stock-take.md`, `skills/triage/scripts/{gather,publish-report,run-scheduled,install-schedule,uninstall-schedule,ensure-label}.sh`, `tests/triage/`. These are plugin content that ships through the release itself, not deployable parts.
  - `new`: local run log under `${XDG_STATE_HOME:-$HOME/.local/state}/compass-labs/triage/{repo-slug}/`. Created on each user's machine at run time, not deployed by the repo.
  - `changed`: `README.md` (skill entry) and `.claude-plugin/marketplace.json` (adds `./skills/triage`). Release content, checked under Completeness.
  - `changed`: maintainer's crontab. A per-user cron entry that each user installs through the skill's install mode; it isn't a deployable part of this repo, so it isn't offered for `l1.parts`. The maintainer's own schedule is installed after Deploy (see the user's steps after the merge).
  - `unchanged`: other cron jobs, GitHub via `gh`, `claude` CLI, repository working tree, `skills/doc-maintainer/`, `skills/task-executor/`, `tests/lib.sh`, `.claude-plugin/plugin.json` (bumped by Deploy's L2 step below).
- **Added to the declaration at this Deploy (REQ-027):** none
- **L1 setup run:** none
- **L2:** release run in this session (`release_mode: in_session`), up to the merge, which waits for the user.

## Release strategy

Tagged release (`l2.strategy`). Merging PR #87 into `main` lets the merge-triggered pipeline create tag `compass-labs--v2.4.0` and publish the release.

## Completeness

The release manifest checked as it ships: `.claude-plugin/marketplace.json`'s `plugins[0].skills` list (what a marketplace install loads; `claude --plugin-dir` ignores it, so it wasn't used as proof). Checked on the session branch at `1918c84`:

- **Every listed component exists and is complete.** All 18 listed folders have a non-empty `SKILL.md` whose `name` matches the folder. `./skills/triage` is listed and holds `SKILL.md` (87 lines), `reference/stock-take.md` and the seven scripts the delta list names; a search of `skills/triage` for TODO, FIXME, TBD, placeholder or stub found nothing, and no `.gitkeep` exists under `skills/`. (`skills/backend` names its not-yet-written `reference/design.md` as tracked in #47; that predates this session and its listed `reference/implement.md` exists.)
- **Nothing complete is left out.** Every folder under `skills/` is in the list; the one skill this session added, `skills/triage`, is listed.

Result: complete.

## Steps run

Source: the deploy declaration, `.claude/deploy.json`, word for word. Branch `feat/86-triage-skill`; level `minor`; version `2.4.0`; issue `86`; PR `87`.

| # | Step | Kind | Command | Result |
|---|---|---|---|---|
| 1 | bump the version | routine | `bash .github/scripts/bump-version.sh minor` | `2.4.0`: `.claude-plugin/plugin.json` version 2.3.0 → 2.4.0, only that line changed |
| 2 | commit the version bump | routine | `git add .claude-plugin/plugin.json && git commit -m "chore(release): v2.4.0 — #86"` | Commit `1918c84` |
| 3 | push the session branch | routine | `git push -u origin feat/86-triage-skill` | `5f54f36..1918c84` pushed to `origin/feat/86-triage-skill` |
| 4 | mark the PR ready | routine | `gh pr ready 87` | PR #87 marked "ready for review" |

**Waiting for the user's instruction:**

- merge the pull request: waiting for the user's instruction (the user merges PR #87; the pipeline then tags and publishes). Deploy never merges.

**The user's steps after the merge:**

- update the local checkout: `git switch main && git pull`
- refresh the local plugin install: `claude plugin update compass-labs@compass-labs`
- restart Claude Code to load the new version: exit Claude Code and start it again
- Not a declared step: the maintainer's own weekly triage schedule (Saturday 01:00 Pacific/Auckland) is installed by the orchestrator after Deploy through the skill's install mode (`/compass-labs:triage install`, which runs `skills/triage/scripts/install-schedule.sh`). It's a per-user cron entry, not a deployable part.

**Follow-ups from Test:** #90, #91 and #92. #92 matters operationally: this machine's `claude` sign-in expires between 2026-11-18 and 2026-11-21, before the first scheduled run (Saturday 2026-11-21 01:00 Pacific/Auckland). Unless the sign-in is renewed before then, the first scheduled triage run won't authenticate.

## Confirmation

Declared check: `bash .github/scripts/release-tag.sh --check`, run after steps 1 to 4.

```
release-tag: would create compass-labs--v2.4.0 for version 2.4.0 at 1918c84db47f1c230a86441fbeabe913173061eb
```

Exit 0. **Passed:** the merge will create the new tag `compass-labs--v2.4.0` (the latest existing tag is `compass-labs--v2.3.0`).

## Rollback

From the declaration's `rollback`, never run automatically:

- **Before the merge** (Deploy or the user): `gh pr ready 87 --undo`, then revert the version bump on the session branch (`git revert 1918c84`, `git push`).
- **After the merge** (the user): open a revert pull request with a new version. Tags and releases are never overwritten.

## Change record

- **What changed:** a new skill, `compass-labs:triage` (`skills/triage/`, DES-001 to DES-009), covering REQ-001 to REQ-030 per [`define/index.md`](define/index.md); its tests under `tests/triage/`; its README section and its `marketplace.json` entry.
- **Version:** 2.3.0 → 2.4.0. **MINOR: a new skill**, per the declared `versioning.rule` (CLAUDE.md, Version Management: MINOR for new skills or backward-compatible enhancements). No existing skill interface changed.
- **Change type:** standard change (ITIL 4): every step run was routine and pre-authorised by the declaration.
- **Change authority:** the user at the Deploy gate, and the user's own merge of PR #87.
