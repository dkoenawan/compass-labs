# Release: Session Lifecycle (#22)

> Phase: Deploy | Started: 2026-09-25 | Status: Draft
> Requirements: [`requirements.md`](requirements.md) · Verification: [`verification.md`](verification.md)

## Version / target

- **Version:** compass-labs **v1.1.0** (MINOR: new skills, agents and hooks; no existing skill interface broken). Bumped from 1.0.0 in `.claude-plugin/plugin.json` by commit `9905bb9` (`chore: bump to v1.1.0`) on `feat/session-lifecycle`.
- **Tag:** `compass-labs--v1.1.0`, created on `main` after the squash-merge of PR #33.
- **Target:** local-directory marketplace `compass-labs` (this repo, `.claude-plugin/marketplace.json`), installed as `compass-labs@compass-labs` (user scope). Currently installed: 1.0.0.
- "Deploy" for this repo means releasing the plugin (per `agents/deploy.md` and the `Taskfile.yml` `release` target). Because merges are squash-only, the pieces of `task release` are split up: the bump happens on the branch, and the tag and cache refresh happen on `main` after the merge. `task release` itself is not used.

## What changed

Branch `feat/session-lifecycle` against `main` (`5801bf4`): 66 files, +4205/−99. This adds the session lifecycle (Define → Design → Implement → Test → Deploy → Close) as a plugin feature:

- **`session` skill + orchestrator** (`skills/session/`, `agents/orchestrator.md`). Runs the Feature workflow from data (`workflows/feature.json`), hands off to one phase agent per phase and gates milestones. Addresses REQ-001, REQ-002, REQ-003, REQ-007, REQ-008.
- **Phase agents** (`agents/define|design|implement|test|deploy|close.md`) following one shared contract (`reference/phase-agent-contract.md`). Addresses REQ-002, REQ-003, REQ-014. Deploy also refuses to ship an incomplete product.
- **Guard hook** (`hooks/session-guard.sh`, PreToolUse). Enforces the artifact set, ownership, freeze and archive rules, and closes a path-traversal hole. Addresses REQ-004, REQ-005, REQ-006.
- **GitHub milestone sync** (`scripts/gh-setup.sh`, `scripts/gh-milestone.sh`, which is idempotent). Addresses REQ-009, REQ-010, REQ-013.
- **Traceability gate** (`scripts/check-traceability.sh`) and the thin **`requirements` / `verification` skills**. Addresses REQ-011, REQ-014.
- **Close fold-back and archive** (`reference/close-foldback.md`, `scripts/archive-session.sh`). Addresses REQ-012.
- **Stop commit guard** (`hooks/session-commit-guard.sh`) and the generalized commit rule template. Addresses REQ-016.
- **Entry points and docs**: SessionStart "active sessions" hook, the `/compass-labs:session` skill (the duplicate `commands/session.md` was dropped), README lifecycle docs. Addresses REQ-015.
- **Fixes from Test** (VER-010, -013, -014, -020, -021, -022, -023): paths resolve against the project git root and not the plugin root, and scripts and templates resolve through `CLAUDE_PLUGIN_ROOT`.
- **Packaging**: `marketplace.json` now lists `session`, `requirements`, `verification`, `adr` and `post-hook-validator`. The empty placeholder skills were dropped. `validate-spec.sh` was retired and replaced by the guard. The `plan` skill now creates the session file at Intake.
- **Test harness** (`tests/run.sh`, bash + jq). This is repo-only and not part of the runtime surface.

## Completeness

Checked on 2026-09-25 at `9905bb9`, against `.claude-plugin/marketplace.json` as it ships (and not by how `--plugin-dir` loads things):

