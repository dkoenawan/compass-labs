# Session Log: Session Lifecycle (#22)

> This log is append-only and every agent writes to it. The format is provisional (Q10) and will be finalized in the Design phase.

## Current state

| | |
|---|---|
| **Phase** | Design (started 2026-09-24) |
| **Active agent** | Main session (no orchestrator exists yet; this session runs by hand) |
| **Last milestone** | ✅ Define complete (2026-09-24): problem statement and decisions agreed |
| **Next step** | User reviews `design.md` D1–D7 and decides |
| **Open items** | D1–D7 decisions; Q6 amendment (only the orchestrator writes the log) |
| **Session docs** | [`overview.md`](overview.md) (problem statement, Define) · [`design.md`](design.md) (Design) |
| **Follow-ups** | #24–#31 |

## Key decisions (summary)

The most important changes, newest first. Full reasoning is in the entries below.

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
