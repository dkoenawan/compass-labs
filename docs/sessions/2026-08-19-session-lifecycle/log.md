---
session: 2026-08-19-session-lifecycle
type: feature
issue: 22
phase: implement
status: active
milestone: design
active_agent: main (manual, since no orchestrator exists yet)
next_step: "User approves tasks.md order; then start task 1 (artifact templates)"
---
# Session Log: Session Lifecycle (#22)

> Format: D2 (accepted 2026-09-24). Only the orchestrator writes this file; for now that's the main session. Entries are append-only.
> Artifacts: [`requirements.md`](requirements.md) (frozen) · [`design.md`](design.md) (frozen) · [`tasks.md`](tasks.md) · Follow-ups: #24–#32

## Open items

- Task 8: verify `claude --agent` works with a plugin-namespaced agent
- Deploy for this repo is a plugin release in a separate session (Q9). The version bump isn't part of Implement

## Key decisions

- **2026-09-24**: ✅ Design milestone reached. D1a (one artifact per phase; an artifact can grow into a folder of native artifacts), D1b (ID links), D1c (EARS as the default; research in #32), D3 (three entry points, documented in the README), D5 accepted. No separate implementation guide: `tasks.md` is the Implement artifact.
- **2026-09-24**: D2 (log format), D4 (phase agent contract, including the Q6 amendment: only the orchestrator writes the log), D6 (fold-back + archive), D7 (enforcement hook) accepted.
- **2026-09-24**: ✅ Define milestone reached. C7 corrected: subagents can nest; the real limit is that they can't ask the user questions.
- **2026-09-24**: Deferred work goes into tracked issues (#24–#31), each linked back to this session.
- **2026-09-24**: Feature is the only session type for now. GitHub shows one milestone per SDLC phase. Archived sessions go to `docs/sessions/archive/`.
- **2026-09-24**: An orchestrator in the main session starts one subagent per phase. Define and Design are separate phases. Each file has one agent that writes it, except this log, which every agent writes to.
- **2026-09-24**: Reframed #22 from a design into a problem statement. The skill-driven design was dropped.
- **2026-08-19**: First design: the `plan` skill drives the whole session. The session file is created at Intake. *(Superseded.)*

---

## Phase: Define

### 2026-08-18 — Issue opened
- #22 opened after a design discussion. It proposed a 10-node lifecycle with `plan` as the only driver and 11 `stage:*` labels.

### 2026-08-19 — First spec (`plan` skill)
- `ce5721b`: spec written with 3 layers (state model, skill wiring, research agent).
- `27e8c1b`: `plan` skill changed so the session file is created at Intake, not after approval. **Still on the branch. Whether to keep it is a Design question.**

### 2026-09-24 — Review and first revision (dropped)
- Reviewed the branch: only one implementation step from the spec had been done.
- `a02a9ad`: tracked the leftover session docs, and ignored `graphify-out/` except `GRAPH_REPORT.md`.
- User raised two core problems: (1) skills are doing agent work and nothing closes the loop; (2) there's no session doc lifecycle, and the iteration record is mixed up with the as-built docs.
- Claude rewrote the spec as a four-subagent design. **Dropped (never committed).** User: "We are jumping into solutioning a little bit too quick." It didn't cover orchestration, different pacing per session type, a separate Define phase, or too many files.

### 2026-09-24 — Problem statement
- Spec rewritten as a problem statement only: current state, what's wrong, constraints, non-goals, open questions, success criteria.
- Evidence found: `hooks/validate-spec.sh` requires DB/Backend/Frontend sections, which neither session folder meets.

### 2026-09-24 — Decisions, round 1 (`e1e895e`)
- Q1 add an orchestrator · Q2 it runs in the main session · Q3 Define and Design are separate · Q5 the file set will evolve · Q6 one agent writes each file, except the log · Q7 fold back at close, then archive · Q8 state lives in the session folder · Q9 Deploy depends on the repo.
- New constraint C8: single responsibility. A file that keeps growing should be split.
- New problems added: 2.5 (each phase keeps a standard document up to date), 2.6 (the conversation must be recorded).

### 2026-09-24 — Decisions, round 2 (`a7f6fe1`)
- Q4 Feature only · Q10 the log records every handoff and decision so someone can pick up cleanly · Q11 start from `plan`/`adr`, then build one phase at a time · Q12 `docs/sessions/archive/` · Q13 one milestone per SDLC phase · Q14 deferred.
- New rule: future problems become GitHub issues linked back to this session.
- Follow-up issues created: #24 Bugfix, #25 Research, #26 Define, #27 Design, #28 Implement, #29 Test, #30 Deploy config, #31 Hook automation.

### 2026-09-24 — ✅ Milestone: Define complete
- Problem statement agreed. #22's description rewritten to match. Branch pushed.
- **Handoff:** Define → Design (both in the main session).

---

## Phase: Design

### 2026-09-24 — Design started
- Order: (1) session folder file set + log format, (2) orchestrator, (3) phase agent contract, (4) milestone mechanism, (5) fold-back and archive.

### 2026-09-24 — Platform check (docs: sub-agents, plugins-reference, workflows, hooks)
- **C7 was wrong:** subagents can nest up to 3 levels. `overview.md` corrected.
- **The real constraint:** subagents can't use `AskUserQuestion`, so Define and Design have to talk to the user through the main session. Q2 still holds, for a different reason.
- Workflows can't pause for user input mid-run and can only be resumed within the same Claude Code session. **Dropped as the orchestrator.** Kept as a candidate for fan-out inside a phase (#28/#29).
- Plugin agents ignore `hooks`/`permissionMode`, but plugin-level hooks fire inside subagents and report `agent_type`. That makes file-ownership enforcement possible (D7).

### 2026-09-24 — First design draft (`design.md`, D1–D7)
- D1: file set `problem.md` / `design.md` / `log.md` / `assets/`. Rename `overview.md` → `problem.md`.
- D2: log keeps state in frontmatter; entries append-only.
- D3: orchestrator as a command + skill (recommended) vs. a main-session agent.
- D4: phase agents return questions for the orchestrator to ask the user. **Proposed amendment to Q6:** only the orchestrator writes `log.md`, to avoid clashes from agents writing in parallel.
- D5: `phase:*` labels. D6: `git mv` to `archive/`. D7: `PreToolUse` hook enforcing the file set and file ownership.
- **Waiting on:** user decisions on D1–D7.

### 2026-09-24 — user — decision: design review round 1
- **Accepted:** D2 log format, D4 phase agent contract (including the Q6 amendment), D6 fold-back + archive, D7 enforcement.
- **Sent back:**
  - D1 is too thin: every SDLC phase should produce an artifact, even a thin one, and Define should produce requirements that follow a standard (via a requirements skill).
  - D3: can the user just start Claude as the orchestrator and pick new/previous sessions?
  - D5 is too thin: it isn't clear what actually gets implemented on GitHub.

### 2026-09-24 — main — attempt: design revision 2 (`design.md`)
- Checked: there's no `requirements` skill in the repo. `plan/template.md` is almost all design. `task-executor/template-tasks.md` works as the Implement artifact.
- D1 → one artifact per phase: `requirements.md` / `design.md` / `tasks.md` / `verification.md` / `release.md` + `log.md`. Linked by ID (REQ → DES → task → VER). Proposed standard: EARS + Given/When/Then + ISO 29148 quality checks. Each artifact is frozen at its milestone.
- D3 → one `session` skill with three ways in: repo default `agent` setting, `claude --agent compass-labs:orchestrator`, `/compass:session`. The list of sessions comes from a `SessionStart` hook, because plugin agents can't set `initialPrompt`.
- D5 → a table of GitHub actions per milestone, commit+push before each `gh` call, and an idempotent `gh-milestone.sh` that can catch up later. One issue + one branch/PR per session.
- D7 extended: also blocks writes to frozen artifacts (**needs user confirmation**, since D7 was already accepted).
- Added a "What gets built" section that separates what's in scope for #22 from what's in #26–#30.
- Converted this log to the D2 format.

### 2026-09-24 — user — decision: design review round 2
- **D1a accepted**, with a refinement: as phases mature, an artifact may become a folder of native artifacts (e.g. a Playwright report) that the MD file links to. Recorded on #29.
- **D1b, D1c accepted.** EARS is the default. Deeper research is deferred to **#32**.
- **D3 accepted.** All three entry points go in the README.
- **D5 accepted.** No objection to the D7 freeze extension or the Q6 amendment.
- User asked: "Do you need a separate implementation guide, or can we proceed?" Answer: no separate guide. By D1, `tasks.md` is the Implement artifact.

### 2026-09-24 — main — note: Define artifact brought in line with D1
- Renamed `overview.md` → `requirements.md`, and rewrote the success criteria as REQ-001 to REQ-015 (EARS + Given/When/Then). The problem statement and decisions are unchanged. This was done under this entry's decision; the guard doesn't exist yet.
- Added a traceability table to `design.md` (D1–D7 → REQ).

### 2026-09-24 — main — milestone: ✅ Design complete
- `design.md` frozen. `tasks.md` created (13 tasks, task-executor format, each tagged with D-ids and REQ-ids).
- **Handoff:** Design → Implement (main session, manual).
