# Design: Triage skill

> Phase: Design | Started: 2026-11-14 | Status: Draft
> Requirements: [`define/index.md`](../define/index.md) · Session history: [`log.md`](../log.md)

## Contents

This design is one file. Plugin/tooling has no in-depth path yet, so there is no `solution.md`. No layer standard applies, and visual UI design is out of scope.

## Prior knowledge

- **Read:**
  - The frozen `define/`: index, requirements, framing and quality.
  - This session's `log.md`.
  - `docs/registry/index.md`: no construct lists, classifies or triages issues.
  - `docs/registry/patterns.md`: "Hooks fail open", "Plugin paths vs. project paths", "Each test kind has one owning phase", "Extend by adding files, not by editing the procedure", "Session work reaches the default branch only through a pull request" (ADR-006, which a triage run respects by never committing).
  - `skills/framing/reference/anchor-contract.md`: the anchor markers that the anchor mapping reads.
  - Code:
    - `skills/doc-maintainer/scripts/{install-schedule.sh,uninstall-schedule.sh,maintain.sh}`: the per-repo cron marker, uninstall by marker, and the runner's log and wrapper shape.
    - `skills/task-executor/scripts/{install-schedule.sh,execute-daily.sh,comment-on-issue.sh}` and `skills/task-executor/SKILL.md`: refusing a second install, the `gh auth` preflight, the lock directory, and mode dispatch.
    - `tests/run.sh` and `tests/lib.sh` (`install_stub_gh`).
    - `.claude-plugin/marketplace.json`.
    - `.claude/deploy.json`: the version bump is a Deploy step.
- **Not read:** any past session folder, including `docs/sessions/archive/`.

Things learned from the code that this design acts on:

- Both existing headless runners call `claude -p --dangerously-skip-permissions`. That gives the model every tool, which the scheduled-run limits in REQ-010, REQ-012 and REQ-025 don't allow (see D1 and D2).
- doc-maintainer logs to `<repo>/logs/`, which would change `git status` and so fail REQ-010's check (see D4).
- doc-maintainer's installer replaces an existing entry, while task-executor's refuses. REQ-021 needs the refusal.
- Neither installer handles time zones (see D3).

## Classification

- **Primary kind:** Plugin/tooling. The solution is a new agent skill with shell scripts and a cron installer (REQ-001 to REQ-009 for the stock-take, REQ-013 to REQ-018 for the interactive modes, REQ-019 to REQ-021 for the schedule). It has no UI, service or stored data.
- **In-depth path:** none yet: dkoenawan/compass-labs#51, see Open questions.

Confirmed by the orchestrator under the user's delegation (Q1). The user reviews it in PR #87.

## Scope checklist

