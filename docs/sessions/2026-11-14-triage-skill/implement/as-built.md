<!-- The as-built record in the implement/ folder (skills/implement/SKILL.md). Four sections, tables only: never a checklist line here, so nothing in this file can be read as a task. Frozen define/ and design/ are never edited; a difference from the design is recorded as a variation below and decided at the Implement gate. -->
# As built: Triage skill

> Phase: Implement | Started: 2026-11-14 | Status: in progress
> Design: [`design/index.md`](../design/index.md) · Plan: [`tasks.md`](tasks.md) · Session history: [`log.md`](../log.md)

## As-built

<!-- One row per DES-* item in the design, each with exactly one status: built as designed | built with variation | not built. A reason is required for any status other than built as designed. A layer with no Implement guidance records "no Implement guidance for {layer}" and its follow-up issue in the Reason. Name the unit and component tests (files or test names), or "none" with the reason. -->

| DES | Status | Reason | Unit tests | Component tests |
|---|---|---|---|---|

## Variations

<!-- One row per difference between the design and what was built. IDs V1, V2 … are local to this file. Every variation is decided at the Implement gate: accepted as built, or sent back for rework. Write "None." under the heading when there are none. -->

| ID | DES | Designed | Built | Why |
|---|---|---|---|---|
| V1 | DES-008 | DES-008 depends on DES-003 to DES-007, so its tasks come after theirs, and it holds the tests for those items | DES-008's stubs and helpers (task 1) are built first. Each of DES-003 to DES-007 commits its own `tests/triage/*_test.sh` with its script (tasks 3 to 7). DES-008's last task (10) still follows every item it depends on, adds the isolation test and runs the full harness | Each script's Check is a stub test, so the stubs must exist before the first script. The Implement standard commits a task's code with its tests, and a test written later would leave each script's task without its Check |
| V2 | DES-008, DES-009 | Implementation order DES-001 → DES-008 → DES-009 | DES-009 (task 9) is built before DES-008's last task (10). Depends on still holds: DES-009 needs DES-001 and DES-006, and DES-008 doesn't need DES-009. From task 2's commit to task 9's commit, `tests/session/marketplace_test.sh` fails, because `skills/triage/` exists without a `SKILL.md` and then without a marketplace entry | `marketplace_test.sh` requires every `skills/*/` folder to have a `SKILL.md` that `marketplace.json` lists, so DES-008's Check (`bash tests/run.sh` passes) can only pass after DES-009. Listing the skill earlier would make a task span two items |
| V3 | DES-005 | "User settings only are loaded: no project or local settings, so no repository hooks" (D2 (a)), from the candidates `--setting-sources user`, `--strict-mcp-config`, `--tools`, `--add-dir`, `--bare` | `--restricted`, which loads no user, project or local settings file, with `--tools "Read,Grep,Glob"`, `--strict-mcp-config` and `--add-dir {snapshot}`. `--setting-sources` and `--bare` aren't passed. The flags and the `claude --help` text behind each are under Layer artifacts | On this machine, user settings enable installed plugins and user hooks. When compass-labs itself is installed, its hooks are this repository's code, so loading user settings could still run repository code (REQ-012). `--restricted` ignores every settings file, removes the code-running tools, confines the file tools to the working directories and refuses `bypassPermissions`. `--bare` would skip hooks too, but it reads only `ANTHROPIC_API_KEY` for auth, so a subscription login would fail under cron |
| V4 | DES-005 | The preflight checks `claude`, `gh`, the git repository and `gh auth status`; the claude flags are the tool restriction, settings isolation, no MCP and `--add-dir` | As designed, plus: the preflight also checks `jq`, `git` and `timeout` on `PATH`; claude also gets `--permission-prompts none` (anything that would prompt is denied), `--disable-slash-commands`, `--no-session-persistence` and `--output-format text`; the prompt goes on stdin; and a report that fails validation is kept beside the log as `{local-date}.report.md`. A publish that created the report but couldn't close a superseded one (exit 3) is logged as its own failure | The scripts the run calls need `jq`, `git` and `timeout`, which cron's `PATH` may lack, so a missing one is named instead of failing later. The extra flags narrow the run further with no loss: no approval can be granted, no skill or command loads, and no transcript is saved. `--tools` and `--add-dir` take several values, so a prompt argument after them would be read as one; stdin avoids that. The kept report lets the maintainer see why a run published nothing, and it stays outside the repository (D4) |

