<!-- The as-built record in the implement/ folder (skills/implement/SKILL.md). Four sections, tables only: never a checklist line here, so nothing in this file can be read as a task. Frozen define/ and design/ are never edited; a difference from the design is recorded as a variation below and decided at the Implement gate. -->
# As built: Session opens on a feature branch

> Phase: Implement | Started: 2026-10-20 | Status: in progress
> Design: [`design/index.md`](../design/index.md) · Plan: [`tasks.md`](tasks.md) · Session history: [`log.md`](../log.md)

## As-built

<!-- One row per DES-* item in the design, each with exactly one status: built as designed | built with variation | not built. A reason is required for any status other than built as designed. A layer with no Implement guidance records "no Implement guidance for {layer}" and its follow-up issue in the Reason. Name the unit and component tests (files or test names), or "none" with the reason. -->

| DES | Status | Reason | Unit tests | Component tests |
|---|---|---|---|---|
| DES-001 | built as designed | | none: a two-call script with no separable units | `tests/session/default_branch_test.sh`: `trunk` via `origin/HEAD` and via the `ls-remote` fallback, a `develop` default, from a subdirectory and from cwd, no `origin` (exit 1), unreachable `origin` (exit 1), not a repo (exit 1) |
| DES-002 | built with variation | V1: adds a tie-break between branch copies and defines "found on" for working-tree sessions, both left open by the design | none: one script, its frontmatter parsing is exercised through the CLI | `tests/session/list_sessions_test.sh`: empty repo; session committed only on `feat/5-widget` listed with that branch while `main` is checked out (and no switch happens); untracked active `log.md` listed with `-` for a missing `branch:`; paused listed; `archive/` and `status: archived` never listed (working tree and branch); working tree wins over the branch copy; on two branches the recorded branch's copy wins; subdirectory and no-argument calls; non-repo and missing path exit 0 |
| DES-004 | built as designed | | `tests/session/session_skill_test.sh` (#37 DES-004 block): the template's frontmatter has `branch: {branch-name}` right after `issue:`, with its comment | none: a template, not a component |
| DES-009 | built as designed | | `tests/session/session_skill_test.sh` (#37 DES-009 block): the same rule text in `SKILL.md` and `agents/orchestrator.md`; Close step 7 hands the merge to the user; every line naming `gh pr merge` or `git merge` is the rule itself. These are static checks on prose rules; whether the model follows them is the live check handed to Test | none: a prose rule for the model, not a component |

## Variations

<!-- One row per difference between the design and what was built. IDs V1, V2 … are local to this file. Every variation is decided at the Implement gate: accepted as built, or sent back for rework. Write "None." under the heading when there are none. -->

| ID | DES | Designed | Built | Why |
|---|---|---|---|---|
| V1 | DES-002 | A slug in the working tree wins over a branch copy; the third column is "the branch it was found on". Silent on a slug found on several branches, and on what a working-tree session was "found on" | Among branch copies, the copy on the branch its own `branch:` field names wins, else the first branch in refname order. A working-tree session's third column is the checked-out branch (`HEAD` when detached) | A session branch cut from another session branch carries both copies; the recorded branch holds the live one. Using the checked-out branch lets DES-008 show `on {branch}` only when the third column differs from the current branch, with no extra column |

## Layer artifacts

<!-- One subsection per layer this session built, shaped by that layer's guidance (skills/{layer}/reference/implement.md). Delete the example subsection when no layer has an artifact. -->

None. Every item is Plugin/tooling (bash scripts, a hook and Markdown skill files); no `DES-*` Component cell names a layer with a `skills/{layer}/` folder, so no layer guidance applies and no layer artifact is produced.

## Handed to Test

<!-- One row per DES-* Check that needs a Test-owned test (integration, ui, playwright or inspection). Implement never writes those tests. -->

| DES | Check |
|---|---|
| DES-003 | Integration (real hook with the real `default-branch.sh` and `list-sessions.sh`): with an active session and `main` checked out, `git commit -m x` is blocked with `main` in the message and `main`'s head is unchanged. Same with default `trunk` and no `main`. `git push origin HEAD:main` and `git push` on `main` are blocked. `git commit` on `feat/5-widget` and `git push -u origin feat/5-widget` are allowed. With no active session and nothing staged under `docs/sessions/`, a commit on `main` is allowed. `ls` and `git status` are allowed. No `jq`: allowed with a warning |
| DES-005 | Live, per OUT-01: a throwaway repo on clean `main`, on `feat/5-existing`, on default `trunk`, and with the branch checked out in another worktree |
| DES-006 | Live: the draft PR exists before the next log entry after the opening commit |
| DES-007 | Live: resume with `main` checked out; the next milestone commit lands on `feat/5-widget`, and `main` and `origin/main` don't move |
| DES-008 | Integration (real `session-start.sh` with the real `list-sessions.sh`): a session committed only on another branch appears with its branch |
| DES-009 | Live: after the Close milestone is approved with no merge request, the PR is still open |
