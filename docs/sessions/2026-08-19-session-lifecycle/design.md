# Design: Session Lifecycle

> Phase: Design | Started: 2026-09-24 | Status: **Approved and frozen** (Design milestone, 2026-09-24). D1–D7 accepted.
> Requirements: [`requirements.md`](requirements.md) · Tasks: [`tasks.md`](tasks.md) · Session history: [`log.md`](log.md)

## Traceability (design item → requirements)

| Design item | Covers |
|---|---|
| D1 Session folder / artifacts | REQ-004, REQ-014 |
| D2 Log format | REQ-007, REQ-008 |
| D3 Orchestrator | REQ-001, REQ-002, REQ-008, REQ-011 (milestone gate), REQ-015 |
| D4 Phase agent contract | REQ-002, REQ-003 |
| D5 GitHub integration | REQ-009, REQ-010, REQ-013 |
| D6 Fold-back and archive | REQ-012 |
| D7 Enforcement | REQ-004, REQ-005, REQ-006 |
| D8 Atomic commit points | REQ-016 |

Scope for this issue is the **Feature** session type only (Q4). This design fixes the *shape* of every artifact and component. How each phase's content gets filled in, beyond a thin first version, is built out in #26–#30.

---

## Platform facts (checked against Claude Code docs, 2026-09-24)

Sources: `code.claude.com/docs/en/sub-agents`, `/plugins-reference`, `/workflows`, `/hooks`.

| # | Fact | What it means for the design |
|---|---|---|
| P1 | Subagents **can** start other subagents, up to 3 levels below the main session. | C7 corrected. Being unable to nest is not why the orchestrator is in the main session. |
| P2 | Subagents **can't use `AskUserQuestion`**. They return only a final summary. | Only the main session talks to the user, so the orchestrator lives there (Q2). |
| P3 | Subagents start with a fresh context: their own prompt, the task message, CLAUDE.md, git status, and preloaded `skills:`. | Phase agents need the session path passed in. The skills they preload define their artifact standards. |
| P4 | `SendMessage` resumes a subagent with its history, **but only within the same Claude Code session**. | Useful inside a phase. Anything that must survive a break goes to disk. |
| P5 | Plugins ship `agents/` (`compass-labs:<name>`). Plugin agents ignore `hooks`, `mcpServers`, `permissionMode`, `initialPrompt`. | Enforcement uses plugin-level hooks. The orchestrator agent can't greet the user on its own; see D3. |
| P6 | Plugin hooks fire **inside subagents**. Hook input includes `agent_id` / `agent_type`. `PreToolUse` exit code 2 blocks the call. | Enforcing the file set and file ownership is possible (D7). |
| P7 | Workflows can't take user input mid-run and can only be resumed within the same session. | Not the orchestrator. A candidate for fan-out inside a phase (#28/#29). |
| P8 | `claude --agent <name>` runs an agent *as* the main session. The `agent` key in `.claude/settings.json` makes it the default. Hook input includes `agent_type` when `--agent` is used. | The orchestrator can be the whole session (D3). **To verify:** a plugin-namespaced agent (`compass-labs:orchestrator`) works with `--agent`. |

---

## D1 — Session folder: one artifact per phase

**Rule: each phase produces exactly one artifact file, owned by that phase's agent. The log belongs to the orchestrator.** Each artifact starts thin (a template of a few sections) and is filled out in the phase's follow-up issue. **Artifacts refer to each other by ID instead of repeating content.** That's what keeps them from duplicating each other as they grow.

```
docs/sessions/{date}-{slug}/
  requirements.md    # Define
  design.md          # Design
  tasks.md           # Implement
  verification.md    # Test
  release.md         # Deploy
  log.md             # orchestrator: state, decisions, handoffs
  assets/            # optional, non-Markdown only
```

Close produces no session file. Its output is the as-built docs plus the archive move (D6).