- **Listed → complete.** All 12 listed skills (`adr`, `bootstrap-new-project`, `brand-designer`, `doc-maintainer`, `explore`, `init`, `plan`, `post-hook-validator`, `requirements`, `session`, `task-executor`, `verification`) have a `SKILL.md` with `name`/`description` frontmatter and a real body (32–972 lines). None is a placeholder, stub, `.gitkeep`-only folder or TODO body. Grepping for `TODO|TBD|placeholder|stub` found only instructional text about *generated* output, not unfinished skill bodies. `bootstrap-new-project` is marked `[DEPRECATED]` but is complete, and it's listed on purpose.
- **Complete → listed.** `skills/` contains exactly those 12 directories, so nothing complete is left out. This session's new skills (`session`, `requirements`, `verification`) are listed.
- **Agents.** `agents/` has all 7 (`orchestrator`, `define`, `design`, `implement`, `test`, `deploy`, `close`).
- **Hooks.** Every script `hooks/hooks.json` references exists: `hooks/session-start.sh`, `hooks/session-guard.sh`, `hooks/session-commit-guard.sh` (plus `hooks/lib/session-log.sh`).
- **Commands.** `commands/hello.md` exists and is complete.
- **Session skill internals.** Every `skills|hooks|agents|scripts|templates|workflows|reference/*.{md,sh,json}` path referenced from `skills/session/SKILL.md`, `agents/*.md` and `workflows/` resolves to a file.
- The `commands/.gitkeep` and `hooks/.gitkeep` files are left over, but both folders have real content, so this isn't a gap.
- `tests/session/marketplace_test.sh` also checks the marketplace listing, and it passes.

Result: **no gaps.**

## Deploy steps run

### Run by the deploy agent (on `feat/session-lifecycle`), done

1. Completeness check (above). No gaps.
2. Bumped `.claude-plugin/plugin.json` `version` from 1.0.0 to 1.1.0 and committed it as `9905bb9` (`chore: bump to v1.1.0`). Not pushed.
3. `claude plugin tag --dry-run` succeeded. It reported: Plugin `compass-labs`, Version `1.1.0 (from plugin.json)`, Marketplace entry `plugins[0]`, Tag `compass-labs--v1.1.0`, "would create tag compass-labs--v1.1.0 at HEAD". There were 4 non-blocking warnings:
   - `CLAUDE.md` at the plugin root isn't loaded as plugin context. This is expected, because it's repo guidance.
   - The 3 `hooks/hooks.json` commands use `$CLAUDE_PLUGIN_ROOT` without quotes, so they would break on a path containing a space.
4. `bash tests/run.sh` gave **15 passed, 0 failed (of 15)**.

### Run by the orchestrator after merge (to be run)

5. [ ] Squash-merge PR #33 into `main`.
6. [ ] `git checkout main && git pull`
7. [ ] `claude plugin tag --push`. This creates and pushes `compass-labs--v1.1.0` at the squash commit.
8. [ ] `claude plugin update compass-labs@compass-labs`
9. [ ] Confirm the release (see below), then restart Claude to activate it.

## How it was confirmed working

To be confirmed by the orchestrator after steps 5–8:

- [ ] `claude plugin list` shows `compass-labs@compass-labs` with **Version: 1.1.0**, enabled.
- [ ] The installed plugin cache (the path for `compass-labs@compass-labs` under `~/.claude/plugins/`) contains `skills/session/SKILL.md`, which proves the new skill shipped through the marketplace install and not just `--plugin-dir`.
- [ ] `git ls-remote --tags origin compass-labs--v1.1.0` resolves to the squash commit on `main`.

Already verified before the merge: dry-run tag, full test suite, and completeness. Behavior is covered by `verification.md` (Test milestone approved).

## Rollback

- **Pin back to the previous release:** `task lock PIN=5801bf4` (the `main` commit before this merge, which is v1.0.0; that release was never tagged). This refreshes the cache. After that, restart Claude.
- **Remove the tag:** `git tag -d compass-labs--v1.1.0 && git push origin :refs/tags/compass-labs--v1.1.0`.
- **Revert the release on `main`:** `git revert <squash-commit-sha>` in a PR, then `claude plugin update compass-labs@compass-labs`.
- Unpin later with `task lock UNPIN=true`.
