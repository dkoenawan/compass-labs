# Session hooks and scripts

> → Concepts: [Session overview](../../explanation/session/overview.md) · → [Workflow and artifacts](workflow-and-artifacts.md)
> Origin: #22

All hooks are registered in `hooks/hooks.json` and run as `bash $CLAUDE_PLUGIN_ROOT/hooks/<name>.sh`. Every hook and script needs `jq`, and every one **fails open** when a dependency is missing, so the plugin never hard-blocks a repo that isn't fully set up. Paths under `docs/sessions/` are resolved against the project's git root.

## Hooks

| Hook | Event (matcher) | Blocks? | Exit codes |
|---|---|---|---|
| `hooks/session-start.sh` | `SessionStart` | Never | Always 0 |
| `hooks/session-guard.sh` | `PreToolUse` (`Write\|Edit\|MultiEdit`) | Yes | 0 allow · 2 block (reason on stderr) |
| `hooks/session-commit-guard.sh` | `Stop` | Yes | 0 allow · 2 block (reason on stderr) |

### `session-start.sh`

Acts only when `agent_type` is `compass-labs:orchestrator` (or a bare `orchestrator`). It scans `docs/sessions/*/log.md` (not `archive/`) for `status: active|paused` and prints `Active sessions:` lines to stdout (`- {slug} (#{issue}, {status}) — phase: {phase} — next: {next_step}`) as context. When there are none, it prints a line suggesting `/compass-labs:session new`.

### `session-guard.sh`

Acts only on paths under `docs/sessions/`. The file path is normalized lexically, so `..` segments can't escape the session folder, even for files that don't exist yet. Rules, in evaluation order:

| # | Condition | Result |
|---|---|---|
| 1 | Path under `docs/sessions/archive/` | Block (archive is read-only for everyone) |
| 2 | Session has no `log.md` yet, and the target is neither `log.md` nor `overview.md` (a `plan` spec) | Block (`log.md` is created first) |
| 3 | `assets/*.md` | Block (assets are non-Markdown only) |
| 3a | Any other `assets/*` | Allow |
| 4 | Any other subdirectory | Block |
| 5 | Workflow file (`skills/session/workflows/{type}.json`) unreadable | Allow, with a warning (fail open) |
| 6 | `log.md` written by a subagent (`agent_id` set) | Block (orchestrator only) |
| 7 | File not in the workflow's `session_level.file_allowlist` | Block |
| 8 | Subagent whose `agent_type` isn't the artifact's `owner_agent` | Block |
| 9 | Artifact frozen (its phase `order` ≤ the `order` of `log.md`'s `milestone` key), written by a subagent | Block |
| 10 | Artifact frozen, written by the main session, with no uncommitted `— decision:` heading in `log.md` | Block |

The main session (no `agent_id`) may write any allowlisted artifact that isn't frozen.

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
| `check-traceability.sh` | `<session-dir>` | Exit 0 when every `REQ-*` row in `requirements.md` has a `VER-*` row in `verification.md` whose Result contains "pass". Otherwise exit 1 and list the missing IDs. |
| `archive-session.sh` | `<session-dir>` | `git mv` to `docs/sessions/archive/{slug}/`. Refuses (exit 1) unless `log.md` has `status: archived`, the working tree is clean, the folder isn't already archived, and the destination doesn't exist. It doesn't commit or push. |

## Tests

`bash tests/run.sh` runs every `tests/**/*_test.sh` (bash + jq, no other dependencies) and exits non-zero on any failure. `tests/lib.sh` provides the assertions. The tests don't ship as part of the plugin's runtime.