**An artifact can grow into a folder** (accepted with D1a). As each phase is built out (#26–#30), its single Markdown file may become a folder in the session holding several artifacts in their native formats. The Markdown file stays as the entry point and **links to** those artifacts rather than copying them in. Example: with Playwright, the Test phase becomes `verification.md` + `verification/` holding the Playwright HTML/JSON report, and each `VER-*` row links to its results in the report. The D7 allowlist grows one phase folder at a time as each is introduced. The pattern stays the same: one owner, one entry-point file, and native artifacts beside it.

### How the artifacts link to each other

```
REQ-001 (requirements.md)
  └─ DES-001 addresses REQ-001 (design.md)
       └─ task 3 implements DES-001 (tasks.md)
            └─ VER-001 verifies REQ-001 → pass/fail (verification.md)
                 └─ released in v1.2.0 (release.md)
```

Every requirement has to be traceable to at least one test. This gives the Close gate something mechanical to check: every `REQ-*` has a passing `VER-*`.

### Artifacts

| Artifact | Phase / owner | Standard (skill that defines it) | Thin first-version sections | Created → updated → frozen | Starts from | Built out in |
|---|---|---|---|---|---|---|
| `requirements.md` | Define / `define` agent | **`requirements` skill (new)** | Problem statement · Scope + non-goals · Requirements (`REQ-nnn`, EARS syntax) · Acceptance criteria per REQ (Given/When/Then) · Constraints · Open questions | Created at Intake (keeps `27e8c1b`) → updated through Define → **frozen at the Define milestone**. Changes after that require a logged `decision` entry. | `plan` Q1–Q3 + Summary/Complexity Profile | #26 |
| `design.md` | Design / `design` agent | **`design` skill** (the layer structure from `plan`'s template) + `adr` | Approach · Components/layers (`DES-nnn`, each naming the `REQ-*` it covers) · Decisions (links to ADRs in `docs/registry/decisions/`) · Risks · Open questions | Created at Design start → frozen at the Design milestone | `plan/template.md` DB/Backend/Frontend sections | #27 |
| `tasks.md` | Implement / `implement` agent | **`task-executor` format** (existing `template-tasks.md`) | Frontmatter (issue, branch, status) · Task checklist with dependencies, each naming the `DES-*` it implements · Deviations from design | Created at Implement start → ticked off as work proceeds → frozen when the PR is ready | `skills/task-executor/template-tasks.md` | #28 |
| `verification.md` | Test / `test` agent | **`verification` skill (new)** | Table: `VER-nnn` · covers `REQ-*` · method (unit / e2e / manual) · result · evidence (CI run, commit) | Created at Test start → updated per test run → frozen at the Test milestone | New | #29 |
| `release.md` | Deploy / `deploy` agent | **per-repo deploy config** (#30) | Version / target · What changed (links to `REQ-*`) · Deploy steps run · How it was confirmed working · Rollback | Created at Deploy start → frozen at the Deploy milestone | New. In this repo: `task release` | #30 |
| `log.md` | All phases / orchestrator | D2 | Frontmatter state · Open items · Key decisions · Entries | Created at session start → appended throughout → frozen at archive | — | this issue |

### Requirements standard (accepted as the **default**; deeper research tracked in a follow-up issue)

- **IDs:** `REQ-001`, `REQ-002`, … They're never reused, and dropped requirements are struck through rather than deleted.
- **Syntax: EARS** (Easy Approach to Requirements Syntax). It's lightweight, and each requirement is one testable sentence. Examples: *"When a session is resumed, the orchestrator shall display the current phase and next step."* · *"The hook shall block writes to files outside the session file set."*
- **Acceptance criteria:** Given/When/Then under each REQ. These feed straight into `verification.md`.
- **Quality checks** from ISO/IEC/IEEE 29148, applied by the `requirements` skill: each requirement must be necessary, unambiguous, verifiable, and implementation-free.

### This session

Done 2026-09-24: `overview.md` renamed to `requirements.md`, and the success criteria rewritten as REQ-001 to REQ-015.

## D2 — Log format ✅ accepted

State lives in frontmatter (`session`, `type`, `issue`, `phase`, `status`, `milestone`, `active_agent`, `next_step`). After it: Open items, then Key decisions (newest first), then append-only entries grouped by phase (`### {date} — {actor} — {event type}: {title}`). There are five event types: `handoff`, `decision`, `attempt`, `milestone`, `note`. Pickup after a break = frontmatter + Open items + Key decisions + the last entry.

## D3 — Orchestrator: start Claude, pick a session

**One implementation, three ways in.** The orchestrator logic lives in one skill (`skills/session/`). All three entry points load that same skill:

| Entry | How | When to use |
|---|---|---|
| **Default for the repo** | Set `"agent": "compass-labs:orchestrator"` in the project's `.claude/settings.json`. Plain `claude` then starts as the orchestrator. | Repos that run everything through sessions. |
| **Explicit** | `claude --agent compass-labs:orchestrator` | Start a session-driven conversation on demand. |
| **From any conversation** | `/compass:session` (also `/compass:session new …`, `resume [slug]`, `status`) | You're already in a normal Claude conversation. |

All three entry points are documented in the **README** ("Using sessions in a repo"), including the snippet for setting the repo default agent (REQ-015).

`agents/orchestrator.md` is a thin wrapper: `skills: [session]`, plus tools that include `Agent`, `Bash(gh *)`, `Read`, `Edit`, `Write`. The command `commands/session.md` loads the same skill. No logic is duplicated.

### Startup flow

```
claude (orchestrator)            SessionStart hook (plugin)
        │                         └─ if agent_type == compass-labs:orchestrator:
        │                              scan docs/sessions/*/log.md frontmatter
        │                              → inject "Active sessions" list as context
        ▼
"Active sessions:
   1. session-lifecycle (#22) — phase: design — next: user decides D1–D7
   2. …
 Resume one, or start a new session?"
        │
   ┌────┴─────────────────────────┐
 resume                          new
   │                               │
 read log.md frontmatter,        ask: title / issue # (or create one) / type (feature)
 Open items, Key decisions,      create folder + log.md + requirements.md (thin)
 last entry → recap to user      gh: label phase:define, comment "session opened"
   │                               │
   └──────────┬────────────────────┘
              ▼
   hand off to current phase agent (D4)
```

- Plugin agents can't set `initialPrompt` (P5), so the list of sessions comes in through a **`SessionStart` hook** that adds context. The orchestrator shows it on its first reply. If the hook can't run, the skill scans the folders itself.
- **"Active sessions"** means any session with `status: active | paused`. Archived sessions are listed only on request (`/compass:session status --all`).

### Main loop (per phase)

1. Hand off to the phase agent with the session path, phase and task. Log a `handoff`.
2. If the agent returns `needs_input`, ask the user and resume the same agent via `SendMessage` with the answers. Repeat until it returns `done`.
3. Append the agent's `log_entries`. Update the frontmatter.
4. **Milestone gate:** show the phase artifact and ask the user to approve it. On approval, freeze the artifact, run the D5 milestone steps, and move to the next phase from the workflow definition.
5. Pause at any time: set `status: paused` and `next_step`, commit, push.

The workflow definition is data in the skill (`workflows/feature.yaml`-style list: `define → design → implement → test → deploy → close`). #24/#25 add new lists rather than changing the orchestrator.

## D4 — Phase agent contract ✅ accepted

The input is the session path, phase, task and user answers. The output is `status` (`done` | `needs_input` | `blocked`), `questions`, `log_entries` and `files_changed`. Each agent writes only its own artifact. For conversational phases, the agent's questions go to the user through the orchestrator, and answers come back via `SendMessage`. **Q6 amended:** agents return log entries, and only the orchestrator writes `log.md`.

## D5 — GitHub integration

**The principle:** the session folder is the source of truth. GitHub is a *view* of it that the orchestrator updates only at milestones. If GitHub is unreachable, the session continues locally and GitHub catches up at the next milestone.

### One-time setup (idempotent, run by `/compass:session` on first use in a repo)

```bash
gh label create phase:define    --color 0E8A16 --force   # …one per SDLC phase
gh label create phase:design    --color 1D76DB --force
gh label create phase:implement --color 5319E7 --force
gh label create phase:test      --color FBCA04 --force
gh label create phase:deploy    --color D93F0B --force
gh label create phase:close     --color 6A737D --force
gh label create type:feature    --color A2EEEF --force
```

### What GitHub records per session

- **One session = one issue.** It's given at `new`, or created by the orchestrator. The number is stored in `log.md` frontmatter.
- **One branch + one PR per session**, created at Implement. The branch holds the session folder, so artifact links work.
- **Labels:** exactly one `phase:*` at a time, plus `type:*`.
- **Comments:** one per milestone, from a fixed template.

### What happens at each milestone

| Milestone (user approves) | Session folder | GitHub |
|---|---|---|
| **Session opened** | create folder, `log.md`, thin `requirements.md` | issue created/linked; `+phase:define +type:feature`; comment "Session opened" |
| **Define complete** | freeze `requirements.md` | issue body replaced with a problem summary + links to the artifacts; `phase:define → phase:design`; milestone comment |
| **Design complete** | freeze `design.md`; ADRs written to the registry | `phase:design → phase:implement`; milestone comment listing ADRs |
| **Implement complete** | `tasks.md` all ticked or deviations logged | PR open and ready for review (`Refs #N`); `phase:implement → phase:test`; comment with PR link |
| **Test complete** | `verification.md`: every `REQ-*` has a passing `VER-*` (the orchestrator's milestone gate checks this before allowing the move to Deploy) | CI status on the PR; `phase:test → phase:deploy`; comment with results summary |
| **Deploy complete** | `release.md` filled | release/tag per repo config (#30); `phase:deploy → phase:close`; comment with version/link |
| **Closed** | fold-back + `git mv` to archive (D6) | PR merged (`Closes #N`); follow-up issues confirmed; final comment; issue closed |

**Anytime:** when a follow-up is deferred, the orchestrator creates the issue straight away using the origin template (parent issue, session path, decision) and logs it (rule from the Define phase).

### Order at each milestone (this avoids links that don't resolve yet, a problem hit in this session)

1. Update the artifact status + `log.md` frontmatter + `milestone` entry
2. `git commit` + `git push`
3. `gh` updates (labels, comment, body), with links pointing at the pushed branch

### Script

`skills/session/scripts/gh-milestone.sh <issue> <from-phase> <to-phase> <comment-file>` handles label swap and comment. It's idempotent: if the labels are already in the target state it's skipped. It reuses the approach from `task-executor/scripts/comment-on-issue.sh`. If `gh` isn't signed in or the network is down, it logs `note: GitHub sync pending` and exits 0. The next milestone runs any pending sync first.

## D6 — Fold-back and archive ✅ accepted

Close agent + `doc-maintainer`: read the artifacts and the Key decisions in `log.md` → update the as-built docs (no session narrative, plus one "Origin: #N" line) → `git mv` to `docs/sessions/archive/` → `status: archived` → close the issue.

## D7 — Enforcement ✅ accepted

A plugin `PreToolUse` hook on `Write|Edit`. Under `docs/sessions/{id}/` it allows only the D1 file set. It blocks Markdown in `assets/`, blocks writes by an agent that doesn't own the file (using `agent_type`), blocks writes to frozen artifacts (per `log.md` frontmatter `milestone`), and blocks everything under `archive/`. It exits with code 2 and gives a reason. It replaces the session check in `validate-spec.sh`.

## D8 — Atomic commit points (added after the Design milestone, 2026-09-24)

**Rule:** each `decision` or `milestone` entry in `log.md` gets exactly one commit, containing that entry plus the artifact changes it describes. A complete set of requirements is recorded as its own `decision` entry. Each ticked task in `tasks.md` gets one commit (code + tick). Drafts still under discussion aren't committed.

**Two layers** (Claude Code rules only guide Claude; hooks enforce):
1. **Guidance:** `.claude/rules/compass-sessions.md` scoped to `paths: docs/sessions/**`. Plugins can't ship `.claude/rules/`, so the orchestrator's one-time setup writes it into the repo from `skills/session/templates/rules/`. The same rule is in the `session` skill.
2. **Enforcement:** `hooks/session-commit-guard.sh` on the **`Stop`** event. If a session's `log.md` has an uncommitted `decision` or `milestone` heading (from `git diff`), it exits with code 2 and a reason, so Claude continues and commits. Loop guard: after 2 blocks in a row it allows the stop (the docs don't mention a built-in guard).

---

## What gets built (plugin components)

| Component | Path | This issue (#22) | Filled out in |
|---|---|---|---|
| Orchestrator skill + Feature workflow definition | `skills/session/SKILL.md`, `skills/session/workflows/feature.*` | ✅ | — |
| Orchestrator agent (thin wrapper) | `agents/orchestrator.md` | ✅ | — |
| Session command | `commands/session.md` | ✅ | — |
| GitHub milestone script + label setup | `skills/session/scripts/gh-milestone.sh`, `gh-setup.sh` | ✅ | — |
| Session-list context hook | `hooks/session-start.sh` + `hooks.json` entry | ✅ | — |
| File-set / ownership / freeze guard | `hooks/session-guard.sh` + `hooks.json` entry | ✅ | — |
| Artifact templates (thin versions of all 6 files) | `skills/session/templates/*.md` | ✅ | — |
| Phase agents | `agents/{define,design,implement,test,deploy,close}.md` | ✅ thin: contract + preloaded skill | #26–#30 |
| `requirements` skill (EARS + 29148 checks) | `skills/requirements/` | thin | #26 |
| `design` skill (from `plan`) | `skills/design/` (or `plan` split up) | thin | #27 |
| Implement skills | `task-executor` format + `skills/{backend,…}/` | reuse | #28 |
| `verification` skill | `skills/verification/` | thin | #29 |
| Deploy config | per-repo | stub | #30 |
| Retire / redirect `plan` | `skills/plan/` → split into `requirements` + `design` | — | #26/#27 |
| Docs | `CLAUDE.md` (add `agents/` to the directory rules), `README.md` | ✅ | — |

**"Done" for #22:** a Feature session can be started, paused, resumed and walked through all six milestones using the thin versions of each artifact and agent. The artifacts are shaped correctly even while their content-writing skills are basic.

---

## Decisions (all accepted 2026-09-24)

| # | Decision | Notes |
|---|---|---|
| D1a | One artifact per phase: `requirements` / `design` / `tasks` / `verification` / `release` + `log` | An artifact can grow into a folder of native artifacts, with the MD file linking to them |
| D1b | Artifacts link by ID (REQ → DES → task → VER); the Test milestone checks every REQ has a passing VER | |
| D1c | Requirements: EARS + Given/When/Then + ISO 29148 checks, as the **default** | Deeper research is a follow-up issue |
| D2 | Log format | |
| D3 | One `session` skill with three entry points and a `SessionStart` session list | Document in the README. Verify `--agent` with a plugin-namespaced agent during implementation |
| D4 | Phase agent contract; only the orchestrator writes the log | |
| D5 | Milestone table, push before `gh`, idempotent script that can catch up later | |
| D6 | Fold-back + `git mv` archive + "Origin" line in as-built docs | |
| D7 | Guard hook: file set, ownership, frozen artifacts, archive | Freeze check added in revision 2. No objection raised |
| D8 | Atomic commit points: rule file + `Stop` commit guard | Added after the milestone by user decision, 2026-09-24 |
