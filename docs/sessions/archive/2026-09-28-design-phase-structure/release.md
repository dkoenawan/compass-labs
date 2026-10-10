# Release: Design phase structure, with layered design skills and visual deltas (#27, #39)

> Phase: Deploy | Started: 2026-10-04 | Status: Draft
> Requirements: [`define/index.md`](define/index.md) · Design: [`design.md`](design.md) · Tasks: [`tasks.md`](tasks.md) · Verification: [`verification.md`](verification.md)

## Version / target

- **Version:** compass-labs **v2.0.0**. This is a MAJOR bump because retiring `plan` (DES-015, REQ-021, REQ-022) breaks anyone who invoked `/compass:plan`. The breaking change is commit `1c00284` (`feat(plan)!: retire the plan skill into Design and repoint its callers — #27`) and task 18 in `tasks.md`. The version went from 1.2.0 to 2.0.0 in `.claude-plugin/plugin.json` in commit `657c835` (`chore: bump to v2.0.0 — #27`) on `feat/27-design-phase-structure`. `.claude-plugin/marketplace.json` has no `version` field, so there was nothing to keep in step there.
- **PR:** [#56](https://github.com/dkoenawan/compass-labs/pull/56), `feat/27-design-phase-structure` → `main`. It's open and not merged. Merging is the user's call.
- **Tag:** `compass-labs--v2.0.0`, to be created on `main` after the squash-merge.
- **Target:** the local-directory marketplace `compass-labs` (this repo, `.claude-plugin/marketplace.json`), installed as `compass-labs@compass-labs` at user scope.
- For this repo, "deploy" means releasing the plugin (`agents/deploy.md`, `Taskfile.yml` `release` target). There's no CI. Merges are squash-only, so this follows the split used in the last two releases (`docs/sessions/archive/2026-09-25-define-phase-depth/release.md` and `docs/sessions/archive/2026-08-19-session-lifecycle/release.md`). The bump happens on the branch, and the tag and cache refresh happen on `main` after the merge. `task release` isn't run as a whole. It would tag the branch commit that the squash-merge throws away, and its `_bump-version` commit message doesn't carry the issue reference.

## What changed

Branch `feat/27-design-phase-structure` compared with `main` (`db34939`), bump included: 40 commits, 55 files, roughly +2800/−1230. The changes by design area:

- **Design standard** (`skills/design/SKILL.md`; DES-001, DES-002, DES-003, DES-006, DES-012, DES-013). Covers the procedure (prior knowledge → primary kind and scope checklist → in-depth path or all-kinds sections → visuals and delta → principles check), the prior-knowledge rule, the kind catalogue and kind contract, significant choices and the principles check, the Design → Implement handoff contract with `Depends on`, and the Claude Design handoff. Covers REQ-001, REQ-002, REQ-003, REQ-007, REQ-018, REQ-019, REQ-020, REQ-032, REQ-033, REQ-035 to REQ-038.
- **Three-tier in-depth path and layer contract** (`skills/design/kinds/three-tier.md`; DES-004, DES-005). Covers REQ-004 to REQ-007 and REQ-032.
- **Stack defaults** (`skills/design/reference/stack-defaults.md`, linked from `init`, `bootstrap-new-project` and the README; DES-007). Covers REQ-008 to REQ-010.
- **Notations and delta styling** (`skills/design/reference/notations.md`; DES-008). Covers REQ-011 to REQ-015.
- **`design/` folder artifact** (templates in `skills/session/templates/design/`, and `feature.json` with `legacy_artifact: design.md` so past sessions keep working; DES-009, DES-010). Covers REQ-011, REQ-012, REQ-024, REQ-036 and REQ-037.
- **Design gate a4 and `check-design.sh`** (`skills/session/SKILL.md`, `skills/session/scripts/check-design.sh`; DES-011). Covers REQ-016, REQ-017 and REQ-024.
- **Design agent** (`agents/design.md` preloads `compass-labs:design`, with a scoped Bash rule; DES-014). Covers REQ-015, REQ-021 and REQ-035. `agents/implement.md` now reads `design/index.md` (DES-012).
- **Close reads `design/`** (`skills/session/reference/close-foldback.md`; DES-017). Covers REQ-024 and REQ-035.
- **`plan` retired (breaking)** (DES-015). `skills/plan/` is deleted and its marketplace entry is replaced by `./skills/design`. `task-executor`, `init`, `bootstrap-new-project` and `explore` now point to `/compass-labs:session`. Covers REQ-021 and REQ-022. A Test-phase fix (`39dcc7a`) removed the remaining live mentions of `plan` from `doc-maintainer` and `docs/explanation/explore/overview.md`.
- **Documentation** (README, `docs/reference/session/workflow-and-artifacts.md`, `docs/explanation/session/overview.md`, `docs/explanation/solution-design.md`; `docs/explanation/plan/overview.md` removed; DES-016). Covers REQ-023.

**Not in this release:** REQ-025 to REQ-031 and REQ-034 are deferred (`define/requirements.md`).

Follow-ups tracked separately: #41, #46, #47, #48, #49, #50, #51, #52, #53, #54, #55.

## Completeness

Checked on 2026-10-04 at `53192ee` (before the bump) against `.claude-plugin/marketplace.json` as it ships, then rechecked by the test suite at `657c835`. I didn't rely on `--plugin-dir`, which ignores the skill list.

- **`plan` is gone.** `skills/plan/` doesn't exist and `marketplace.json` doesn't list it. A grep of `skills/`, `agents/`, `.claude-plugin/` and `hooks/` for `compass:plan`, `compass-labs:plan` or `skills/plan` finds nothing. The only remaining `plan` words in `skills/` are `task-executor`'s own `plan <issue-number>` subcommand, which isn't the retired skill.
- **Everything listed is complete.** All 14 listed skills (`adr`, `bootstrap-new-project`, `brand-designer`, `design`, `doc-maintainer`, `explore`, `framing`, `init`, `post-hook-validator`, `problem-statement`, `requirements`, `session`, `task-executor`, `verification`) have a `SKILL.md` whose `name` frontmatter matches the folder and that has a real body (29 to 972 lines). The `design` skill and its new files all have real content:
  - `skills/design/`: `SKILL.md` (181 lines), `reference/notations.md` (194), `reference/stack-defaults.md` (34) and `kinds/three-tier.md` (117).
  - `skills/session/templates/design/`: `index.md` (106), `solution.md` (55) and `ui-handoff.md` (30).
  - `skills/session/scripts/check-design.sh` exists.

  A grep for `TODO` or `TBD` across `skills/`, `agents/` and `hooks/` finds only `agents/deploy.md`'s own rule text and #30 note, and the substring `TBD` inside "JTBD" in `skills/problem-statement/reference/methods.md`. None of these is an unfinished body. `agents/design.md`'s #27 TODO is gone. No skill file is empty and there's no `.gitkeep` under `skills/`. Relative Markdown links in `skills/design/`, `skills/session/templates/design/` and `agents/design.md` resolve, except for paths that are meant to be relative to a session folder: layer files (`frontend.md`, `backend.md`, `database.md`) and `../assets/…` in the templates, and the `order-approval` example in `notations.md`. Those are written per session, not shipped.
- **Everything complete is listed.** `skills/` contains exactly the 14 directories listed (a `diff` of the list against `ls skills/` shows no difference). The new `design` skill is listed. `tests/session/marketplace_test.sh` checks the same thing, plus the check that nothing invokes `plan`, and passes.
- **Agents.** All 7 are present in `agents/`: `orchestrator`, `define`, `design`, `implement`, `test`, `deploy`, `close`.
- **Hooks.** All three scripts that `hooks/hooks.json` references exist: `session-start.sh`, `session-guard.sh` and `session-commit-guard.sh`.
- **Tasks.** All 23 tasks in `tasks.md` are ticked, and the frontmatter says `status: complete`.

Result: **no gaps.**

## Deploy steps run

### Run by the deploy agent on `feat/27-design-phase-structure` (done)

1. Ran the completeness check above. It found no gaps.
2. Bumped `.claude-plugin/plugin.json` `version` from 1.2.0 to 2.0.0 and committed it as `657c835` (`chore: bump to v2.0.0 — #27`).
3. `bash tests/run.sh` after the bump: **19 passed, 0 failed (of 19)**.
4. `claude plugin tag --dry-run` succeeded. It reported Plugin `compass-labs`, Version `2.0.0 (from plugin.json)`, Marketplace entry `plugins[0]`, and Tag `compass-labs--v2.0.0`, and said it would create the tag at HEAD. It gave the same 4 non-blocking warnings as v1.2.0:
   - `CLAUDE.md` isn't loaded as plugin context. That's expected, since it's repo guidance.
   - The 3 `hooks/hooks.json` commands use `$CLAUDE_PLUGIN_ROOT` without quotes.
5. Pushed the branch to `origin`. That includes `53192ee` and `657c835`.
6. Opened PR [#56](https://github.com/dkoenawan/compass-labs/pull/56) to `main` with `gh pr create`. It isn't merged. The body links #27 and #39 without closing keywords, so Close closes them, as in PR #44.

### Pending: to be run by the orchestrator or user after the merge

7. [ ] Squash-merge PR #56 into `main`. This is the user's call.
8. [ ] `git checkout main && git pull`
9. [ ] `claude plugin tag --push`, which creates and pushes `compass-labs--v2.0.0` at the squash commit on `main`.
10. [ ] `claude plugin update compass-labs@compass-labs` to refresh the plugin cache.
11. [ ] Confirm the release (see below), then restart Claude to activate it.

## How it was confirmed working

Already checked before the merge: the completeness check, the full test suite (19/19 at `657c835`), the tag dry run, and `verification.md` (32 VER rows, all pass).

Note: `claude plugin list` already shows `compass-labs@compass-labs` at Version 2.0.0, "Read from: /home/su-sentinel/private/compass-labs". For this local-directory marketplace it reads the version from the working tree, which is on the branch. So it doesn't prove the release is installed. The cache check below is the one that counts.

The orchestrator or user still needs to check these after steps 7 to 10:

- [ ] `claude plugin list` shows `compass-labs@compass-labs` at **Version: 2.0.0**, enabled, with `main` checked out.
- [ ] The installed plugin cache under `~/.claude/plugins/` for `compass-labs@compass-labs` contains `skills/design/SKILL.md`, `skills/design/reference/notations.md` and `skills/session/templates/design/index.md`, and has **no** `skills/plan/`. That shows the change shipped through the marketplace install and not only through `--plugin-dir`.
- [ ] `git ls-remote --tags origin compass-labs--v2.0.0` resolves to the squash commit on `main`.

## Rollback

- **Before the merge:** close PR #56 without merging. Nothing has been tagged yet.
- **Pin back to v1.2.0:** `task lock PIN=compass-labs--v1.2.0`, which also refreshes the cache and brings `/compass:plan` back. Then restart Claude. Unpin later with `task lock UNPIN=true`.
- **Remove the tag:** `git tag -d compass-labs--v2.0.0 && git push origin :refs/tags/compass-labs--v2.0.0`.
- **Revert the release on `main`:** `git revert <squash-commit-sha>` in a PR, then `claude plugin update compass-labs@compass-labs`. Sessions started under v2.0.0 have a `design/` folder, which v1.2.0's `feature.json` doesn't know about. Finish or archive them before reverting.
