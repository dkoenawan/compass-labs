# Release: Define phase depth — problem framing, per-type standards, project anchoring (#23)

> Phase: Deploy | Started: 2026-09-27 | Status: Draft
> Requirements: [`requirements.md`](requirements.md) (root layout, D6) · Verification: [`verification.md`](verification.md)

## Version / target

- **Version:** compass-labs **v1.2.0**. This is a MINOR bump because it adds the `framing` and `problem-statement` skills and restructures `requirements` without breaking compatibility: past sessions keep their root `requirements.md`, and the tools still read it (DES-019, DES-020). The version went from 1.1.0 to 1.2.0 in `.claude-plugin/plugin.json` in commit `95dbe79` (`chore: bump to v1.2.0 — #23`) on `feat/23-define-phase-depth`. `.claude-plugin/marketplace.json` has no `version` field, so there was nothing to keep in step there.
- **PR:** [#44](https://github.com/dkoenawan/compass-labs/pull/44), `feat/23-define-phase-depth` → `main`. It's open and not merged. Merging is the user's call.
- **Tag:** `compass-labs--v1.2.0`, to be created on `main` after the squash-merge.
- **Target:** the local-directory marketplace `compass-labs` (this repo, `.claude-plugin/marketplace.json`), installed as `compass-labs@compass-labs` at user scope. The installed version is currently 1.1.0.
- For this repo, "deploy" means releasing the plugin (`agents/deploy.md`, `Taskfile.yml` `release` target). There's no CI (`.github/` doesn't exist). Merges are squash-only, so this follows the split used in the last release (`docs/sessions/archive/2026-08-19-session-lifecycle/release.md`). The bump happens on the branch, and the tag and cache refresh happen on `main` after the merge. `task release` isn't run as a whole. It would tag the branch commit that the squash-merge throws away, and its `_bump-version` commit message doesn't carry the issue reference.

## What changed

Branch `feat/23-define-phase-depth` compared with `main` (`912634c`): 60 commits, 52 files, +3494/−165. The changes by design area:

- **Framing step** (`skills/framing/SKILL.md`, DES-001 to DES-005). A procedure that doesn't depend on the phase. It runs a depth tier proposal, the XY and symptom/cause checks, the anchor locate/assess/verdict checks and a registry/ADR overlap check. Covers REQ-001 to REQ-006, REQ-010, REQ-013, REQ-020 to REQ-022.
- **Anchor contract** (`skills/framing/reference/anchor-contract.md`, DES-006). Covers REQ-018, REQ-019.
- **Workflow `framing` block and the `define/` folder artifact** (`feature.json`, `skills/session/templates/define/` with six templates, `hooks/session-guard.sh`; DES-007, DES-008, DES-020). Covers REQ-001 to REQ-006, REQ-009, REQ-010, REQ-013, REQ-032, REQ-033, REQ-035, REQ-039 to REQ-042.
- **Orchestrator anchor write and Define gate check a3, and the Define agent** (`skills/session/SKILL.md`, `agents/define.md`; DES-009, DES-010). Covers REQ-001, REQ-007, REQ-008, REQ-011, REQ-020, REQ-021.
- **Per-type standards** (`skills/problem-statement/`, the restructured `skills/requirements/`, and both `reference/methods.md` files; DES-011 to DES-013). Covers REQ-005, REQ-007 to REQ-009, REQ-014, REQ-015, REQ-023 to REQ-037, REQ-046.
- **Diagram catalogue and worked example** (`skills/requirements/reference/diagrams.md`, `skills/requirements/examples/feature-full/`; DES-017, DES-018). Covers REQ-038 to REQ-045.
- **Traceability and path ripple** (`check-traceability.sh` reads `define/` first and falls back to the root file; agents, templates and `skills/verification` now point at `define/`; the old root `requirements.md` template is removed; DES-019, DES-021). Covers REQ-009.
- **Close fold-back of `define/`** (`skills/session/reference/close-foldback.md`, DES-023).
- **README anchor and refresh, solution design refresh, ADR-003** (DES-014 to DES-016). Covers REQ-001, REQ-016 to REQ-019. The plugin and marketplace descriptions and CLAUDE.md's Repository Purpose now match the anchor (a deviation recorded in `tasks.md`).
- **Test-phase fix** to the worked example and the Good examples in the standard (REQ-025, REQ-038, REQ-040), recorded in `log.md` as the decision "fix the worked-example gaps found in Test".

**Not in this release:** task 21 (DES-022), the as-built session docs that describe the `define/` folder. It's deferred to Close, where the doc-maintainer pass handles it.

Follow-ups tracked separately: #37, #38, #39, #40, #41, #42, #43.

## Completeness

Checked on 2026-09-27 at `95dbe79`, against `.claude-plugin/marketplace.json` as it ships. I didn't rely on `--plugin-dir`, which ignores the skill list.

