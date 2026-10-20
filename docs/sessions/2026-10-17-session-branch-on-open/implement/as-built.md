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
| DES-005 | built as designed | | `tests/session/session_skill_test.sh` (#37 DES-005 block): step 2b sits between Slug and Folder; it reads `default-branch.sh`, proposes `feat/{issue}-{kebab-title}`, lets the user replace it, asks "use `{branch}`" or "create a new branch", starts a new branch from the default branch, stops on failure writing and committing nothing; step 3 fills `branch:`; Slug no longer creates the folder. Static checks on prose rules; the live runs are handed to Test. The step is numbered 2b so the design's "step 3" and "step 4" keep their numbers; `default-branch.sh` is also listed in the skill's Scripts table | none: a prose rule for the model, not a component |
| DES-003 | built with variation | V2: recognises a few more command and push forms than the design lists, and fails open in one more case | none: one hook script, tested through its stdin/exit-code interface | `tests/hooks/session_branch_guard_test.sh` (collaborators stubbed in a scratch plugin layout): commit on `main` blocked naming `main` and REQ-005; push to `main` blocked as `HEAD:main`, bare, remote only, `main`, `refs/heads/main`, `+HEAD:main`, `:main`, `HEAD`, `--all`, `--mirror`, wildcard, `--repo=`; commit and `push -u origin feat/5-widget` on the feature branch allowed; `ls`, `git status`, `git log`, `echo "git commit"`, non-Bash tool allowed; `&&`, `;`, `\|\|`, pipe, redirections, subshell, newline, multi-line quoted message, env prefix, full path, global options; quoted messages never parsed as commands; `git -C` (absolute and relative) and `cd`; default `trunk` with no `main`; no session and nothing staged allowed, staged `docs/sessions/` paths blocked; detached HEAD allowed; fail open with a warning for no default branch, non-repo cwd, missing collaborators, missing `jq` (silent for non-git commands); `hooks.json` registration |

## Variations

<!-- One row per difference between the design and what was built. IDs V1, V2 … are local to this file. Every variation is decided at the Implement gate: accepted as built, or sent back for rework. Write "None." under the heading when there are none. -->

| ID | DES | Designed | Built | Why |
|---|---|---|---|---|
| V1 | DES-002 | A slug in the working tree wins over a branch copy; the third column is "the branch it was found on". Silent on a slug found on several branches, and on what a working-tree session was "found on" | Among branch copies, the copy on the branch its own `branch:` field names wins, else the first branch in refname order. A working-tree session's third column is the checked-out branch (`HEAD` when detached) | A session branch cut from another session branch carries both copies; the recorded branch holds the live one. Using the checked-out branch lets DES-008 show `on {branch}` only when the third column differs from the current branch, with no extra column |
| V2 | DES-003 | Split compound commands on `&&`, `;` and `\|`; honour `git -C dir`; block a push to an explicit refspec destination (`main`, `HEAD:main`, `refs/heads/main`), `--all` or `--mirror`, or no refspec on the default branch; fail open when `jq` is missing, the cwd isn't a git repo, or `default-branch.sh` can't answer | Also: an earlier `cd dir` in the same compound command sets where later git commands run; `\|\|`, `&`, parentheses and newlines split too, quotes are respected and redirections dropped; `VAR=value`, `env`, `command`, `exec`, `time`, `nohup` prefixes and a full path to `git` are recognised; `--branches`, a `:main` deletion, a `+` forced refspec, `HEAD`/`@` while the default branch is checked out and a wildcard destination that matches it are blocked; fails open (with a warning) when `default-branch.sh` or `list-sessions.sh` is missing from the plugin. Without `jq`, the warning is printed only for commands that mention git with commit or push | Each closes a common way Claude writes the same commit or push (`cd repo && git commit …`, `git push … 2>&1`, multi-line messages), within the Risks mitigation "splits compound commands and honours `git -C`". Warning without `jq` on every Bash call would flood every tool call in a repo without `jq` |

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