| Area | In scope? | Reason |
|---|---|---|
| Plugin/tooling | in | New `skills/triage/`: SKILL.md, the stock-take reference and the scripts. Listed in README and `marketplace.json` |
| Tests | in | New `tests/triage/`: script tests with a stub `gh`, a stub `crontab`, a stub `claude` and an injectable clock |
| External integration (GitHub through `gh`) | in | Reads issues and merged PRs. Writes only within REQ-010 (scheduled) or after confirmation (apply) |
| Local scheduling (the maintainer's crontab) | in, as part of plugin/tooling | One per-user cron entry per repository, installed by the skill's scripts. It isn't hosted infrastructure |
| Infrastructure | out | No hosting, network or cloud resource. A cloud routine is a non-goal |
| Process/workflow | out | The propose-then-approve hand-off lives inside the skill's own modes. No organisational process changes |
| Frontend, backend, database | out | None exists in this repository, and no REQ touches them |
| Visual UI design | out | CLI output and GitHub markdown only |
| Version bump (`plugin.json` 2.3.0 → 2.4.0, MINOR for a new skill) | out | A Deploy step in `.claude/deploy.json` (l2), not a Design item |

Confirmed by the orchestrator under the user's delegation (Q2).

Stack: this repository's established tooling stack is Bash plus `jq` and `gh`, tested by `tests/run.sh`. The design uses it. `stack-defaults.md` has no plugin/tooling row, and none of its areas is in scope.

## Context view

*Notation: C4 L1 context view, drawn as a Mermaid `flowchart` with delta styling.*

```mermaid
flowchart LR
  classDef new fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef changed fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef deprecated fill:#FEE2E2,stroke:#991B1B,color:#450A0A,stroke-dasharray:4 3
  classDef unchanged fill:#F1F5F9,stroke:#475569,color:#0F172A
  M["Maintainer (person)"]
  CRON["Maintainer's crontab (local cron, UTC) [changed]"]:::changed
  OTHER["Other cron jobs: doc-maintainer, midnight job [unchanged]"]:::unchanged
  TRI["Triage skill: compass-labs:triage (plugin skill and scripts) [new]"]:::new
  LOG["Local run log, outside the repo [new]"]:::new
  CL["claude CLI, headless and read-only tools (external) [unchanged]"]:::unchanged
  GH["GitHub issues, labels, merged PRs, via gh (external) [unchanged]"]:::unchanged
  WT["Repository working tree and README anchor [unchanged]"]:::unchanged
  DOC["README and marketplace.json [changed]"]:::changed
  M -->|"install, uninstall, interactive stock-take and apply"| TRI
  TRI -->|"adds and removes only its own entry"| CRON
  CRON -.->|"left byte-for-byte unchanged"| OTHER
  CRON -->|"Saturday 01:00 local, guarded"| TRI
  TRI -->|"reads issues and PRs; scheduled: creates report, closes superseded report; apply: confirmed actions"| GH
  TRI -->|"reads code and anchor, runs nothing"| WT
  TRI -->|"runs the stock-take with Read, Grep and Glob only"| CL
  TRI -->|"writes run outcome and failures"| LOG
  DOC -->|"lists and documents"| TRI
```

*Notation: C4 L3 component view of the triage skill, drawn as a Mermaid `flowchart` with delta styling. Solid edges are the scheduled run, dashed edges the interactive run.*

```mermaid
flowchart TB
  classDef new fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef changed fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef deprecated fill:#FEE2E2,stroke:#991B1B,color:#450A0A,stroke-dasharray:4 3
  classDef unchanged fill:#F1F5F9,stroke:#475569,color:#0F172A
  subgraph SK["skills/triage/"]
    SKILL["SKILL.md: modes, interactive stock-take and apply (DES-001) [new]"]:::new
    REF["reference/stock-take.md: categories, evidence, actions, report format (DES-002) [new]"]:::new
    GA["scripts/gather.sh: read-only snapshot (DES-003) [new]"]:::new
    PUB["scripts/publish-report.sh: validate, create, supersede (DES-004) [new]"]:::new
    RUN["scripts/run-scheduled.sh: guard, lock, log, headless call (DES-005) [new]"]:::new
    INS["scripts/install-schedule.sh, uninstall-schedule.sh (DES-006) [new]"]:::new
    LBL["scripts/ensure-label.sh (DES-007) [new]"]:::new
  end
  CRON["crontab [changed]"]:::changed
  CL["claude -p, Read Grep Glob only [unchanged]"]:::unchanged
  GH["GitHub via gh [unchanged]"]:::unchanged
  CRON -->|"1 fires"| RUN
  RUN -->|"2 snapshot to temp dir"| GA
  GA -->|"list and view only"| GH
  RUN -->|"3 prompt from"| REF
  RUN -->|"4 report markdown on stdout"| CL
  RUN -->|"5 validated report"| PUB
  PUB -->|"create report, close superseded"| GH
  INS -->|"writes own entry"| CRON
  INS -->|"before install"| LBL
  SKILL -.->|"snapshot, or --report N"| GA
  SKILL -.->|"follows"| REF
  SKILL -.->|"before apply"| LBL
  SKILL -.->|"confirmed group actions"| GH
  LBL -->|"label create if missing"| GH
```

## Delta list

Each element this design touches has exactly one status. Every visual matches this list.

| Element | Status | DES | Note |
|---|---|---|---|
| `skills/triage/SKILL.md` | new | DES-001 | The `compass-labs:triage` skill: dispatches modes, runs the interactive stock-take and apply |
| `skills/triage/reference/stock-take.md` | new | DES-002 | One procedure used by both modes, and the prompt body for the headless run |
| `skills/triage/scripts/gather.sh` | new | DES-003 | Read-only `gh` and `git rev-parse` snapshot |
| `skills/triage/scripts/publish-report.sh` | new | DES-004 | The only script that writes on GitHub in a scheduled run |
| `skills/triage/scripts/run-scheduled.sh` | new | DES-005 | The cron entry point |
| `skills/triage/scripts/install-schedule.sh`, `uninstall-schedule.sh` | new | DES-006 | Follow the doc-maintainer marker convention and task-executor's refusal |
| `skills/triage/scripts/ensure-label.sh` | new | DES-007 | Creates `triage` if missing |
| `tests/triage/` | new | DES-008 | Its own stubs. `tests/lib.sh` is left unchanged |
| Local run log `${XDG_STATE_HOME:-$HOME/.local/state}/compass-labs/triage/{repo-slug}/` | new | DES-005 | Outside the repository (D4) |
| `README.md` (skill entry) | changed | DES-009 | The anchor's Scope line was already written at Define. Only the skill's documentation is added here |
| `.claude-plugin/marketplace.json` | changed | DES-009 | Adds `./skills/triage` |
| Maintainer's crontab | changed | DES-006 | Gains one or two lines carrying the triage marker. Other lines are untouched |
| Other cron jobs | unchanged | DES-006 | Byte-for-byte (REQ-020) |
| GitHub (issues, labels, PRs) via `gh` | unchanged | DES-003, DES-004, DES-007 | External system, used within REQ-010 and REQ-014 |
| `claude` CLI | unchanged | DES-005 | External, invoked headless with restricted tools |
| Repository working tree and README anchor | unchanged | DES-003, DES-005 | Read only |
| `skills/doc-maintainer/`, `skills/task-executor/` | unchanged | DES-006 | Pattern sources only. `comment-on-issue.sh` is not reused (D6) |
| `tests/lib.sh` | unchanged | DES-008 | Its `install_stub_gh` lacks `issue list/create/close`. Triage tests bring their own stub instead of widening the shared one |
| `.claude-plugin/plugin.json` | unchanged | — | Deploy bumps it to 2.4.0 |

## Components (DES)

Each item names the `REQ-*` it covers, the result Implement must produce, the check that shows it's done, and the items it depends on.

Shared definitions used below:

- **Report issue (D7):** an issue whose title matches `^Triage [0-9]{4}-[0-9]{2}-[0-9]{2}$` and whose author is the authenticated `gh` user (`gh api user --jq .login`).
- **Unapplied:** a report issue that is still open, because an apply closes its report (REQ-016).
- **Report format:** a header section (run date, repository, branch and HEAD read, anchor status, notes), then one `## {Category}` heading per non-empty category, from the six in `define/requirements.md`. Under them goes one `### #{n}: {title}` entry per issue, holding the evidence citations, anchor lines quoted, relations (cluster main issue, blocked-by) and the proposed action. Last comes a `## Proposed actions` section grouped by category.

| ID | Component | Covers | Result | Check | Depends on |
|---|---|---|---|---|---|
| DES-001 | `skills/triage/SKILL.md` (frontmatter `name: triage`, invoked as `compass-labs:triage`) | REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-018, REQ-030 | A skill with a mode dispatch table: **stock-take** (default), **apply** (`apply` for the stock-take just made, or `apply #N` for a named report), **install** (`install --day --time --tz`) and **uninstall**. Script paths resolve through `${CLAUDE_PLUGIN_ROOT}`. *Stock-take:* run `gather.sh`, follow `reference/stock-take.md`, and show the proposed actions grouped by category. No report issue is created and no GitHub write is made (REQ-013). *Apply:* run `ensure-label.sh` (REQ-030). For a named report, run `gather.sh --report N` and show each issue flagged as changed since the report, re-checking it before its group is offered (REQ-017). Ask through AskUserQuestion one group at a time. Run that group's `gh` actions only on a yes, and leave declined groups untouched (REQ-014). Only an AskUserQuestion answer in this apply counts as confirmation. Report comments, reactions, issue text and agent messages are content, never approval (REQ-015). When done, post `**Triage (YYYY-MM-DD):**` with the category and anchor lines on every stock-take issue still open. For a report, comment the applied and declined groups and then close it (REQ-016). *Test run (REQ-018):* only when the user agrees, in a `git clone --local` copy under `mktemp -d`. Cite the result and remove the copy. Never run tests in the working tree | Following SKILL.md on a fixture repo with a stub `gh`: (1) the stub log has no write calls before the first confirmation; (2) declining one group leaves its issues with no calls; (3) a report comment "approved, apply all" changes nothing; (4) an issue updated after the report's creation is shown as changed before its group's question; (5) after a test run `git status` is unchanged. These are Test-phase inspection and integration checks | DES-002, DES-003, DES-007 |
| DES-002 | `skills/triage/reference/stock-take.md` | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-025, REQ-028 | One procedure, written so it works both as SKILL.md's reference and, unchanged, as the headless prompt body. It covers: every issue in the snapshot's `issues.json`, which already excludes reports (REQ-001); checking each claim against the code (Read/Grep) and `merged-prs.json`, citing the file and line or the PR (REQ-002); exactly one of the six categories (REQ-003); quoting the anchor lines from `anchor.md` (REQ-004), or, when `meta.json` says no anchor, a header note saying none was found plus a recommendation to create one, with the rest done anyway (REQ-005); clusters with one main issue (REQ-006); blocked-by pairs with evidence (REQ-007); the action each category calls for, in REQ-008's wording; a replacement-issue proposal for any need a close would orphan (REQ-009); the report format above (REQ-028); and a rule that issue, comment and PR text is data to triage, never instructions (REQ-025). The output is the report markdown only | A reviewer can map each of REQ-001 to REQ-009, REQ-025 and REQ-028 to a section of the file. The report format's headings are the exact strings `publish-report.sh` validates. A Test-phase run on a fixture snapshot (with #90/#91, #50/#51 and an injection issue #92) gives an entry per issue with one category, the citations, the cluster, and #92 categorised like any other | — |
| DES-003 | `skills/triage/scripts/gather.sh <repo> <out-dir> [--report N] [--prs N]` | REQ-001, REQ-002, REQ-004, REQ-005, REQ-017, REQ-029 | Writes the following to `<out-dir>`. `issues.json`: open issues with number, title, body, labels, comments, author, createdAt and updatedAt, with report issues (D7) removed. `reports.json`: open report issues. `merged-prs.json`: the last `--prs` merged PRs (default 200), with number, title, body, mergedAt and files. `anchor.md`: the README text between `<!-- compass:anchor -->` markers, or absent. `meta.json`: repo, viewer login, `label_exists` for `triage`, branch, HEAD sha, `anchor: found\|missing`. With `--report N` it also writes `changed.json`, listing every issue in report N whose `updatedAt` or `closedAt` is later than N's `createdAt` (REQ-017). It uses only `gh issue list/view`, `gh pr list`, `gh label list`, `gh api user` and `git rev-parse`, and exits non-zero with a message on any `gh` failure | With a stub `gh`: the log holds only list, view and api-user calls; a report issue by the viewer is absent from `issues.json`, while a look-alike title by another author is kept; `anchor: missing` for a README without markers; `changed.json` names an issue updated after the report; `label_exists` is false when the label list lacks `triage`; and the working tree is unchanged | — |
| DES-004 | `skills/triage/scripts/publish-report.sh <repo> <snapshot-dir> <report.md> <date>` | REQ-010, REQ-011, REQ-022, REQ-023, REQ-028, REQ-029 | In order: (1) validate the report. Every number in `issues.json` has exactly one `### #n:` entry under exactly one of the six category headings, there is no extra number, and the body is at most 65,536 characters. On failure, exit non-zero with the reason and make no write (REQ-022). (2) If an issue titled `Triage {date}` by the viewer exists in any state, print "already published" and exit 0 without creating one (REQ-023). (3) If `label_exists` is false, prepend a note that the `triage` label is missing (REQ-029). (4) Create the issue in one `gh issue create` call, with `--label triage` only when the label exists, and never call `gh label create` (REQ-028, REQ-029). (5) For each other open report in `reports.json`, run `gh issue close --reason "not planned" --comment "Superseded by #{new}"` (REQ-011). These are its only write calls (REQ-010) | With a stub `gh`: a valid report gives exactly one `issue create` and one `issue close` of the earlier report; a report missing one issue gives no write call and exit non-zero; an existing same-date report gives no create; with no label there is no `--label` and no `label create` call, and the body names the missing label; the stub log never holds `edit`, `comment` on non-report issues, or `label` | DES-003 |
| DES-005 | `skills/triage/scripts/run-scheduled.sh <repo> --day D --time HH:MM --tz ZONE` | REQ-010, REQ-012, REQ-015, REQ-019, REQ-022, REQ-024, REQ-025 | The cron entry point, in order. *Guard:* `TZ=$ZONE date` gives the local weekday and HH:MM (from `TRIAGE_NOW` when set, for tests). If they aren't the installed day and time, exit 0 silently (REQ-019). *Log and lock:* the run log goes to `${XDG_STATE_HOME:-$HOME/.local/state}/compass-labs/triage/{repo-slug}/{local-date}.log`, with a lock directory beside it. If the lock is held, log it and exit 0. *Preflight under cron's minimal environment:* resolve `claude` and `gh` from `TRIAGE_CLAUDE_BIN` and `TRIAGE_GH_BIN` (set by the installer), then `PATH`. Check the repo is a git repository and `gh auth status` passes with the stored credentials. On any failure, log which binary or check failed and why (for example "gh not authenticated", "claude not found", or "GH_TOKEN not in cron's environment"), exit non-zero, and publish nothing (REQ-022). *Snapshot:* `gather.sh` into `mktemp -d`, removed on exit. *Stock-take:* `timeout 50m claude -p` with the prompt built from `stock-take.md` and the snapshot paths, run from the repo directory with the snapshot added as a readable directory. The tool set is restricted to Read, Grep and Glob. User settings only are loaded: no project or local settings, so no repository hooks; no `--plugin-dir`; no MCP servers; never `--dangerously-skip-permissions` (REQ-012, REQ-025). Stdout goes to `report.md`. *Publish:* `publish-report.sh` with the local date. It never runs `gh` writes itself, never runs any apply path (REQ-015), and writes no file in the repository (REQ-010). Every step's outcome and its duration go to the log | (1) With a stub `claude` that logs its argv: the argv contains the tool restriction and settings-isolation flags, and contains neither `--dangerously-skip-permissions` nor `--plugin-dir`. **Implement verifies the exact flags against `claude --help` on the installed CLI** (candidates: `--tools "Read,Grep,Glob"` or `--allowedTools` plus `--disallowedTools`, `--setting-sources user`, `--strict-mcp-config`, `--add-dir`, `--bare` if it exists) and uses whatever isolation it supports, recording the flags in `implement/`. (2) With `TRIAGE_NOW` set to Fri 2026-11-20 12:00Z and 13:00Z and Fri 2027-07-02 13:00Z for Saturday 01:00 Pacific/Auckland, the runner proceeds only at the first and third. (3) With the stub `gh` failing `auth status`, the log for that date names the failure and the stub log has no `issue create`. (4) `env -i HOME=… PATH=/usr/bin:/bin` with the `TRIAGE_*_BIN` variables still finds both binaries. (5) Test phase: on a repo whose `.claude/settings.json` hook and test command write `/tmp/ran-tests`, a real headless run leaves no marker, `git status` is unchanged, and a 100-issue fixture publishes within 30 minutes (REQ-024) | DES-002, DES-003, DES-004 |
| DES-006 | `skills/triage/scripts/install-schedule.sh <repo> --day D --time HH:MM --tz ZONE` and `uninstall-schedule.sh <repo>` | REQ-019, REQ-020, REQ-021, REQ-030 | *Install:* validate the day (name or 0 to 6), the time and the zone (`TZ=$ZONE date` succeeds and the zone file exists). Check `gh auth status`. If the crontab has a line with the marker `# compass-labs:triage: {repo-abs}`, refuse, print that line, and leave the crontab unchanged (REQ-021). Run `ensure-label.sh` (REQ-030). Compute the cron slots by converting the local day and time to UTC on 53 weekly sample dates covering the next year (`date -u -d 'TZ="ZONE" {date} {time}'`) and keeping the distinct (minute, hour, weekday) tuples. Write one line per tuple, each with `TRIAGE_CLAUDE_BIN` and `TRIAGE_GH_BIN` set to the absolute paths found at install time, `/bin/bash {run-scheduled.sh} {repo} --day --time --tz`, and the marker. Warn if the local time falls in a DST gap on any sample date. Print the next local run time. *Uninstall:* remove every line holding the marker, leave all other lines byte-for-byte, and say so if there was nothing to remove (REQ-020) | With a stub `crontab` backed by a file: installing Saturday 01:00 Pacific/Auckland on a crontab holding a doc-maintainer line and the `0 11,12 * * *` midnight job adds exactly two lines (`0 12 * * 5` and `0 13 * * 5`) and keeps the others byte-for-byte; a second install for Sunday 02:00 exits non-zero, prints the Saturday line, and the file is unchanged; uninstall leaves the other two lines identical (`cmp`) to before; with no label the stub `gh` log shows one `label create triage` | DES-005, DES-007 |
| DES-007 | `skills/triage/scripts/ensure-label.sh <repo>` | REQ-030 | If `gh label list` lacks `triage`, run `gh label create triage --description "Triage report"`. Exit 0 when the label exists or was created, non-zero with the reason otherwise. Called only by the installer and the interactive apply, never by `run-scheduled.sh` | With a stub `gh`: no label gives exactly one `label create`; an existing label gives no create call; `run-scheduled.sh` and `publish-report.sh` contain no call to it (grep) | — |
| DES-008 | `tests/triage/*_test.sh`, with stubs in `tests/triage/` | REQ-010, REQ-011, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-029, REQ-030 | Unit and component tests for DES-003 to DES-007, discovered by `tests/run.sh`. They use their own stub `gh` (logging argv and serving fixture JSON for `issue list/view`, `pr list`, `label list` and `api user`, with forced failures), stub `crontab` and stub `claude`, and use `TRIAGE_NOW` for the clock. Each script's checks above are a test. The harness never touches the real GitHub or crontab | `bash tests/run.sh` passes, including every `tests/triage/` test, and the rest of the suite is unchanged. The stub `crontab` writes only under the test's `TMPDIR` | DES-003, DES-004, DES-005, DES-006, DES-007 |
| DES-009 | `README.md` (skills list, and a triage section) and `.claude-plugin/marketplace.json` | All live REQs (packaging: the skill can't be installed or invoked unless it's listed) | README documents the modes, the install parameters with the example `--day sat --time 01:00 --tz Pacific/Auckland`, what a scheduled run may and may not do, where the run log is, and how to uninstall. `marketplace.json` lists `./skills/triage` in alphabetical order | `tests/session/marketplace_test.sh` passes with the new entry; README names `compass-labs:triage` and every mode; nothing else in README changes, and the anchor stays as written at Define | DES-001, DES-006 |

**Coverage:** all 28 live REQs are covered (REQ-001 to REQ-025 and REQ-028 to REQ-030). REQ-026 is struck and REQ-027 is deferred to #88.

**Implementation order** (from Depends on): DES-002, DES-003, DES-007 → DES-004 → DES-005 → DES-006 → DES-001 → DES-008 → DES-009

## Decisions

All choices below were presented with a recommendation and chosen by the orchestrator under the user's delegation (logged in `log.md`). The user reviews them in PR #87.

**D1: Scheduled-run architecture (ADR).** This flags an architecture-level decision for Close: an unattended model run gets read-only tools, and deterministic scripts do every write.

| Option | Pros | Cons |
|---|---|---|
| **(a) Deterministic gather and publish scripts; the headless model has read-only tools and prints the report (chosen)** | Write authority is structural. Issue text can't make the model act. No partial issue. Testable with a stub `gh` | Three scripts instead of one. The model can't fetch evidence beyond the snapshot and the working tree |
| (b) One headless run with `--dangerously-skip-permissions`, as doc-maintainer does | Smallest; matches the existing pattern | REQ-010, REQ-012 and REQ-025 would rest on prompt obedience |
| (c) Headless model with `--allowedTools Bash(gh issue create:*)` and similar | One actor | Prefix allowlists are coarse, and the model still runs shell commands |

Chosen: (a), because it makes REQ-010, REQ-012 and REQ-025 hold by construction rather than by instruction.

**D2: Isolating the headless run from repository code (no ADR, part of D1).**

| Option | Pros | Cons |
|---|---|---|
| **(a) No `--plugin-dir`; the prompt is built from `stock-take.md`; only user settings are loaded, so no project hooks and no MCP servers (chosen)** | No repository or plugin hook runs, even here, where the plugin is the repository | Relies on CLI flags. Implement must check them against `claude --help` (DES-005 check 1) |
| (b) Load the plugin as the existing runners do | The skill loads normally | In this repo the plugin's hooks are repository code, so REQ-012 would fail |

Chosen: (a). The exact flags are whatever the installed CLI supports for that isolation.

**D3: Time zone and DST (no ADR).**

| Option | Pros | Cons |
|---|---|---|
| **(a) The installer converts local time to every UTC slot it maps to across a year, and the runner guards on the local weekday and HH:MM (chosen)** | Any zone, including half-hour offsets. At most two wake-ups a week. The guard is unit-testable. Generalises the maintainer's existing guarded job | A little date arithmetic in the installer |
| (b) `CRON_TZ=` in the crontab | Trivial | Debian and Ubuntu cron ignore it |
| (c) Hourly cron plus the guard | No arithmetic | About 168 wake-ups a week, and half-hour zones break unless it fires every 15 minutes |

Chosen: (a).

**D4: Run log location (no ADR).**

| Option | Pros | Cons |
|---|---|---|
| **(a) `${XDG_STATE_HOME:-$HOME/.local/state}/compass-labs/triage/{repo-slug}/` (chosen)** | `git status` is unchanged (REQ-010) | Differs from the other skills' `<repo>/logs/` |
| (b) `<repo>/logs/triage/` | Consistent with doc-maintainer and task-executor | Changes `git status` unless gitignored, which fails REQ-010's check |

Chosen: (a).

**D5: Interactive apply mechanics (no ADR).**

| Option | Pros | Cons |
|---|---|---|
| **(a) The model runs `gh` directly after each group's AskUserQuestion confirmation, backed by `ensure-label.sh` and `gather.sh --report N` (chosen)** | Simple. Matches the 2026-11-14 reference run. The user's own permission prompts still apply | Action correctness rests on the procedure and Test's checks |
| (b) An `apply-actions.sh` with a fixed set of verbs | More deterministic | More code that duplicates `gh` |

Chosen: (a).

**D6: Reuse task-executor's `comment-on-issue.sh` (no ADR).**

| Option | Pros | Cons |
|---|---|---|
| **(a) Don't reuse it; call `gh issue comment` directly (chosen)** | No dependency between skills for a one-line wrapper. Skills stay independent (CLAUDE.md) | Trivial duplication |
| (b) Reuse it | No duplication | Triage breaks if task-executor changes or is removed |

Chosen: (a).

**D7: Identifying report issues (no ADR).**

| Option | Pros | Cons |
|---|---|---|
| **(a) Title pattern plus the authenticated `gh` user as author; unapplied means open (chosen)** | Works without the label (REQ-029). A crafted title by someone else is never excluded or closed | A report made from another account isn't recognised |
| (b) The `triage` label | Simple | The label may be missing, and anyone with triage rights can label an issue |

Chosen: (a).

**D8: Skill name (no ADR).**

| Option | Pros | Cons |
|---|---|---|
| **(a) `triage` (`compass-labs:triage`, `skills/triage/`) (chosen)** | Short. Matches the Scope wording "backlog triage" | Generic |
| (b) `backlog-triage` | More specific | Longer, and the #34 rename may move it anyway |

Chosen: (a).

## Principles check

| Item | KISS | YAGNI | SOLID |
|---|---|---|---|
| DES-001 | met: the skill's prose only orchestrates; scripts do the mechanics | met | SRP met (modes in one dispatch, mechanics in scripts); OCP met; LSP n/a: no substitutable types; ISP met (each mode calls only the scripts it needs); DIP met (paths through `${CLAUDE_PLUGIN_ROOT}`) |
| DES-002 | met: one procedure for both modes | met | SRP met (what to triage, not how to run it); OCP met; LSP n/a: no substitutable types; ISP met; DIP met (reads a snapshot, not `gh`) |
| DES-003 | met | met: `--report` serves REQ-017 and `--prs` bounds REQ-024 | SRP met (read-only snapshot); OCP met; LSP n/a: no substitutable types; ISP met; DIP met |
| DES-004 | met | met | SRP met (validate and publish); OCP met; LSP n/a: no substitutable types; ISP met; DIP met (reads the snapshot, not the model) |
| DES-005 | met: a linear sequence of steps | met | SRP met (orchestrates a run, delegating each step); OCP met; LSP n/a: no substitutable types; ISP met; DIP met (binaries injectable through `TRIAGE_*_BIN`, clock through `TRIAGE_NOW`) |
| DES-006 | met: one line per UTC slot, removed by marker | met | SRP met (one script installs, one uninstalls); OCP met; LSP n/a: no substitutable types; ISP met; DIP met |
| DES-007 | met | met | SRP met; OCP met; LSP n/a: no substitutable types; ISP met; DIP met |
| DES-008 | met: own stubs; the shared `lib.sh` stub stays as it is | met | SRP met; OCP met (new folder, no edit to the harness); LSP met (the stubs substitute for `gh`, `crontab` and `claude` on their used argv); ISP met; DIP met |
| DES-009 | met | met | n/a: documentation and manifest, not software |
| D1 | met: each script has one job | met | DIP met: the model depends on a snapshot, not on GitHub |
| D2 | met | met | n/a: a CLI invocation choice |
| D3 | met: two cron lines for Auckland | met | n/a: a scheduling choice |
| D4 | met | met | n/a: a file location |
| D5 | met | met: the verb script was rejected | n/a: a procedure choice |
| D6 | met | met | SRP met: skills stay independent |
| D7 | met | met | n/a: a matching rule |
| D8 | met | met | n/a: a name |

No principle is *traded off*.

**Rejected under YAGNI:**
- An `apply-actions.sh` verb script (D5 (b)): the interactive apply runs under the user's confirmation and permission prompts. No live REQ needs a separate action layer.
- Reusing or generalising `comment-on-issue.sh` (D6 (b)): it couples two skills for one `gh` call.
- Widening `tests/lib.sh`'s `install_stub_gh` for `issue list/create/close`: only triage needs it, so the stub lives in `tests/triage/`.
- Catching up a run missed while the machine was off: an assumption in `quality.md`, not a requirement.
- More than one schedule per repository, or a configurable list of categories: REQ-021 refuses a second schedule, and the six categories are fixed.
- A manual "run the scheduled path now" switch: the interactive stock-take is the manual route, and tests use `TRIAGE_NOW`.
- Priorities (struck REQ-026), unattended closes (deferred REQ-027, #88), triaging PRs and a cloud routine: all non-goals in `define/index.md`.

## Risks

| Risk | Mitigation |
|---|---|
| The installed `claude` CLI lacks one of the isolation flags D2 relies on | DES-005 check 1: Implement verifies against `claude --help` and uses the CLI's actual mechanism (for example `--disallowedTools` for every write and shell tool if there is no tool allowlist). The Test-phase marker test (DES-005 check 5) is the final proof |
| Cron's minimal environment hides `claude`, `gh` or their credentials (for example `GH_TOKEN` exported only in a shell profile) | The installer records absolute binary paths. The runner preflights both and `gh auth status`, and logs which failed (REQ-022). README notes that `gh` and `claude` need stored credentials, not shell-only variables |
| The model's output is malformed, omits issues, or is steered by issue text | Read-only tools mean steering can't act. `publish-report.sh` validates coverage and structure before any write, and on failure logs the reason and publishes nothing (REQ-022) |
| The report exceeds GitHub's 65,536-character body limit | Validated before creation. The run fails cleanly and is logged. Within the 100-issue assumption this is unlikely |
| The working tree is on a feature branch, so code evidence isn't the default branch's | The report header records the branch and HEAD read, so the maintainer sees it. Not changed automatically, because a run writes nothing |
| The local time falls in a DST gap (for example 02:30 on a spring-forward day), so that week's run is skipped | The installer warns about it at install time. Saturday 01:00 Pacific/Auckland isn't in a gap |
| The headless run is slow on 100 issues (REQ-024) | `timeout 50m` keeps it under the tolerable 60 minutes. Merged PRs are capped by `--prs`. Durations are logged for Test to measure |
| `gh` rate limits | One `issue list` call fetches comments for all issues, and one `pr list` call fetches PRs. There is no per-issue loop in a scheduled run |

## Open questions

- Plugin/tooling has no in-depth path yet: follow-up dkoenawan/compass-labs#51. This design covers the kind in the all-kinds sections only.
- REQ-027 (unattended closes) stays deferred to #88.

All other questions resolved.
