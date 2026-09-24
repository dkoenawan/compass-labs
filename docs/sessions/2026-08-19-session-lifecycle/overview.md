# Problem Statement: Session Lifecycle

> Date: 2026-08-19 | Revised: 2026-09-24 | Status: Draft — problem definition + first decisions, no design yet
> Relates to: Issue #22 — Design and implement full session lifecycle (GitHub-tracked, Diataxis-linked)

## Why this is a problem statement, not a spec

Two earlier drafts of this file jumped to a design: first "`plan` skill drives everything," then "four phase subagents plus a Close step." Both were premature, since neither dealt with the problems below. Both drafts are in git history (`ce5721b`, and the uncommitted 2026-09-24 rewrite). This version only defines the problem, the constraints and the open questions. Design starts once we agree on this.

---

## Problem 1 — The repo can't take a session from start to finish

### Current state (verified 2026-09-24)

- `plan` is a skill that produces a spec and then stops. Nothing hands off to it or from it.
- `skills/backend/`, `skills/frontend/`, `skills/database/`, `skills/infrastructure/` are empty directories.
- `commands/` has only `hello.md`, a test command. No lifecycle phase has a command.
- `hooks/` has `validate-spec.sh` (checks spec sections on Write) and `post-commit` (reminds you to bump the version). Neither knows about lifecycle stages.
- `task-executor` is the only component that runs multi-step work on its own (via cron). It's tied to one flow (issue → tasks → PR).

So a session can be planned, but every step after that is manual.

### What's wrong

1. **Skills are doing agent work.** A skill is a capability: explore a codebase, write an ADR, run tests. Driving a session through its phases is a different job: keep track of where things are, decide what comes next, hand off. That job has no owner today.
2. **Nothing owns the loop itself.** Even with agents for each phase, something has to sequence them, track progress and decide when a session is done.
3. **Different kinds of work have different cadences.** One fixed loop doesn't fit them:

   | Session type | Rough shape |
   |---|---|
   | Feature | Define → Design → Implement → Test → Deploy → Close |
   | Bugfix | Reproduce → Fix → Verify → Close |
   | Research / spike | Question → Investigate → Synthesize → Decide → Close |
   | Migration / chore | Scope → Execute → Verify → Close (e.g. `2026-08-17-compass-rename`, which is already a run sheet rather than a spec) |

   Evidence the current approach already breaks: `validate-spec.sh` requires "Database Layer / Backend Layer / Frontend Layer" sections in every session `overview.md`. Neither session folder in the repo matches that structure.