- **Everything listed is complete.** All 14 listed skills (`adr`, `bootstrap-new-project`, `brand-designer`, `doc-maintainer`, `explore`, `framing`, `init`, `plan`, `post-hook-validator`, `problem-statement`, `requirements`, `session`, `task-executor`, `verification`) have a `SKILL.md` with `name` frontmatter matching the folder and a real body (29 to 972 lines). This session's new and changed skill files all have real content:
  - `framing`: `SKILL.md` (114 lines) and `reference/anchor-contract.md` (53 lines).
  - `problem-statement`: `SKILL.md` (29), `types/feature.md` (112), `types/bugfix.md` (33) and `reference/methods.md` (36).
  - `requirements`: `SKILL.md` (65), `types/feature.md` (141), `types/bugfix.md` (21), `reference/methods.md` (42), `reference/diagrams.md` (237), and six files in `examples/feature-full/` (28 to 129 lines).
  - The six `skills/session/templates/define/` templates (22 to 51 lines).

  A grep for `TODO` or `TBD` across `skills/`, `agents/` and `hooks/` finds only `agents/design.md`'s note about #27 and `agents/deploy.md`'s own rule text. Neither is an unfinished body. Relative Markdown links in the new and changed skills and in `agents/define.md` all resolve. The only unresolved path mentions are `workflows/research.json` and `types/research.md` in `framing/SKILL.md` l.107. They're a hypothetical example ("A Research session type would add…", #25), not a reference to something that's supposed to ship.
- **Everything complete is listed.** `skills/` contains exactly the 14 directories listed (a `diff` of the list against `ls skills/` shows no difference). The new `framing` and `problem-statement` are both listed. `tests/session/marketplace_test.sh` checks the same thing and passes.
- **Agents.** All 7 are present in `agents/`: `orchestrator`, `define`, `design`, `implement`, `test`, `deploy`, `close`.
- **Hooks.** All three scripts that `hooks/hooks.json` references exist: `session-start.sh`, `session-guard.sh` and `session-commit-guard.sh`.
- **Leftover files.** `commands/.gitkeep` and `hooks/.gitkeep` are still there, but both folders have real content, so they aren't gaps.
- **Tasks.** Tasks 1 to 20 in `tasks.md` are all ticked and ship complete. Task 21 (DES-022) is explicitly deferred to Close and isn't part of this release. It's documentation that the doc-maintainer pass writes, not a component in the manifest, so leaving it out leaves no stub or gap in what ships.

Result: **no gaps.**

## Deploy steps run

### Run by the deploy agent on `feat/23-define-phase-depth` (done)

1. Ran the completeness check above. It found no gaps.
2. Bumped `.claude-plugin/plugin.json` `version` from 1.1.0 to 1.2.0 and committed it as `95dbe79` (`chore: bump to v1.2.0 — #23`).
3. `bash tests/run.sh` after the bump: **15 passed, 0 failed (of 15)**.
4. `claude plugin tag --dry-run` succeeded. It reported Plugin `compass-labs`, Version `1.2.0 (from plugin.json)`, Marketplace entry `plugins[0]`, and Tag `compass-labs--v1.2.0`, and said it would create the tag at HEAD. It gave 4 warnings that don't block the release, the same ones as v1.1.0:
   - `CLAUDE.md` isn't loaded as plugin context. That's expected, since it's repo guidance.
   - The 3 `hooks/hooks.json` commands use `$CLAUDE_PLUGIN_ROOT` without quotes.
5. Pushed the branch to `origin`.
6. Opened PR [#44](https://github.com/dkoenawan/compass-labs/pull/44) to `main` with `gh pr create`. It isn't merged.

### To be run by the orchestrator or user after the merge

7. [ ] Squash-merge PR #44 into `main`. This is the user's call.
8. [ ] `git checkout main && git pull`
9. [ ] `claude plugin tag --push`, which creates and pushes `compass-labs--v1.2.0` at the squash commit.
10. [ ] `claude plugin update compass-labs@compass-labs`
11. [ ] Confirm the release (see below), then restart Claude to activate it.

## How it was confirmed working

Already checked before the merge: the completeness check, the full test suite (15/15 at `95dbe79`), the tag dry run, and `verification.md` (Test milestone approved, 37 VER rows, 0 fails, `check-traceability.sh` exits 0).

The orchestrator or user still needs to check these after steps 7 to 10:

- [ ] `claude plugin list` shows `compass-labs@compass-labs` at **Version: 1.2.0**, enabled.
- [ ] The installed plugin cache under `~/.claude/plugins/` for `compass-labs@compass-labs` contains `skills/framing/SKILL.md`, `skills/problem-statement/SKILL.md` and `skills/session/templates/define/index.md`. That shows the new skills shipped through the marketplace install and not only through `--plugin-dir`.
- [ ] `git ls-remote --tags origin compass-labs--v1.2.0` resolves to the squash commit on `main`.

## Rollback

- **Before the merge:** close PR #44 without merging. Nothing has been tagged or installed yet.
- **Pin back to v1.1.0:** `task lock PIN=compass-labs--v1.1.0`, which also refreshes the cache. Then restart Claude. Unpin later with `task lock UNPIN=true`.
- **Remove the tag:** `git tag -d compass-labs--v1.2.0 && git push origin :refs/tags/compass-labs--v1.2.0`.
- **Revert the release on `main`:** `git revert <squash-commit-sha>` in a PR, then `claude plugin update compass-labs@compass-labs`.
