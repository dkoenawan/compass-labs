# Release: Session opens on a feature branch (#37)

> Phase: Deploy | Started: 2026-10-24 | Status: Draft
> Requirements: [`define/index.md`](define/index.md) · Design: [`design/index.md`](design/index.md) · As built: [`implement/as-built.md`](implement/as-built.md) · Verification: [`verification.md`](verification.md)

## Version / target

- **Version:** compass-labs **v2.2.0**, a MINOR bump from v2.1.0 (`.claude-plugin/plugin.json`). `.claude-plugin/marketplace.json` has no `version` field, so nothing there needs to match.
- **Why MINOR:** CLAUDE.md's rules say new skills or backward-compatible enhancements are MINOR, and breaking changes to skill interfaces are MAJOR. This release adds one hook (`hooks/session-branch-guard.sh`) and two session scripts (`default-branch.sh`, `list-sessions.sh`), and changes the New session, Resume and Close flows of `/compass-labs:session`. No skill is added, removed or renamed, and every `/compass-labs:*` entry point keeps its name and arguments.
  - Behaviour note for the user at the gate: from v2.2.0, the guard blocks Claude's session commits and pushes on the default branch (REQ-005). A consuming repo that has a session already open on `main` under v2.1.0 will have its next session commit blocked until that work moves to a branch. That's the point of the change, not an interface break, and it's why MINOR rather than MAJOR is proposed. If the user reads it as breaking, the bump is MAJOR (v3.0.0) instead.
