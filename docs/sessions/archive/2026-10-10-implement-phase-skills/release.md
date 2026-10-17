# Release: Implement phase — an as-built artifact, the backend API artifact and the testing boundary (#28)

> Phase: Deploy | Started: 2026-10-17 | Status: Draft
> Requirements: [`define/index.md`](define/index.md) · Design: [`design/index.md`](design/index.md) · Tasks: [`tasks.md`](tasks.md) · Verification: [`verification.md`](verification.md)

## Version / target

- **Version:** compass-labs **v2.1.0**, a MINOR bump from v2.0.0. The bump is in `.claude-plugin/plugin.json`, commit `9b7ff8e` (`chore: bump to v2.1.0 — #28`) on `feat/28-implement-phase-skills`. `.claude-plugin/marketplace.json` has no `version` field, so nothing there needs to match.
- **Why MINOR:** CLAUDE.md's rules say new skills or backward-compatible enhancements are MINOR, and breaking changes to skill interfaces are MAJOR. This release adds two skills, `implement` (DES-001) and `backend` (DES-004). It removes no skill and no invocation. Every existing `/compass-labs:*` entry point keeps its name and arguments. The behaviour changes are compatible with existing sessions:
  - Past sessions keep working. The root `tasks.md` and `design.md` are read as legacy layouts by the gates, Test, Close, `task-executor` and `find-active-plan.sh` (REQ-020, DES-011). VER rows check this: 699 comparisons against `4286ed9` on the archived sessions, 0 differing.
  - `task-executor` no longer writes construct files (REQ-018, DES-007/DES-008). That changes who does a write, not how the skill is called. Close now registers constructs.
  - New sessions write their plan to `implement/tasks.md` and not a root `tasks.md`. That is the new session schema, not a change to how any skill is called.
- **Tag:** `compass-labs--v2.1.0`, created on `main` after the squash-merge. `claude plugin tag --dry-run` confirms the name. `compass-labs--v2.0.0` already exists at `401094b` (current `main`).
- **Target:** the local-directory marketplace `compass-labs` (this repo, `.claude-plugin/marketplace.json`), installed as `compass-labs@compass-labs` at user scope.
- **What "deploy" means here:** releasing the plugin (`agents/deploy.md`, `Taskfile.yml` `release` target). There's no CI. As in the last three releases (`docs/sessions/archive/*/release.md`), the bump is done on the branch, and the tag and cache refresh are done on `main` after the squash-merge. `task release` isn't run as a whole for two reasons. It would tag a branch commit that the squash-merge throws away. And its `_bump-version` commit message doesn't carry the issue reference.

## What changed

Branch `feat/28-implement-phase-skills` compared with `main` (`401094b`): 39 files, about +1920/−215 before the bump. By design item:

- **Implement standard** `skills/implement/SKILL.md` (new skill; DES-001): covers REQ-001 to REQ-003, REQ-007, REQ-008, REQ-014 to REQ-016 and REQ-020.
- **Implement templates** `skills/session/templates/implement/tasks.md` and `as-built.md` (DES-002): covers REQ-001, REQ-002, REQ-012, REQ-015 and REQ-016.
- **Implement agent** `agents/implement.md` preloads `compass-labs:implement` and owns `implement/` (DES-003): covers REQ-001 and REQ-015.
- **Backend layer** `skills/backend/SKILL.md` and `reference/implement.md` (new skill; DES-004): covers REQ-007 and REQ-011 to REQ-014.
- **Implement gate** in `skills/session/SKILL.md` (DES-005): covers REQ-004, REQ-005 and REQ-020.
- **Close fold-back of `implement/`** in `skills/session/reference/close-foldback.md` (DES-006): covers REQ-006 and REQ-020.
- **`task-executor`** resolves `design/index.md` or `design.md` and writes no registry entries (DES-007): covers REQ-015, REQ-017 and REQ-018.
- **Construct registration and the validator trigger:** Close is the only registrar, and `post-hook-validator` runs by name (DES-008). Covers REQ-018 and REQ-019. A Test-phase fix (`0be7ff6`) reworded `init`'s injected protocol item 4 and `doc-maintainer` step 4 to match.
- **Test boundary** in `agents/test.md`, `skills/verification/SKILL.md` and `templates/verification.md` (DES-009): covers REQ-009, REQ-010 and REQ-020.
- **Harness tests**: new `implement_standard_test.sh` and `find_active_plan_test.sh`, plus extra assertions in existing tests (DES-010). Covers REQ-014, REQ-017, REQ-018 and REQ-020.
- **`implement/` folder artifact** in `feature.json`, with root `tasks.md` as its legacy file, plus `find-active-plan.sh` and `doc-maintainer` (DES-011): covers REQ-001, REQ-002 and REQ-020.
- **Registration:** `marketplace.json` and the README list `implement` and `backend`.

The user accepted these at the Test gate: REQ-001's "deviated" is recorded as "built with variation", and REQ-014 allows the marketplace and README listing as the one edit outside a layer's folder (`3d8630f`).

**Not in this release:** REQ-021 to REQ-026 are deferred to #57, #58, #59, #60, #50 and #61 (`define/requirements.md`). Follow-ups filed during the session: #64 and #65.

## Completeness

Checked on 2026-10-17 at `3cedd6d` (before the bump) against `.claude-plugin/marketplace.json` as it ships, and checked again by the test suite at `9b7ff8e`. `--plugin-dir` wasn't used, because it ignores the skill list.

