<!-- The release record, written by the Deploy agent from the Deploy standard (skills/deploy/SKILL.md). The Deploy tier line sets which sections are required (the standard's tier table); the Deploy gate's check-release.sh refuses a record missing one. Delete a section only if the confirmed tier doesn't require it. A record with no Deploy tier line is a past record and gets no check. -->
# Release: Deploy phase depth

> Phase: Deploy | Started: 2026-11-14 | Status: Draft
> Deploy tier: short: routine plugin release, no production-affecting step (every step run is routine and pre-authorised by the declaration; the merge is the user's and doesn't count)
> Requirements: [`define/index.md`](define/index.md) · Verification: [`verification.md`](verification.md) · Declaration: `.claude/deploy.json`

The session's framing tier (full) plays no part in this tier (REQ-025). `check-declaration.sh --plan` gave "tier: short" and "tier if L1 runs: short".

## Lifecycles run and why

- **Declaration:** `bash skills/deploy/scripts/check-declaration.sh {repo} --plan` reported `check-declaration: valid` (exit 0), release mode `in_session`.
- **L1:** needed. Read from the frozen design's [delta list](design/index.md#delta-list):
  - `.github/workflows/release.yml`, `.github/scripts/release-tag.sh` (this repo): **new**, DES-016, marked as the deployable part. It is the declared part `merge-triggered pipeline` in `l1.parts`, so its declared setup runs (L1 rule 3).
  - `.claude/deploy.json` (this repo): new, DES-011. The declaration itself, not a deployable part.
  - `.github/scripts/bump-version.sh`: new, DES-010. A declared L2 step's script, not a deployable part.
  - Every other `new` or `changed` row (`skills/deploy/`, `check-declaration.sh`, `install-starter.sh`, the starter templates, `check-release.sh`, `release.md` template, `agents/deploy.md`, the phase-agent contract, `skills/session/SKILL.md`, `skills/init/SKILL.md`, `marketplace.json`/`README.md`, `Taskfile.yml` `check-upgrade`, tests and fixtures, the Deploy phase process): plugin content shipped by L2, not a C4 container, service or deployed resource. "Repo's copy of the starter (in a consuming repo)" is new but lives in other repos, not this one.
  - `.claude-plugin/plugin.json`: unchanged in the design; bumped by L2 step 1.
- **Added to the declaration at this Deploy (REQ-027):** none. The declaration already covers the only deployable part, so no offer was made and no question was asked.
- **L1 setup run:** `merge-triggered pipeline`, step 1 "show that the pull-request run of release.yml on the branch passed" (routine, read-only): `gh run list --workflow release.yml --branch feat/30-deploy-phase-depth --limit 1` returned `completed	success	feat: Deploy phase depth — #30	release	feat/30-deploy-phase-depth	pull_request	43565893739	7s	2026-11-14T06:20:57Z`. Passed. After the push in L2, the next pull-request run (43566019362, on the bump commit) also passed (see Confirmation).
- **L2:** release run in this session, after L1: the four routine steps ran; the merge waits for the user.

## Release strategy

Tagged release (`l2.strategy`). The merge into `main` triggers `.github/workflows/release.yml`, which creates `compass-labs--v{version}` on the merge commit and publishes the release.

## Completeness

Checked the release manifest as it ships, `.claude-plugin/marketplace.json` (`strict: true`, so its `skills` list is what a marketplace install loads), not as `claude --plugin-dir` loads it.

- **Every listed component exists and is complete.** All 17 entries in `plugins[0].skills` resolve to a folder with a `SKILL.md` whose `name:` matches the folder, and none has an empty, stub or TODO body. A search for `TODO`, `TBD` and `FIXME` in `skills/`, `agents/`, `hooks/`, `commands/`, `.github/` and `.claude-plugin/` found only text that describes the completeness rule (the release template and `agents/deploy.md`) and a method name in `skills/problem-statement/reference/methods.md`, none a placeholder. `skills/backend/` is a short but complete index released in v2.1.0; its unwritten `reference/design.md` is tracked in #47 and isn't listed as a file it ships. This session's new skill, `skills/deploy/` (`SKILL.md`, `reference/declaration.md`, `reference/frameworks.md`, `scripts/check-declaration.sh`, `scripts/install-starter.sh`, `scripts/lib/*.jq`, `templates/github/release.yml`, `templates/github/release-tag.sh`), has every file present and non-empty.
- **Nothing complete is left out.** The 17 folders under `skills/` match the 17 listed entries one to one. The skill this session added, `./skills/deploy`, is listed (the `marketplace.json` row in the delta list). Agents (`agents/*.md`, including the changed `deploy.md`), hooks (`hooks/hooks.json`) and commands load from the plugin root by convention and aren't listed in the manifest. `hooks/.gitkeep` and `commands/.gitkeep` sit beside real content, not alone.
- `claude plugin validate .` reported "Validation passed with warnings".

Result: complete. No gap.

## Steps run

Source: the deploy declaration, `.claude/deploy.json`, word for word, in declared order, on `feat/30-deploy-phase-depth`.

| # | Step | Kind | Command | Result |
|---|---|---|---|---|
| L1.1 | show that the pull-request run of release.yml on the branch passed | routine | `gh run list --workflow release.yml --branch feat/30-deploy-phase-depth --limit 1` | Passed: run 43565893739, `pull_request`, `success` |
| L2.1 | bump the version | routine | `bash .github/scripts/bump-version.sh minor` | Printed `2.3.0`; `plugin.json` `2.2.1` to `2.3.0`, only the version line changed |
| L2.2 | commit the version bump | routine | `git add .claude-plugin/plugin.json && git commit -m "chore(release): v2.3.0 — #30"` | Commit `ac29eb5`, one file, staged by name |
| L2.3 | push the session branch | routine | `git push -u origin feat/30-deploy-phase-depth` | `f9edbd9..ac29eb5  feat/30-deploy-phase-depth -> feat/30-deploy-phase-depth` |
| L2.4 | mark the PR ready | routine | `gh pr ready 77` | `Pull request dkoenawan/compass-labs#77 is marked as "ready for review"` |

**Waiting for the user's instruction:**

- merge the pull request: waiting for the user's instruction (production-affecting, `merge: true`; the merge is always the user's). PR #77 is open, not a draft, and `MERGEABLE`. Nothing was pushed to `main`.

