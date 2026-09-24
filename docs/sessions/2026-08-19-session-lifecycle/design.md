# Design: Session Lifecycle

> Phase: Design | Started: 2026-09-24 | Status: Draft. D1–D7 are proposals waiting for decisions.
> Problem statement: [`overview.md`](overview.md) · Session history: [`log.md`](log.md)

Scope for this issue is the **Feature** session type only (Q4). Each phase's skills and documents are built in #26–#29.

---

## Platform facts (checked against Claude Code docs, 2026-09-24)

These are the platform limits the design has to work within. Sources: `code.claude.com/docs/en/sub-agents`, `/plugins-reference`, `/workflows`.

| # | Fact | What it means for the design |
|---|---|---|
| P1 | Subagents **can** start other subagents, up to 3 levels below the main session (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`). | **C7 was wrong** and is corrected in `overview.md`. Being unable to nest is *not* why the orchestrator runs in the main session. |
| P2 | Subagents **can't use `AskUserQuestion`**. They run on their own and return only a final summary. | **This is the real reason for Q2.** Only the main session can talk to the user, so Define and Design (both conversations) have to go through it. |
| P3 | Subagents start with a fresh context: their own system prompt, the task message, CLAUDE.md, git status, and preloaded `skills:`. | Phase agents know only what they're told and what's on disk. The session folder path has to be passed in explicitly (C2). |
| P4 | A subagent can be resumed with `SendMessage` and keeps its history, **but only within the same Claude Code session**. | Useful inside a phase. Anything that has to survive a two-day break must be on disk (C3). |
| P5 | Plugins can ship `agents/` (namespaced `compass-labs:<name>`). Plugin agents **ignore `hooks`, `mcpServers`, `permissionMode`**. | Phase agents can ship with the plugin. Enforcement has to use plugin-level `hooks/hooks.json`, not hooks defined on an agent. |
| P6 | `PreToolUse` hooks can block a tool call. `SubagentStart` / `SubagentStop` events exist. | The fixed file set can be enforced mechanically (C1). Logging handoffs automatically is possible later (#31). |
| P7 | Workflows (JS scripts that run many subagents) can't take user input mid-run, and can only be resumed within the same session. Plugins can ship `workflows/`. | They don't fit the orchestrator of a session that spans several days. They could fit fan-out *inside* a non-interactive phase (Implement per layer, Test per area). Deferred to #28/#29. |
| P8 | Any agent can run *as* the main session via `claude --agent <name>` or the `agent` setting. | One option for the orchestrator (see D3). |

---

## D1 — Session folder file set (Feature, first version)

```
docs/sessions/{date}-{slug}/
  problem.md    # Define: problem statement, requirements, acceptance criteria. Owner: Define
  design.md     # Design: the fix and its decisions, links to ADRs.            Owner: Design
  log.md        # State + decisions summary + handoff/decision entries.         Owner: orchestrator (see D4)
  assets/       # optional; non-Markdown only (images, diagrams, data)
```

- **Three Markdown files, and that's all.** Implement, Test and Deploy don't get their own files yet. Their outputs are code, PRs and test runs, recorded as log entries. #28/#29 can add a file if a real session needs one (Q5: the file set grows as needed).
- **Rename `overview.md` → `problem.md`.** The old name was used when one file held both the problem and the design. With Define and Design split, the names should say which file belongs to which phase. The references to update (`plan` skill, `validate-spec.sh`, `doc-maintainer`) are being reworked in #26/#27 anyway.
- **Keep `27e8c1b`.** "Create the session file at Intake" still fits: Define creates `problem.md` on the first question.
- **Artifacts outside the session folder:** ADRs keep living in `docs/registry/decisions/` (they're already as-built docs) and are linked from `design.md`.

## D2 — Log format

```markdown
---
session: 2026-08-19-session-lifecycle
type: feature
issue: 22
phase: design            # define | design | implement | test | deploy | close
status: active           # active | paused | closed | archived
milestone: define        # last completed milestone
active_agent: main
next_step: "…"
---
# Session Log: {title}

## Open items
- …

## Key decisions
- {date}: one line per decision, newest first

---
## Phase: Define
### {date} — {actor} — {event type}: {title}
- **From → To:** orchestrator → define-agent        (handoffs only)
- **Input:** …   **Output:** files / commits / issues
- **Notes:** what was tried, what was dropped and why
```

- **State goes in frontmatter.** It's machine-readable, so hooks and the orchestrator can parse it, and GitHub shows it as a table. It's the single source of session state (Q8). The human-facing block in the current `log.md` gets replaced by this.
- **Event types:** `handoff`, `decision`, `attempt` (tried or dropped), `milestone`, `note`. Every `decision` also gets a line under Key decisions.
- **Append-only body.** Only the frontmatter, Open items and Key decisions are ever rewritten.
- **Pickup test (Q10):** someone resuming after two days reads the frontmatter, Open items and Key decisions, plus the last entry. That's enough to continue without reading the whole log.

## D3 — Orchestrator

**Runs in the main session (P2).** Two ways to do that:

| Option | How | For | Against |
|---|---|---|---|
| **A. Command + skill** (recommended) | `/compass:session new <issue\|description>`, `/compass:session resume [slug]`, `/compass:session status`. A skill whose instructions make the main session act as orchestrator. | Works in any existing conversation. Matches how the plugin is used today. No restart. | The orchestrator's rules share context with everything else in the session. |
| B. Main-session agent | `claude --agent compass-labs:orchestrator` | Clean system prompt and restricted tools for the whole session. | Needs a restart for each session. Replaces the default Claude Code prompt for the whole session. |

**What it does** (only these, per C8):
1. Create a session folder (nothing else creates one) or resume one. On resume it reads `log.md` frontmatter.
2. Pick the workflow for the session type. The **Feature** workflow is an ordered list of phases stored as *data*, so #24/#25 add Bugfix/Research workflows without changing the orchestrator.
3. Hand off to the phase agent with its context (D4).
4. Pass questions to the user and answers back to the agent (D4).
5. Append log entries, update state, and get the user's sign-off at each milestone.
6. Update the GitHub milestone (D5).

## D4 — Phase agent contract

**Every phase agent** is a plugin subagent (`agents/define.md`, `agents/design.md`, …) with restricted `tools` and preloaded `skills:`.

- **Input** (from the orchestrator): session folder path, phase, task, and any user answers.
- **Output** (returned as structured text):
  - `status`: `done` | `needs_input` | `blocked`
  - `questions`: for the user, when `needs_input`
  - `log_entries`: in the D2 format
  - `files_changed`: only files this agent owns
- **Writes only its own file** (Q6).

**Conversational phases (Define, Design): passing questions through the orchestrator.** Because of P2, the agent drafts, then returns `needs_input` with its questions. The orchestrator asks the user and resumes the *same* agent with `SendMessage`, carrying the answers (P4). If the conversation is interrupted, a fresh agent rebuilds context from `problem.md`/`design.md` + `log.md`. This keeps Define and Design as separate agents (Q3) while the user only ever talks to the orchestrator.

**Proposed amendment to Q6: agents *return* log entries, and only the orchestrator writes `log.md`.** Q6 said every agent writes to the log. But agents running in parallel (Implement fan-out, P7) would conflict writing to the same file, and a single writer keeps the format consistent. The log still records every agent's handoffs and decisions. Only the actual file write moves to the orchestrator.

**Non-interactive phases (Implement, Test, Deploy):** plain subagents, possibly with fan-out inside the phase. Details are in #28/#29/#30.

## D5 — GitHub milestones (Q13)

| Option | Fit |
|---|---|
| **Labels `phase:define` … `phase:close`** (recommended), one active at a time, plus a milestone comment linking to `log.md` | Works on any issue with or without a Project. Easy for the orchestrator to set with `gh issue edit`. |
| GitHub Project status field | Better board view, but needs a Project for every session. Could be added later. |
| GitHub native Milestones | Wrong fit: those are repo-wide release buckets, not per-issue phases. |

Only milestones are mirrored, not every handoff (Q8).

## D6 — Fold-back and archive (Q7, Q12)

Close phase, run by a Close agent using `doc-maintainer`:
1. Read `problem.md`, `design.md` and the Key decisions in `log.md`.
2. Update as-built docs (`docs/reference/`, `docs/explanation/`, registry `planned → built`). No session narrative in them (C5).
3. `git mv docs/sessions/{id} docs/sessions/archive/{id}`, set `status: archived`, add the final log entry, close the issue.

Open: should as-built docs get a single "Origin: #22" line pointing back to the archived session? It's traceable without adding narrative. (Recommended.)

## D7 — Enforcement (C1)

A plugin-level `PreToolUse` hook on `Write|Edit` (P5, P6) that:
- **blocks** any file under `docs/sessions/{id}/` other than `problem.md`, `design.md`, `log.md`, `assets/**`
- **blocks** Markdown in `assets/`
- **blocks** every write under `docs/sessions/archive/` (archived sessions are frozen)

- **blocks writes by the wrong agent.** Plugin hooks fire inside subagents too, and the hook input includes `agent_type` (verified 2026-09-24, `docs/en/hooks`). So the hook can enforce Q6 ownership: `compass-labs:define` → only `problem.md`, `compass-labs:design` → only `design.md`, main session (no `agent_id`) → only `log.md`.

It blocks by exiting with code 2 and printing a reason to stderr. It replaces the session-folder check in `validate-spec.sh`, whose required DB/Backend/Frontend sections no longer apply (#27).

---

## Decisions needed

| # | Decision | Recommendation |
|---|---|---|
| D1 | File set `problem.md` / `design.md` / `log.md` / `assets/`, and rename `overview.md` → `problem.md` | Yes |
| D2 | Log format: state in frontmatter, append-only entries, five event types | Yes |
| D3 | Orchestrator as command + skill (A) or main-session agent (B) | A |
| D4 | Questions passed through the orchestrator for Define/Design; **Q6 amendment**: only the orchestrator writes `log.md` | Yes / Yes |
| D5 | `phase:*` labels + milestone comment | Yes |
| D6 | Archive via `git mv`; "Origin" backlink line in as-built docs | Yes / Yes |
| D7 | `PreToolUse` hook enforcing both the file set and file ownership | Yes (checked: hooks fire inside subagents) |
