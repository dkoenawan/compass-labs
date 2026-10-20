---
issue: 37
branch: feat/37-session-branch-on-open
status: in-progress
test_command: bash tests/run.sh
last_skill_commit: null
retry_counts:
schedule: null
budget:
  max_tasks_per_run: 3
  max_wall_clock_minutes: 90
  stop_on_first_failure: true
---

<!-- The plan in the implement/ folder: the task checklist only. Tasks come from the design's Components (DES) table by the Implement standard's task rule (skills/implement/SKILL.md): each task names the DES-* it implements, tasks follow the Depends-on order, and an item's last task carries its Check, unless the Check needs a Test-owned test (then it goes under Handed to Test in as-built.md). Statuses, variations, layer artifacts and Handed to Test live in as-built.md, never here. -->

Each task names the `DES-*` item it implements. An item's last task carries its Check.

- [x] Add `skills/session/scripts/default-branch.sh` (origin/HEAD, then `ls-remote --symref` with a short timeout; exit 1 with a reason otherwise) and its component tests in `tests/session/default_branch_test.sh` [DES-001] — check: in a throwaway repo cloned from a local bare remote whose HEAD is `trunk` and which has no `main`, it prints `trunk`, both with `origin/HEAD` set and after `git remote set-head origin -d`; with no remote, it exits 1
- [x] Add `skills/session/scripts/list-sessions.sh` (working tree incl. untracked, then every local branch tip, read-only; never `archive/`; working tree wins) and its component tests in `tests/session/list_sessions_test.sh` [DES-002] — check: in a throwaway repo with `main` checked out and an active session committed only on `feat/5-widget`, it prints that session with `feat/5-widget`; an untracked new `log.md` with `status: active` is listed; an archived session isn't
- [ ] Add the `branch:` frontmatter field after `issue:` in `skills/session/templates/log.md`, with its comment, and assert it in `tests/session/session_skill_test.sh` [DES-004] — check: the template has the field; `session_skill_test.sh` asserts it
- [ ] State the no-merge rule in `skills/session/SKILL.md` (main loop and Close milestone) and `agents/orchestrator.md`, and assert it in `tests/session/session_skill_test.sh` [DES-009] — check: `session_skill_test.sh` asserts the rule in both files, and that no step of the skill merges
- [ ] Add `hooks/session-branch-guard.sh`, register it in `hooks/hooks.json` as `PreToolUse` matcher `Bash`, with component tests in `tests/hooks/session_branch_guard_test.sh` (collaborator scripts replaced by stubs) [DES-003] (depends on: 1, 2)
- [ ] Add the New session flow branch step between Slug and Folder in `skills/session/SKILL.md`, fill `branch:` in step 3, and assert the step's rules in `tests/session/session_skill_test.sh` [DES-005] (depends on: 1, 3) — check: `session_skill_test.sh` asserts the step's rules are stated (branch step before the folder, the ask on a non-default branch, the name proposal, stop on failure, `branch:` filled)
- [ ] Switch Mode dispatch listing to `list-sessions.sh` and add the switch-to-branch rule at the start of the Resume flow in `skills/session/SKILL.md`, asserted in `tests/session/session_skill_test.sh` [DES-007] (depends on: 2, 3) — check: `session_skill_test.sh` asserts the switch-before-anything rule and the use of `list-sessions.sh`
- [ ] Build `hooks/session-start.sh`'s "Active sessions" lines from `list-sessions.sh`, adding `on {branch}` for sessions not in the working tree, with a component case in `tests/hooks/session_start_test.sh` (stub lister) [DES-008] (depends on: 2)
- [ ] Make New session flow step 4 push with `git push -u origin {branch}` and add the one-time draft PR prompt before `gh-milestone.sh` in `skills/session/SKILL.md`, asserted in `tests/session/session_skill_test.sh` [DES-006] (depends on: 6) — check: `session_skill_test.sh` asserts the order (commit, push, PR prompt, `gh-milestone.sh`), the one-time ask and `--draft`