4. **Planning mixes two jobs.** Understanding the problem (what's wrong, for whom, what "done" means) and designing the fix (architecture, tradeoffs, ADRs) have different inputs, outputs and approval points. Today they're one pass.

---

## Problem 2 — Session docs have no defined lifecycle

### Current state

- A session gets one `overview.md`, created at Intake (`27e8c1b`) and edited in place until approved.
- There's no record of what was tried, what was dropped, or why a decision changed. Edits overwrite earlier content.
- There's no defined step that turns a finished session into as-built documentation (`docs/reference/`, `docs/explanation/`, `docs/registry/`).

### What's wrong

1. **No written evolution model.** Nothing says which documents exist at which phase, who writes them, when they're frozen, or how they relate to each other.
2. **Agents create too many files.** Left alone, agents write a new MD for every step, attempt or summary. After a few sessions you get hundreds of files with duplicated content, no hierarchy and no clear source of truth. This is the problem we most need to prevent, and prompt instructions alone won't prevent it.
3. **Two kinds of content are mixed together:**
   - The **iteration record**: in order, including dead ends and reasoning. Valuable because it's honest.
   - The **as-built docs**: flat, current truth, no story. Valuable because they're clean.

   One file can't be both, and today neither is defined.
4. **Fold-back is undefined.** It's not specified when iteration content becomes as-built docs, who does it, or what happens to the session folder afterwards.
5. **Each phase has standard documents that nobody keeps up to date.** Every Define phase should produce the same kind of requirements document, and every Design phase the same kind of design document. They should be updated throughout the session as understanding changes, not written once at the end and never touched again. Today there's no defined set of these documents and no rule that they stay current.
6. **Nothing records the conversation.** Decisions get made in conversation, like the ones in this document. If nobody writes them down with a summary of what changed and why, they're lost when the conversation ends.

---

## Constraints (any solution must satisfy these)

1. **Bounded session folder.** Each session has a small, fixed set of files. Agents can't create new files. Enforcement is mechanical (e.g. a hook), not just prompt instructions.
2. **One session, one folder.** Agents hold no state between invocations, but every agent in a session reads and writes the same session folder. No agent discovers or creates a session on its own.
3. **Resumable.** A session can pause (end of conversation, cron gap) and any agent can pick it up from what's in the session folder. Nothing depends on conversation memory.
4. **State lives in the session folder.** GitHub only mirrors key milestones, not every phase change.
5. **Flat as-built docs.** Folded-back docs contain no session narrative. The "why" stays in the archived session.
6. **Works as a distributable plugin.** Everything ships through the plugin structure (`skills/`, `commands/`, `hooks/`, and possibly `agents/`). No per-user setup beyond installing.
7. **Platform limits.** Subagents can't start other subagents, so the orchestrator runs in the main session and starts the phase subagents from there. **Still to verify against current Claude Code docs.**
8. **Single responsibility (SOLID).** Each agent and skill does one job. If an agent or skill file keeps growing, that's a sign it's doing more than one job and should be split.

## Non-goals (for this issue)

- Building every phase skill (backend, frontend, test domains). This issue defines the lifecycle they plug into, not their contents.
- Automating stage transitions with hooks. Deferred until agent handoffs work manually.
- Migrating existing session folders to a new structure.

---

## Decisions (2026-09-24)

| # | Question | Decision |
|---|---|---|
| Q1 | Do we need a lifecycle orchestrator above the phase agents? | **Yes.** It picks the workflow for the session type and owns the session folder. |
| Q2 | Where does the orchestrator run? | **In the main session.** It starts the phase subagents from there (see C7). |
| Q3 | Is planning one phase or two? | **Two: Define (requirements) and Design**, each with its own agent. The split follows the single-responsibility rule (C8). |
| Q5 | What's the fixed file set in a session folder? | **Will evolve.** Start small and add files only when a real session needs one. Each phase's standard documents (Problem 2.5) are the starting candidates. |
| Q6 | Does each file have a single owning agent? | **Yes, except the log.** The log is hierarchical and shared: every agent writes to it. |
| Q7 | When does fold-back happen, and what happens to the session folder? | **At session close.** The log and phase documents are summarized into as-built docs, then the session folder is **archived**: kept for reference but no longer active. |
| Q8 | Where does session state live? | **In the session folder.** GitHub only records key milestones. |
| Q9 | What does "Deploy" mean? | **It depends on the repo.** Here it means releasing the plugin, run as its own session in a separate conversation. In a full-stack project it's a real deployment specific to that repo. The Deploy phase has to be configurable per repo, not hard-coded. |

## Open questions

| # | Question | Notes |
|---|---|---|
| Q4 | Which session types (workflows) do we support first? | Leaning Feature + Bugfix, with Research second. |
| Q10 | What does the hierarchical log look like? | For example: session → phase → entry, with a running summary at the top of the most important decisions and changes (Problem 2.6). Still needs a precise structure and clear rules for what goes into the summary and what goes into entries. |
| Q11 | What are the standard documents for each phase? | Define → requirements. Design → design doc (plus ADRs?). Implement / Test / Deploy → to be decided. This list becomes the first version of the file set (Q5). |
| Q12 | Where do archived sessions go, and how are they marked? | For example, `docs/sessions/archive/` or a status flag. Archived sessions must not get mixed up with active ones. |
| Q13 | Which milestones get mirrored to GitHub? | For example: session opened, design approved, implementation merged, session closed. This replaces the earlier 11-label `stage:*` taxonomy. |
| Q14 | How does a repo tell the Deploy phase what "deploy" means? | Config file, a skill specific to the repo, or a Taskfile target? |

## Success criteria (how we'll know a solution works)

- A Feature session and a Bugfix session each run from intake to close without manual steps between phases.
- Every session folder has the defined file set. Trying to create any other file is blocked.
- Each phase's documents reflect current understanding at every point in the session, not just at the end.
- The log's summary shows the key decisions at a glance, and its entries show what was tried and why things changed.
- After close, as-built docs are updated with no session narrative, and the session folder is archived.
- A session paused mid-phase resumes correctly in a new conversation using only what's in the session folder.
- No agent or skill file does more than one job. Anything that grew past that has been split.