**The user's steps after the merge:**

- update the local checkout: `git switch main && git pull`
- refresh the local plugin install: `claude plugin update compass-labs@compass-labs`
- restart Claude Code to load the new version: exit Claude Code and start it again

The tag and the published release are made by the pipeline on the merge, not by the user.

## Confirmation

Declared check (`confirmation.run`): `bash .github/scripts/release-tag.sh --check`, run on the branch head after L2.4.

```
release-tag: would create compass-labs--v2.3.0 for version 2.3.0 at ac29eb5c7eaf06e448f6ed9a9d61b2364a4e05df
```

Exit 0. **Passed.**

The pull-request run of `release.yml` on the pushed bump commit (run 43566019362, event `pull_request`, head `ac29eb5`) completed with `success`; its "Check the release tag" step printed `release-tag: would create compass-labs--v2.3.0 for version 2.3.0 at 45afda0fb1fa4f8321ac3f9f8fc1ee7ac1bff257` (the PR's merge ref). `git ls-remote --tags origin` shows no `compass-labs--v2.3.0` tag; the latest is `compass-labs--v2.2.1`.

## Rollback

From the declaration's `rollback`. Never run automatically.

1. **Before the merge:** `gh pr ready 77 --undo`, then revert the version bump on the session branch (`git revert ac29eb5`, `git push`). Run by Deploy or the user.
2. **After the merge:** open a revert pull request with a new version. Run by the user. Tags and releases are never overwritten.

## Change record

- **What changed:** the Deploy standard and its declaration contract, tiers and frameworks (REQ-001, REQ-014, REQ-016); the Deploy phase reading the declaration, stopping on a missing or invalid one, running routine steps, holding production-affecting ones, confirming and recording rollback (REQ-002 to REQ-013, REQ-017, REQ-025, REQ-027); the Deploy gate's section check (REQ-015); compass-labs' own declaration and merge-triggered pipeline (REQ-018 to REQ-024); the declaration offer at initiation and the optional GitHub starter (REQ-026, REQ-028).
- **Version:** `2.2.1` to `2.3.0`. **MINOR: a new skill** (`skills/deploy/`), with backward-compatible enhancements to the session, init and Deploy agent, by the declared `versioning.rule` (`CLAUDE.md`, Version Management). Tag on merge: `compass-labs--v2.3.0`.
- **Change type:** standard change (ITIL 4): every step run is routine and pre-authorised by the declaration. The merge is production-affecting and the user's.
- **Change authority:** the user, at the Deploy gate (confirms the tier and approves the milestone), and then by merging PR #77.