- **Everything listed is complete.** `marketplace.json` lists 16 skills, and every one has a `SKILL.md` whose `name` frontmatter matches its folder and that has a real body (13 to 972 lines). The new components:
  - `skills/implement/SKILL.md`: 89 lines, the six-part standard.
  - `skills/backend/SKILL.md`: 13 lines. It is an index by design (DES-004), and it points to `reference/implement.md` (42 lines), which holds the guidance.
  - `skills/session/templates/implement/tasks.md` (23 lines) and `as-built.md` (39 lines).
  - Relative Markdown links in `skills/implement/` and `skills/backend/` all resolve.
- **Nothing is unfinished.** No file under `skills/`, `agents/` or `hooks/` is empty. A whole-word grep for `TODO`, `TBD` or `FIXME` across `skills/` and `hooks/` finds nothing, and the only hits in `agents/` are `deploy.md`'s own rule text and its #30 note. There is no `.gitkeep` under `skills/`. `hooks/.gitkeep` sits next to real scripts, so the folder isn't `.gitkeep`-only.
  - Noted, not a gap: `skills/backend/SKILL.md`'s index has a row for `reference/design.md` marked "Not written yet: #47". It isn't a link and no stub file exists. It records that the backend design standard is out of scope here and tracked in #47. Until then, Design covers the backend in its all-kinds sections, as the row says.
- **Nothing complete is left out.** `skills/` has exactly the 16 folders listed (`diff` of the manifest list against `ls skills/` is empty). Both skills this session added, `implement` and `backend`, are listed. `tests/session/marketplace_test.sh` checks the same thing and passes.
- **Agents:** all 7 exist in `agents/` (`orchestrator`, `define`, `design`, `implement`, `test`, `deploy`, `close`).
- **Hooks:** all three scripts that `hooks/hooks.json` references exist (`session-start.sh`, `session-guard.sh`, `session-commit-guard.sh`).
- **Tasks:** 12 of 12 in `tasks.md` are ticked, with frontmatter `status: complete`.

Result: **no gaps.**

## Deploy steps run

### Run by the deploy agent on `feat/28-implement-phase-skills` (done)

1. Ran the completeness check above. It found no gaps.
2. Ran `bash tests/run.sh` before the bump: **21 passed, 0 failed (of 21)**.
3. Bumped `.claude-plugin/plugin.json` `version` from 2.0.0 to 2.1.0. Committed it as `9b7ff8e` (`chore: bump to v2.1.0 — #28`).
4. Ran `bash tests/run.sh` after the bump: **21 passed, 0 failed (of 21)**.
5. Ran `claude plugin tag --dry-run`. It succeeded with Version `2.1.0 (from plugin.json)`, Marketplace entry `plugins[0]` and Tag `compass-labs--v2.1.0`. It gave the same 4 non-blocking warnings as v2.0.0: `CLAUDE.md` isn't loaded as plugin context (expected, it's repo guidance), and the 3 `hooks/hooks.json` commands use `$CLAUDE_PLUGIN_ROOT` without quotes.

### Pending: needs the user's go-ahead (outward-facing)

6. [ ] Push the branch: `git push origin feat/28-implement-phase-skills`. The remote is at `190877d`, so this pushes `3cedd6d`, the bump and this release note.
7. [ ] Open the PR: `gh pr create --base main --head feat/28-implement-phase-skills --title "feat: Implement phase standard, backend layer and testing boundary (v2.1.0) — #28"`. The body should link #28 and #52 without closing keywords, so that Close closes them, as in PRs #44 and #56.
8. [ ] Squash-merge the PR into `main`. This is the user's call.
9. [ ] `git checkout main && git pull`
10. [ ] `claude plugin tag --push`. This creates and pushes `compass-labs--v2.1.0` at the squash commit on `main`.
11. [ ] `claude plugin update compass-labs@compass-labs` to refresh the plugin cache. Then restart Claude.

## How it was confirmed working

Checked before the merge:

- The completeness check (no gaps).
- The full test suite: 21 of 21 pass at `3cedd6d` and again at `9b7ff8e`.
- The tag dry run.
- `verification.md`: 24 VER rows, every REQ-001 to REQ-020 has a passing Test-owned check, and `check-traceability.sh` is ok.

Still to check after steps 8 to 11:

- [ ] `claude plugin list` shows `compass-labs@compass-labs` at **Version: 2.1.0** and enabled, with `main` checked out. For this local-directory marketplace the version is read from the working tree, so this check alone doesn't prove the release is installed.
- [ ] The installed plugin cache under `~/.claude/plugins/` for `compass-labs@compass-labs` contains `skills/implement/SKILL.md`, `skills/backend/reference/implement.md` and `skills/session/templates/implement/as-built.md`. This proves both new skills shipped through the marketplace install, not only through `--plugin-dir`.
- [ ] `git ls-remote --tags origin compass-labs--v2.1.0` resolves to the squash commit on `main`.

## Rollback

- **Before the merge:** don't open the PR, or close it without merging. Nothing is tagged yet. To drop the bump locally, run `git revert 9b7ff8e` on the branch.
- **Pin back to v2.0.0:** run `task lock PIN=compass-labs--v2.0.0`, which also refreshes the cache, then restart Claude. Unpin later with `task lock UNPIN=true`.
- **Remove the tag:** `git tag -d compass-labs--v2.1.0 && git push origin :refs/tags/compass-labs--v2.1.0`.
- **Revert the release on `main`:** run `git revert <squash-commit-sha>` in a PR, then `claude plugin update compass-labs@compass-labs`. Sessions started under v2.1.0 keep their plan in `implement/tasks.md`, and v2.0.0's `feature.json` doesn't know that folder. Finish or archive those sessions before reverting.
