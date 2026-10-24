# Session hooks and scripts

> → Concepts: [Session overview](../../explanation/session/overview.md) · → [Workflow and artifacts](workflow-and-artifacts.md)
> Origin: #22 · #23 · #27 · #28 · #37

All hooks are registered in `hooks/hooks.json` and run as `bash $CLAUDE_PLUGIN_ROOT/hooks/<name>.sh`. Every hook needs `jq` (`default-branch.sh` and `list-sessions.sh` need only `git`), and every hook and script **fails open** when a dependency is missing, so the plugin never hard-blocks a repo that isn't fully set up. Paths under `docs/sessions/` are resolved against the project's git root.

## Hooks

| Hook | Event (matcher) | Blocks? | Exit codes |
|---|---|---|---|
| `hooks/session-start.sh` | `SessionStart` | Never | Always 0 |
| `hooks/session-guard.sh` | `PreToolUse` (`Write\|Edit\|MultiEdit`) | Yes | 0 allow · 2 block (reason on stderr) |
| `hooks/session-branch-guard.sh` | `PreToolUse` (`Bash`) | Yes | 0 allow · 2 block (reason on stderr) |
| `hooks/session-commit-guard.sh` | `Stop` | Yes | 0 allow · 2 block (reason on stderr) |

### `session-start.sh`

Acts only when `agent_type` is `compass-labs:orchestrator` (or a bare `orchestrator`). It takes the session list from `list-sessions.sh` (so sessions committed only on another local branch are included, and `archive/` never is) and prints `Active sessions:` lines to stdout as context:

```
- {slug} (#{issue}, {status}) — phase: {phase} — next: {next_step}
- {slug} (#{issue}, {status}) — on {branch} — phase: {phase} — next: {next_step}
```

The second form is for a session that isn't in the working tree: its issue, phase and next step are read from that branch's `log.md` with `git show`, without switching branch. `{slug}` is the session's folder name. When the list is empty, it prints a line suggesting `/compass-labs:session new`. When `list-sessions.sh` is missing from the plugin, it prints nothing at all (rather than a misleading "none"), and the skill runs the lister itself.

### `session-guard.sh`

Acts only on paths under `docs/sessions/`. The file path is normalized lexically, so `..` segments can't escape the session folder, even for files that don't exist yet. Rules, in evaluation order:

| # | Condition | Result |
|---|---|---|
| 1 | Path under `docs/sessions/archive/` | Block (archive is read-only for everyone) |
| 2 | Session has no `log.md` yet, and the target is neither `log.md` nor `overview.md` (where the retired `plan` skill kept its spec; the exception is kept so nothing that exists breaks) | Block (`log.md` is created first) |
| 3 | `assets/*.md` | Block (assets are non-Markdown only) |
| 3a | Any other `assets/*` | Allow |
| 4 | Path more than one folder deep inside the session (`*/*/*`) | Block (unknown subdirectory) |
| 5 | Workflow file (`skills/session/workflows/{type}.json`) unreadable | Block a path inside a subfolder (unknown subdirectory); allow a top-level file, with a warning (fail open) |
| 6 | `log.md` written by a subagent (`agent_id` set) | Block (orchestrator only) |
| 7 | `dir/file` where `dir/` isn't in the allowlist or isn't some phase's folder `artifact` | Block (unknown subdirectory) |
| 7a | `dir/file` where `file` isn't in that phase's `artifact_files` | Block ("not one of define/'s files", or design/'s or implement/'s) |
| 7b | Top-level file not in the workflow's `session_level.file_allowlist` | Block |
| 8 | No phase owns the artifact (matched by `artifact` or `legacy_artifact`) | Block |
| 9 | The file is a phase's `legacy_artifact` (root `requirements.md`, `design.md` or `tasks.md`) and doesn't already exist in the session | Block (new sessions write `define/`, `design/` or `implement/`) |
| 9a | The file is in a folder artifact and that phase's `legacy_artifact` already exists in the session | Block (this session uses the root layout) |
| 10 | Subagent whose `agent_type` isn't the artifact's `owner_agent` | Block |
| 11 | Artifact frozen (its phase `order` ≤ the `order` of `log.md`'s `milestone` key), written by a subagent | Block |
| 12 | Artifact frozen, written by the main session, with no uncommitted `— decision:` heading in `log.md` | Block |

The main session (no `agent_id`) may write any allowlisted artifact that isn't frozen.

**Folder artifacts.** Every file inside a folder artifact resolves to the folder's key (`define/`, `design/` or `implement/`), so the whole folder has one owner (`compass-labs:define`, `compass-labs:design` or `compass-labs:implement`) and one freeze point. Rules 9 and 9a keep each session to one layout: a past session keeps editing its root `requirements.md`, `design.md` or `tasks.md`, and a new session can only use the folder. The hook's code knows no folder by name: a new folder artifact is data in the workflow file. The block messages keep their wording ("not in this workflow's session file set", "owned by", "frozen", "unknown subdirectory").

### `session-branch-guard.sh`

Keeps session work off the default branch, so it reaches it only through a pull request ([ADR-006](../../registry/decisions/006-session-branch-guard.md)). It sees only Bash calls Claude makes; the user's own terminal git never passes through it.

**Fast exit.** A Bash call whose input doesn't mention `git` together with `commit` or `push` exits 0 at once, before `jq` is even checked.

**Reading the command.** The command text is split into simple commands on `&&`, `||`, `;`, `|`, `&`, parentheses and newlines. Quotes and backslashes are respected (a quoted commit message, even a multi-line one, is never read as a command) and redirections are dropped. A simple command is a git invocation when its first word, after any `VAR=value` assignments and an `env`, `command`, `exec`, `time` or `nohup` prefix, is `git` or a path ending in `git`. Git's global options are skipped. `git -C dir` sets the repository, and so does an earlier `cd dir` in the same compound command.

**When it applies.** For each `git commit` or `git push`, it treats the call as a session commit when `list-sessions.sh` prints any session for that repository, or the index has staged paths under `docs/sessions/`. Otherwise the command is allowed. The default branch comes from `default-branch.sh`.

| Command | Blocked when |
|---|---|
| `git commit` | The current branch is the default branch. A detached `HEAD` is allowed. |
| `git push` | `--all`, `--mirror` or `--branches`; a refspec whose destination is the default branch (`main`, `HEAD:main`, `refs/heads/main`, `+main`, `:main`), or `HEAD` / `@` while it's checked out; a wildcard destination that matches it; or no refspec while the default branch is checked out. `--repo=` is understood. |

A block exits 2 with a message on stderr that names the default branch and says what to do instead (switch to the session branch, or push it and open a pull request).

**Fails open**, with a warning on stderr, when `jq` is missing (only for commands that mention git with commit or push), the directory isn't a git repository, `default-branch.sh` or `list-sessions.sh` is missing from the plugin, or `default-branch.sh` can't name the default branch.

**Known gap.** It reads command text, so `sh -c "git commit"`, `eval`, a git alias, an unquoted heredoc body, or a script that commits can get past it.

### `session-commit-guard.sh`

For each `docs/sessions/*/log.md` (not `archive/`), it checks for an uncommitted `— decision:` or `— milestone:` heading: lines added in `git diff HEAD`, or the whole file if it's untracked. If it finds one, it blocks the stop and names the log.

- **Loop guard:** the hook blocks at most 2 times in a row per Claude session, then allows the stop with a warning. The counter lives in `${TMPDIR:-/tmp}/compass-session-commit-guard/{session_id}.count`. It restarts when `stop_hook_active` is `false` and is removed on every allow. Counter files older than a day are pruned.
- It fails open when `cwd` isn't in a git repository.

`hooks/lib/session-log.sh` provides `session_log_has_uncommitted_heading <repo_root> <log_path> <regex>`, which both guards use.

## Scripts

All scripts are in `skills/session/scripts/`, called as `bash ${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/<name>`. None of them writes `log.md`.

| Script | Usage | Exit / output |
|---|---|---|
| `gh-setup.sh` | `[--repo owner/name] [--type feature]` | Creates `type:{type}` and every phase's `gh_label` with `gh label create --force` (idempotent). Prints `SYNC_PENDING: …` for each failure and keeps going. |
| `gh-milestone.sh` | `<issue> <from-phase\|none> <to-phase> <comment-file>` | Leaves exactly one `phase:*` label (`phase:{to-phase}`) and removes any stale one. Posts the comment with a hidden marker `<!-- compass:milestone:{to-phase} -->` and skips it if that marker is already present. Any `gh` failure → `SYNC_PENDING: …` on stdout, exit 0. Exit 1 only if the comment file is missing. |
| `check-traceability.sh` | `<session-dir>` | Reads `define/requirements.md`, or the root `requirements.md` in a session from before the folder (if both exist, `define/` wins). Exit 0 when every `REQ-*` row has a `VER-*` row in `verification.md` whose Result contains "pass". Otherwise exit 1 and list the missing IDs. Exit 1 naming both paths when neither requirements file exists. Only the first column of `\| REQ-nnn \|` rows is read, so extra columns (Priority, Serves), struck-through rows and `## Deferred` rows are ignored. |
| `check-design.sh` | `<session-dir>` | Design gate (a4). With `design/index.md`: exit 0 when it has the `## Classification`, `## Scope checklist`, `## Context view` and `## Delta list` headings; otherwise exit 1, printing each missing one (e.g. "delta list missing"). With only a root `design.md` (a session from before the folder): print "legacy layout: no check" and exit 0. With neither: exit 1. |
| `default-branch.sh` | `[repo-path]` | Prints the default branch name as `origin` reports it and exits 0. Reads `git symbolic-ref refs/remotes/origin/HEAD` (stripping `origin/`), then falls back to `git ls-remote --symref origin HEAD` under a timeout of `DEFAULT_BRANCH_LS_REMOTE_TIMEOUT` seconds (default 5), with no credential prompt. Never assumes `main`, never fetches, never sets `origin/HEAD`. Exit 1 with a reason on stderr when `repo-path` isn't a git repository, there is no `origin` remote, or neither source answers. |
| `list-sessions.sh` | `[repo-path]` | Prints one tab-separated line per active or paused session: `{slug}`, `{status}`, `{branch it was found on}`, `{recorded branch:, or -}`. Reads `docs/sessions/*/log.md` in the working tree (untracked files included; "found on" is the checked-out branch, or `HEAD` when detached), then at the tip of every local branch (`refs/heads`) with `git grep` and `git show`: read-only, no checkout, no fetch. Never reads `archive/` and never lists `status: archived`. `{slug}` is the folder name. A working-tree copy wins over any branch copy; among branch copies, the one on the branch its own `branch:` names wins, otherwise the first branch in refname order. Always exit 0, also when nothing is listed or `repo-path` isn't a git repository (then only its working tree is read). |
| `archive-session.sh` | `<session-dir>` | `git mv` to `docs/sessions/archive/{slug}/`. Refuses (exit 1) unless `log.md` has `status: archived`, the working tree is clean, the folder isn't already archived, and the destination doesn't exist. It doesn't commit or push. |

## Plan lookup

`skills/task-executor/scripts/find-active-plan.sh <repo-path>` finds an in-progress plan (frontmatter `status: in-progress`) in either layout, `docs/sessions/*/implement/tasks.md` or a past session's root `docs/sessions/*/tasks.md`. It prints the path, `none`, or `multiple:<path1>:<path2>…`. `doc-maintainer`'s session fold-back reads the same two paths to decide whether a session is finished.

## Tests

`bash tests/run.sh` runs every `tests/**/*_test.sh` (bash + jq, no other dependencies) and exits non-zero on any failure. `tests/integration/` holds tests that run the real hooks and scripts together in throwaway repositories with local bare remotes, such as the branch guard with the real `default-branch.sh` and `list-sessions.sh`. `tests/lib.sh` provides the assertions. The tests don't ship as part of the plugin's runtime.
