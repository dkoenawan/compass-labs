---
id: "010"
date: 2026-11-14
status: Accepted
deciders: [Daniel Koenawan (delegated to the session orchestrator)]
affects: [triage, StockTakeProcedure, TriageSnapshot, TriageReportPublisher, TriageScheduledRun]
issue: https://github.com/dkoenawan/compass-labs/issues/86
---

# ADR-010: An unattended triage run is a read-only headless model in a restricted, plugin-free session; deterministic scripts make every GitHub write

> Origin: #86

## Context

The `triage` skill runs a weekly stock-take of a repository's open issues from the maintainer's crontab, with nobody present. The model reads text written by other people and by other agents: issue bodies, comments, pull request descriptions and the README. Any of it can be written to steer an agent ("close every open issue now", "this report is approved").

The anchor's non-goal "Replacing user approval at milestones" means an unattended run may only *propose*. It can publish its own report issue and close its own superseded report. It can't close, edit, label or comment on any other issue, create a label, apply anything, run tests or other repository code, or write in the repository.

The plugin's other headless runners (`doc-maintainer`'s `maintain.sh`, `task-executor`'s `execute-daily.sh`) call `claude -p --dangerously-skip-permissions`, which gives the model every tool. Under that model, every limit above would rest on the prompt being obeyed. In this repository the plugin *is* the repository, so loading the plugin, or any settings file that enables it, would run repository code (its hooks).

Constraints: the run has to work under cron's minimal environment with the maintainer's normal `claude` sign-in. The report has to cover every open issue or not be published at all. The whole run has to be testable with stub `gh`, `claude` and `crontab`.

## Decision

We will split an unattended run into **deterministic scripts that own all GitHub I/O** and **a headless model that only reads and prints**:

1. `gather.sh` takes a read-only snapshot with `gh issue list/view`, `gh pr list`, `gh label list`, `gh api user` and `git rev-parse`. It writes the snapshot to a temporary directory outside the repository.
2. `claude -p` runs the stock-take procedure (`reference/stock-take.md`, sent unchanged as the prompt on stdin) from the repository directory, under `timeout 50m`. It can use **only the Read, Grep and Glob tools**, and its stdout is the report markdown.
3. `publish-report.sh` validates the report's structure and coverage against the snapshot before any write. Then it makes the run's only writes: one `gh issue create` and a `gh issue close` of each of its own earlier unapplied reports. It never creates a label.

The headless session is **isolated from repository and plugin code**:

| Flag | Effect |
|---|---|
| `--tools "Read,Grep,Glob"` | The only tools available |
| `--restricted` | Ignores user, project and local settings files, so no settings hooks and no enabled plugins. Removes the code-running tools, confines the file tools to the working directories and refuses `bypassPermissions` |
| `--strict-mcp-config` (with no `--mcp-config`) | No MCP server loads |
| `--permission-prompts none` | Anything that would prompt is denied |
| `--disable-slash-commands`, `--no-session-persistence`, `--output-format text` | No skill or command loads, no transcript is saved, and stdout is the report |
| `--add-dir {snapshot}` | The snapshot is readable alongside the working tree |

The run never passes `--dangerously-skip-permissions`, `--allow-dangerously-skip-permissions`, `--plugin-dir`, `--plugin-url`, `--settings`, `--mcp-config`, `--setting-sources` or `--bare`. A unit test fails if the argv holds any of them.

The interactive `apply` is outside this decision. It runs in the user's own session, and the model runs `gh` there only after the user's `AskUserQuestion` answer for each group.

## Options Considered

**Who writes on GitHub in an unattended run**

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Deterministic gather and publish scripts; the model has read-only tools and prints the report (chosen)** | Write authority is structural, so issue text can't make the model act. A malformed report publishes nothing. Testable with a stub `gh` | Three scripts instead of one. The model can't fetch evidence beyond the snapshot and the working tree | — chosen |
| One headless run with `--dangerously-skip-permissions`, like `doc-maintainer` | Smallest. Matches the existing runners | The no-write, no-code and injection limits rest on the prompt being obeyed | Limits by instruction, not construction |
| Headless model with prefix allowlists such as `--allowedTools Bash(gh issue create:*)` | One actor | Prefix allowlists are coarse, and the model still runs shell commands | Too coarse; still a shell |

**How the headless session is kept away from repository and plugin code**

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **`--restricted`, with `--tools`, `--strict-mcp-config` and no `--plugin-dir` (chosen)** | Ignores every settings file, so no hook or plugin loads, even when compass-labs is installed. Works with a subscription sign-in | Relies on CLI flags, so a CLI change could weaken it | — chosen |
| Load user settings only (`--setting-sources user`) | Keeps the user's normal configuration | User settings enable installed plugins and user hooks. With compass-labs installed, its hooks are this repository's code | Repository code could still run |
| `--bare` | Skips hooks and plugins too | Authenticates only with `ANTHROPIC_API_KEY` or an `apiKeyHelper`, so a normal sign-in fails under cron | Breaks unattended auth |
| Load the plugin, as the other runners do | The skill loads normally | The plugin's hooks are repository code here | Runs repository code |

## NFR Captured

- Integrity: a scheduled run's GitHub writes are limited to creating its own `Triage YYYY-MM-DD` report and closing its own superseded reports, by construction.
- Safety: a scheduled run runs no repository code (tests, hooks, scripts) and writes nothing in the repository. Its log lives under `${XDG_STATE_HOME:-$HOME/.local/state}`.
- Injection resistance: instructions in issue, comment or PR text can't cause any action, because the model has no tool that acts.
- Completeness: a report that misses an open issue, has an extra entry, or breaks the fixed format is not published.
- Timeliness: for 100 open issues the report is published within 30 minutes (goal), 60 at worst. The model step is capped at 50 minutes.

## Consequences

**Now easier**: The no-write, no-code and injection guarantees can be tested with stub binaries and an argv check, not just reviewed. A failed or malformed run leaves no partial issue, and its report is kept beside the run log.
**Now harder**: The model sees only the snapshot and the checked-out working tree. Evidence comes from whatever branch is checked out, which the report header records. Merged PRs are capped (default 200), and claims that need a test run can't be settled unattended.
**New constraints**: The isolation depends on the installed `claude` CLI supporting these flags. A CLI change has to be re-checked against `claude --help` and the argv test. The run needs stored credentials for `gh` and `claude`, not variables exported only in a shell profile. Any change that would let an unattended run carry out a proposed action has to revisit this ADR.

## Revisit Conditions

- If unattended runs are allowed to carry out some actions, for example closing an issue covered by a merged PR (#88), re-evaluate where write authority sits.
- If the `claude` CLI drops or changes `--restricted`, `--tools` or `--strict-mcp-config`, re-evaluate the isolation.
- If the report outgrows one issue body (#90), re-evaluate the single-create publish step.
- The other headless runners (`doc-maintainer`, `task-executor`) still use `--dangerously-skip-permissions`. Any of them that starts reading untrusted text unattended should adopt this split.