## Layer artifacts

<!-- One subsection per layer this session built, shaped by that layer's guidance (skills/{layer}/reference/implement.md). Delete the example subsection when no layer has an artifact. -->

### plugin/tooling

There is no `skills/plugin-tooling/reference/implement.md`, so this subsection records the one artifact DES-005's Check 1 asks for: the headless `claude` flags in `skills/triage/scripts/run-scheduled.sh`, checked on 2026-11-14 against `claude --help` of Claude Code 2.1.325 at `/home/su-sentinel/.local/bin/claude`. `~/.claude/settings.json` on this machine enables five plugins, `compass-labs@compass-labs` among them (V3).

| Artifact | Path | Check |
|---|---|---|
| `-p` | `skills/triage/scripts/run-scheduled.sh` (`CLAUDE_ARGS`) | Help: "-p, --print  Print response and exit (useful for pipes)". The prompt is read from stdin |
| `--tools "Read,Grep,Glob"` | same | Help: "--tools <tools...>  Specify the list of available tools from the built-in set. Use \"\" to disable all tools, \"default\" to use the default set, or specify tool names (e.g. \"Bash,Edit,Read\")". The tool restriction (REQ-012, REQ-025) |
| `--restricted` | same | Help: "Restricted mode: removes the built-in tools that run commands or code (Bash, PowerShell and the other code-running tools) and WebFetch unless --tools names them, and ignores user, project and local settings files (managed settings and --settings still apply; add --strict-mcp-config to skip MCP servers too). Also confines the file tools to the working directories (--add-dir included), refuses bypassPermissions". The settings isolation (V3): no settings hooks, no enabled plugins |
| `--strict-mcp-config` | same | Help: "Only use MCP servers from --mcp-config, ignoring all other MCP configurations". No `--mcp-config` is passed, so no MCP server loads |
| `--permission-prompts none` | same | Help: "Who answers permission prompts with --print: ... \"none\" (nobody: anything that would prompt is denied automatically)" (V4) |
| `--disable-slash-commands` | same | Help: "Disable all skills and commands" (V4) |
| `--no-session-persistence` | same | Help: "Disable session persistence - sessions will not be saved to disk and cannot be resumed (only works with --print)" (V4) |
| `--output-format text` | same | Help: "Output format (only works with --print): \"text\" (default)". Stdout is the report |
| `--add-dir {snapshot}` | same | Help: "--add-dir <directories...>  Additional directories to allow tool access to". The snapshot is readable; `--restricted` confines the file tools to it and the repository (the working directory) |
| Not passed: `--dangerously-skip-permissions`, `--allow-dangerously-skip-permissions`, `--plugin-dir`, `--plugin-url`, `--settings`, `--mcp-config`, `--setting-sources`, `--bare` | same | `tests/triage/run_scheduled_test.sh` fails if the stub `claude`'s argv holds any of them. `--bare` was rejected because its help text says "Anthropic auth is strictly ANTHROPIC_API_KEY or apiKeyHelper via --settings (OAuth and keychain are never read)" |
| `timeout 50m` | same | `/usr/bin/timeout` (coreutils). Exit 124 is logged as "claude timed out after 50m" |

## Handed to Test

<!-- One row per DES-* Check that needs a Test-owned test (integration, ui, playwright or inspection). Implement never writes those tests. -->

| DES | Check |
|---|---|