- **Tag:** `compass-labs--v2.2.0`, created by `claude plugin tag --push` on `main` after the squash-merge of PR [#71](https://github.com/dkoenawan/compass-labs/pull/71). Note: v2.1.0 was tagged `v2.1.0` (annotated, at `b1c2bcc`), not `compass-labs--v2.1.0` as `claude plugin tag` names it. v2.0.0 and earlier use the `compass-labs--v*` form. This release goes back to the tool's form.
- **Target:** the local-directory marketplace `compass-labs` (this repo, `.claude-plugin/marketplace.json`), installed as `compass-labs@compass-labs` at user scope. Installed now: 2.1.0 at `b1c2bcc` (`~/.claude/plugins/installed_plugins.json`).
- **What "deploy" means here:** releasing the plugin (`agents/deploy.md`, `Taskfile.yml` `release` target). There's no CI. As in the last four releases (`docs/sessions/archive/*/release.md`), the bump is done on the branch, and the tag and cache refresh are done on `main` after the squash-merge. `task release` isn't run as a whole: its `_tag-and-push` would tag a branch commit that the squash-merge throws away, and its `_bump-version` commit message doesn't carry the issue reference. With #37 in place, its `git push origin HEAD --tags` on `main` would also be a push to the default branch, which merging is the user's call for.
- **PR:** [#71](https://github.com/dkoenawan/compass-labs/pull/71), `feat/37-session-branch-on-open` → `main`, open and draft. Not merged; merging is the user's call.

## What changed

Branch `feat/37-session-branch-on-open` compared with `main` (`b1c2bcc`): 23 files, +2160/−42 (session folder included). By design item:

- **Default-branch lookup** `skills/session/scripts/default-branch.sh` (new; DES-001): covers REQ-006.
- **Session lister** `skills/session/scripts/list-sessions.sh` (new; DES-002, variation V1 accepted): covers REQ-004 and REQ-005.
- **Branch guard** `hooks/session-branch-guard.sh`, registered in `hooks/hooks.json` as `PreToolUse` matcher `Bash` (new; DES-003, variation V2 accepted): covers REQ-005 and REQ-006.
- **Session branch record** `branch:` in `skills/session/templates/log.md` frontmatter (DES-004): covers REQ-003.
- **New session branch step** in `skills/session/SKILL.md`, step 2b (DES-005): covers REQ-001, REQ-002, REQ-007 and REQ-010.
- **First push and draft PR prompt** in `skills/session/SKILL.md` step 4 (DES-006): covers REQ-008.
- **Cross-branch listing and Resume switch** in `skills/session/SKILL.md` (DES-007): covers REQ-004.
- **Session list at start** `hooks/session-start.sh` (DES-008, variation V3 accepted): covers REQ-004.
- **No-merge rule** in `skills/session/SKILL.md` and `agents/orchestrator.md` (DES-009): covers REQ-009.
- **Tests:** `tests/hooks/session_branch_guard_test.sh`, `tests/session/default_branch_test.sh`, `tests/session/list_sessions_test.sh`, `tests/integration/session_branch_integration_test.sh`, and extra cases in `session_start_test.sh` and `session_skill_test.sh`.

Verification: VER-001 to VER-013 pass, covering REQ-001 to REQ-010. VER-014 (live orchestrator runs against real GitHub) is pending by the user's choice at the Test gate.

**Not in this release:** follow-ups #70 (no remote or a failed push), #72 (Close closes the issue before the PR is merged) and #73 (branch guard stops applying once a session is archived). The as-built docs (`docs/explanation/session/overview.md`, `docs/reference/session/hooks-and-scripts.md`) are folded in by Close, per the design's scope table.

## Completeness

Checked on 2026-10-24 at `ba797ef` against `.claude-plugin/marketplace.json` and `hooks/hooks.json` as they ship. `--plugin-dir` wasn't used, because it ignores the skill list.

- **Everything listed is complete.** `marketplace.json` lists 16 skills. Each has a `SKILL.md` whose `name` frontmatter matches its folder and that has a real body (13 to 972 lines; `backend`'s 13 lines are an index by design, as recorded for v2.1.0). This session added no skill.
- **Hooks as they ship.** All four scripts `hooks/hooks.json` references exist and are non-empty: `session-start.sh` (94 lines), `session-guard.sh` (298), `session-branch-guard.sh` (328, new) and `session-commit-guard.sh` (114). All pass `bash -n`.
- **New scripts.** `skills/session/scripts/default-branch.sh` (60 lines) and `list-sessions.sh` (131) exist, pass `bash -n`, and are tracked as mode `100755`, as is `hooks/session-branch-guard.sh`. They ship inside `skills/session/`, which is listed.
- **Nothing is unfinished.** No file under `skills/`, `agents/` or `hooks/` is empty except `hooks/.gitkeep`, which sits next to real scripts (the folder isn't `.gitkeep`-only); `commands/.gitkeep` sits next to `hello.md`. A whole-word grep for `TODO`, `TBD` or `FIXME` across `skills/`, `hooks/` and `agents/` finds only `agents/deploy.md`'s own rule text and its #30 note.
- **Nothing complete is left out.** `skills/` has exactly the 16 folders listed (`diff` of the manifest list against `ls skills/` is empty). The new hook is registered in `hooks/hooks.json` (VER-013). `tests/session/marketplace_test.sh` passes.
- **Agents:** all 7 exist in `agents/`.
- **Tasks:** 9 of 9 in `implement/tasks.md` are ticked, with frontmatter `status: complete`.

Result: **no gaps** in the release manifest.

Documentation gap, not a manifest gap: the README's "What the hooks enforce" table (`README.md`, around line 395) lists `session-guard.sh`, `session-start.sh` and `session-commit-guard.sh` but not the new `session-branch-guard.sh`. Since the plugin is for public distribution and the README is what a user installing it reads, a row should be added before the merge (proposed in Deploy step 3 below).

## Deploy steps run

### Run by the deploy agent on `feat/37-session-branch-on-open` (done)

1. Ran the completeness check above. No manifest gaps; one README gap noted.
2. Ran `bash tests/run.sh` at `ba797ef`: **25 passed, 0 failed (of 25)** (24 at Test plus the integration script kept in the harness).
3. Ran `claude plugin tag --dry-run`. It stopped with "Uncommitted changes affecting this release": the orchestrator's uncommitted `log.md` edit. Its warnings were the same non-blocking ones as v2.1.0 (`CLAUDE.md` isn't loaded as plugin context; `hooks/hooks.json` commands use `$CLAUDE_PLUGIN_ROOT` without quotes), now 4 hook warnings instead of 3 because of the new entry. To be re-run after step 6.

### Pending: for the orchestrator (the deploy agent writes only `release.md`)

4. [ ] Add a README row for the new hook, in the "What the hooks enforce" table, e.g. `| hooks/session-branch-guard.sh | PreToolUse (Bash) | Blocks Claude's session commits on the default branch and pushes to it (read from the repo, not assumed to be main), so session work reaches it only through a pull request |`. Commit, e.g. `docs(readme): list the session branch guard — #37`.
5. [ ] Bump `.claude-plugin/plugin.json` `version` from `2.1.0` to `2.2.0`. Commit it alone as `chore: bump to v2.2.0 — #37`.
6. [ ] Commit `log.md` and this `release.md`, then `bash tests/run.sh` (expect 25 of 25) and `claude plugin tag --dry-run` (expect Version `2.2.0 (from plugin.json)`, Tag `compass-labs--v2.2.0`).
7. [ ] Push the branch: `git push` (upstream is `origin/feat/37-session-branch-on-open`).
8. [ ] Update PR #71's title to carry the version, e.g. `feat: Session opens on a feature branch (v2.2.0) — #37`, and mark it ready for review (`gh pr ready 71`) when the user wants it.

### Pending: the user's call (merge and outward release)

9. [ ] Squash-merge PR #71 into `main`. The user does this; no agent merges it (REQ-009).
10. [ ] `git checkout main && git pull`
11. [ ] `claude plugin tag --push`: creates and pushes `compass-labs--v2.2.0` at the squash commit on `main`.
12. [ ] `claude plugin update compass-labs@compass-labs` to refresh the plugin cache, then restart Claude.

## How it was confirmed working

Checked before the merge:

- The completeness check (no manifest gaps).
- The full test suite: 25 of 25 at `ba797ef`.
- `verification.md`: VER-001 to VER-013 pass for REQ-001 to REQ-010; VER-014 pending.
- The tag dry run is not yet clean (uncommitted `log.md`); re-run at step 6.

Still to check after steps 9 to 12:

- [ ] `claude plugin list` shows `compass-labs@compass-labs` at **Version: 2.2.0** and enabled, with `main` checked out. For this local-directory marketplace the version is read from the working tree, so this alone doesn't prove the release is installed.
- [ ] `~/.claude/plugins/installed_plugins.json` shows `version: 2.2.0` and the squash commit's `gitCommitSha`, and the cache under `~/.claude/plugins/cache/compass-labs/compass-labs/2.2.0/` contains `hooks/session-branch-guard.sh`, `skills/session/scripts/default-branch.sh` and `skills/session/scripts/list-sessions.sh`, and its `hooks/hooks.json` has the `Bash` matcher. This proves the change shipped through the marketplace install, not only through `--plugin-dir`.
- [ ] `git ls-remote --tags origin compass-labs--v2.2.0` resolves to the squash commit on `main`.
- [ ] Optional, closes VER-014's gap: in a throwaway consuming repo with the installed plugin, start a session on `main` and confirm the orchestrator creates the session branch before the first commit, and that a `git commit` of session files on `main` is blocked.

## Rollback

- **Before the merge:** leave PR #71 unmerged or close it. Nothing is tagged. To drop the bump on the branch, `git revert` the `chore: bump to v2.2.0 — #37` commit.
- **Pin back to v2.1.0:** `task lock PIN=v2.1.0` (that release's tag name), which also refreshes the cache, then restart Claude. Unpin later with `task lock UNPIN=true`.
- **Turn off only the guard:** if the branch guard misfires in a consuming repo, the quickest local relief is pinning back (above); the guard also fails open without `jq` or outside a git repo. A fix goes through a new session and a PATCH release.
- **Remove the tag:** `git tag -d compass-labs--v2.2.0 && git push origin :refs/tags/compass-labs--v2.2.0`.
- **Revert the release on `main`:** `git revert <squash-commit-sha>` in a PR, then `claude plugin update compass-labs@compass-labs`. Sessions opened under v2.2.0 carry a `branch:` field in `log.md` that v2.1.0 ignores, so they keep working, but v2.1.0 won't switch to their branch on Resume.
