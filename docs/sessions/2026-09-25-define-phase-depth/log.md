---
session: 2026-09-25-define-phase-depth
type: feature
issue: 23
phase: define
status: active
# milestone: the PHASE KEY of the last completed milestone, not a display
# label. Allowed values (feature workflow): none | define | design |
# implement | test | deploy | close. "none" until the first milestone
# (Define complete) is reached. The guard hook (D7) uses this key, plus
# each phase's `order` in workflows/<type>.json, to decide which
# artifacts are frozen. Display labels (e.g. "Define complete") live only
# in workflows/<type>.json's `milestone` field, for GitHub comments.
milestone: none
active_agent: main
next_step: "Define milestone gate: skip-tier question + approve REQ-001..022"
---
# Session Log: Define phase depth — problem framing, per-type standards, project anchoring (#23)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`requirements.md`](requirements.md) · [`design.md`](design.md) · [`tasks.md`](tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- #38: `init` should set up the project anchor (vision and mission) when a project is created. Blocked by this session's anchor contract.
- #37: the session skill's new-session flow should create a branch before its first commit/push. Deferred, out of scope here.
- `origin/main` now has `912634c`, which reverts the session-open commit `d38c99c`. Before this branch's first push, merge `origin/main` into it and keep the branch's session files, so the PR doesn't delete them.
- Issue #23's title and body still describe the original, narrower proposal (a Q0 problem-framing step in `skills/plan/SKILL.md`). Rewrite both once Define's problem statement is agreed.

## Key decisions

- **2026-09-25**: Skip tier skips every framing check, including anchor verdict and anchor creation (REQs unchanged)
- **2026-09-25**: Anchor contract: one labelled authoritative statement in persistent project docs; vision + mission + scope required, non-goals optional; create/complete once with approval (REQ-018..022); REQ-012 struck
- **2026-09-25**: Project anchor split: this session defines the anchor contract (vision + mission) and framing creates it once if missing (supersedes the per-session ask fallback); init establishing it at project creation deferred to #38
- **2026-09-25**: Framing answers folded into requirements.md: "extends" verdict applied before the framing milestone; Close fold-back unchanged (non-goal); user confirms each session's depth tier
- **2026-09-25**: Session skill should branch before its first commit/push; deferred to #37
- **2026-09-25**: Framing open questions settled: full refresh of compass-labs README + solution-design in this session; owed anchor update made at framing time; no-anchor fallback = ask user for 1–2 sentence purpose, recorded in session; framing effort scales with size of work (in scope)
- **2026-09-25**: Framing standards are one skill per artifact section (problem statement, requirements), with standards picked by session type
- **2026-09-25**: Project anchor = README + docs/explanation/solution-design.md; registry/ADRs are overlap/conflict context only; "extends" owes an anchor update
- **2026-09-25**: Generalise the problem-framing step (not a Define phase) across session types; Feature + Bugfix concrete here, Research gets an extension point only (#25)
- **2026-09-25**: Session absorbs #26 (Define standard) and #32 (requirements methodology research); plan skill rework is out of scope
- **2026-09-25**: Session opened on existing issue #23, broadened from "plan skill Q0 problem framing" to the depth of the Define phase as a whole (three threads below)

---

## Phase: Define

### 2026-09-25 — main — decision: session opened on #23 with broadened scope
- The user picked up #23 and said it needs updating now that the session lifecycle (#22) has shipped. The Define phase is currently thin. They raised three threads:
  1. **Broaden beyond SDLC.** Define was framed around software delivery, but sessions now cover other activities (for example Research, per #24/#25). How should Define generalise across session types?
  2. **Get specific per variation.** Start with SDLC work (feature, bugfix). What makes a good problem statement, and what makes good requirements? Break down the relevant standards and give each one its own skill.
  3. **Anchor to the project.** Every feature definition should be anchored to the repository as a whole. There's a core README, so when does a feature align with the project's existing framing, and when does it extend it?
- #23's original research (XY problem, SCQ/Minto, Genchi Genbutsu symptom-vs-cause split, 5 Whys caveats, JTBD, PR-FAQ) and its Q0 full/short/skip proposal carry forward as input material, not as an agreed solution.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (agree problem statement for three threads)
- **Input:** session `docs/sessions/2026-09-25-define-phase-depth/`, phase define; task: turn the three threads plus #23's original research into an agreed problem statement, scope/non-goals and constraints first (problem before solution), then REQ-* requirements. Issue #23 body is at hand for the original research.
- **Output:** needs_input (4 framing questions); files_changed: none

### 2026-09-25 — compass-labs:define — note: current-state review before problem framing
- Read define.md, the requirements skill, the requirements template, session SKILL.md, feature.json, plan SKILL.md, README, docs/explanation (solution-design, session, plan), docs/registry/index.md, and the archived session's follow-up table.
- Findings: Define has no framing or discovery guidance and doesn't read project context. The requirements skill covers only the REQ table. Artifacts are Feature-only, and the planned Bugfix workflow (#24) has no Define phase. The README and solution-design are stale ("Systematic Dev Kit", full-stack framing). Plan's discovery overlaps Define and its layer design overlaps Design. #26 (Define standard) and #32 (requirements research) overlap this session's scope.
- Asked the user 4 framing questions (issue absorption and plan, generalisation unit and types, project anchor, standards granularity) before drafting a problem statement.

### 2026-09-25 — main — decision: framing answers (scope, generalisation, anchor, granularity)
- **Scope:** absorb #26 and #32. The plan skill isn't reworked here.
- **Generalisation:** the thing that generalises is the problem-framing step, not a Define phase. Feature and Bugfix are done concretely in this session. Research gets an extension point only, with the rest deferred to #25. No other session types for now.
- **Anchor:** README plus docs/explanation/solution-design.md. The registry and ADRs are checked only for overlap or conflict. An "extends" verdict means an anchor update is owed. A repo with no anchor gets a defined fallback.
- **Granularity:** one skill per artifact section (problem statement, requirements), each picking its standards by session type.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (draft problem framing from answers)
- **Input:** the four answers above. Task: draft the Problem statement, Scope, Non-goals, Constraints and Open questions in requirements.md. No REQ rows until the framing is agreed.
- **Output:** done (framing draft for review); files_changed: requirements.md

### 2026-09-25 — compass-labs:define — attempt: framing draft written for review
- Filled in Problem statement, Scope, Non-goals, Constraints and Open questions in requirements.md from the user's answers: absorb #26 and #32; generalise the framing step, not a Define phase; Feature and Bugfix concrete, Research as an extension point only; anchor is the README plus solution-design, with the registry and ADRs checked only for overlap or conflict; one skill per artifact section.
- Fixed #32's boundary in Scope item 6 and Constraints: a named candidate list with at most 3 additions per section, an adopt/adapt/reject verdict for each of Feature and Bugfix, and the research is done when every candidate has one.
- No REQ rows yet. 4 open questions await the user: fixing compass-labs' own stale anchor docs, when an owed anchor update is made, the no-anchor fallback, and scaling framing effort to the size of the work.

### 2026-09-25 — main — note: session moved to branch feat/23-define-phase-depth
- The user asked for session work to go on a new branch, not `main`. The opening commit `d38c99c` had already been pushed to `origin/main`, and it's now also part of the branch's history. Whether to revert it on `main` is still open (see Open items). Local `main` has been reset to `origin/main`.

### 2026-09-25 — main — decision: framing open questions settled
- **Stale anchor docs:** refresh compass-labs' README and `solution-design.md` fully in this session (not the agent's suggested middle path).
- **When an owed anchor update happens:** at framing time, before anything is built. This isn't the agent's lean either; nothing waits for Close.
- **No-anchor fallback:** the framing step asks the user for a 1–2 sentence project purpose and records it in the session's own artifact. It never creates project docs.
- **Scaling:** how much framing is done scales with the size of the work (full, short or skip), and this is in scope.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (fold in open-question answers, draft REQ rows)
- **Input:** the four answers above. Task: update Scope, Non-goals and Open questions to match, then draft REQ rows in EARS form with Given/When/Then criteria.
- **Output:** done (REQ-001 to REQ-017, ready for Define milestone review); files_changed: requirements.md

### 2026-09-25 — main — note: reverted session-open commit on main
- The user asked for the revert to follow best practice. I added `912634c` to `origin/main` with `git revert` (no history rewrite, no force-push), working in a temporary worktree so this branch's working tree wasn't touched.
- Still to do: the branch contains `d38c99c`, and `main` now reverts it. Before the first push, merge `origin/main` into the branch and resolve the modify/delete conflict by keeping the branch's files.

### 2026-09-25 — main — decision: defer session-skill branching fix to #37
- The session skill's New session flow commits and pushes the opening commit without creating a branch, which is how `d38c99c` reached `main`. Fixing the skill is outside this session's scope, so I opened #37 to track it.

### 2026-09-25 — compass-labs:define — decision: framing answers folded into requirements.md
- A full refresh of README.md and solution-design.md is in scope (Scope item 8), done in Implement.
- An "extends" verdict is settled during framing: the anchor update is agreed with the user and applied before the framing milestone is approved. Close's fold-back is unchanged, which is now a non-goal.
- No-anchor fallback: ask for a 1–2 sentence purpose, record it in the session artifact, and never create project docs.
- Depth tiers (full, short, skip) are in scope. The user confirms each session's tier.

### 2026-09-25 — compass-labs:define — attempt: REQ-001 to REQ-017 drafted for Define milestone review
- 17 EARS requirements, each with one Given/When/Then, covering Scope items 1–8, including the #32 research (REQ-014, REQ-015) and the anchor refresh (REQ-016, REQ-017). Each was checked against the ISO 29148 quality checklist.
- For the user to confirm at the gate: checks don't run at skip tier; REQ-011 leaves who applies the anchor update to Design; the refresh needs the user to approve a new purpose statement.

### 2026-09-25 — main — decision: project anchor is established once, not asked per session; init work split to #38
- The user interrupted the Define gate. Compass is meant to be a verbose, general workflow for any kind of work, not only full-stack development. A project's vision and mission should be anchored once, during init, and created if they don't exist, so the user doesn't have to restate them every session.
- Split, as the user chose. **This session** defines the anchor contract: what the vision and mission must state, and where the anchor lives. The framing step reads the anchor, and if it's missing, framing creates it once with the user's approval and commits it. This **supersedes** the earlier fallback of asking every session and never creating project docs (REQ-012 as drafted). The compass-labs README and solution-design refresh (REQ-016/017) is the first anchor written to the contract. **Deferred to #38:** `init` sets up the anchor at project creation (greenfield and brownfield-migrate). Related to #19.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (revise anchor requirements for the split)
- **Input:** the decision above. Task: strike REQ-012 through, add requirements for the anchor contract and for create-if-missing, align REQ-016/017 to the contract, update Scope, Non-goals (#38) and Constraints. Also raise the skip-tier question (whether checks are skipped at skip tier) as an open question.
- **Output:** done after one restart. A rate limit interrupted the first run, and I resumed the same agent with SendMessage. files_changed: requirements.md

### 2026-09-25 — compass-labs:define — decision: project anchoring reframed as an anchor contract, created once
- The user reframed anchoring. A project's vision and mission are recorded once, in an anchor that meets a contract, and created if they don't exist, so they're never restated each session. Compass is a general workflow, not only for full-stack development.
- Anchor contract: one authoritative, labelled statement in the project's persistent docs. Vision, mission and scope are required; non-goals are optional and checked when present. The exact location and layout are left to Design (REQ-018, REQ-019).
- Create or complete if missing, once, with the user's approval, as persistent project docs (REQ-020, REQ-021). Reuse without restating (REQ-022). REQ-012's per-session fallback is dropped (struck through).
- compass-labs' README and solution-design refresh becomes the first anchor written to the contract (REQ-016, REQ-017).
- Anchor setup in `init` for new and existing projects is deferred to #38 (related #19).

### 2026-09-25 — compass-labs:define — attempt: requirements.md revised and ready for the Define milestone gate
- Updated Problem statement, Scope item 6 and item 8, Non-goals (#38) and Constraints (general-workflow constraint added, "never create project docs" wording removed). Added REQ-018 to REQ-022, revised REQ-010, 013, 016 and 017, and struck through REQ-012.
- One open question for the user: whether skip tier skips all framing checks, including the anchor ones. Lean: yes.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (resolve skip-tier question, mark approved)
- **Input:** the user chose "skip everything" at skip tier and approved the Define milestone. Task: mark the open question resolved and set the status line to Approved. Change nothing else.
- **Output:** done; files_changed: requirements.md

### 2026-09-25 — compass-labs:define — decision: skip tier skips all framing checks, including anchor checks
- The user took the lean: at skip tier, framing skips every check, including the aligns/extends verdict and anchor creation or completion (REQ-020, REQ-021). A missing anchor is created at the next full- or short-tier session.
- The REQs already say this (REQ-005, 006, 010, 013, 020 and 021 run only at full or short tier), so they're unchanged. The open question is marked resolved in requirements.md.

### 2026-09-25 — compass-labs:define — note: requirements.md marked approved, ready to freeze
- Status line set to "Approved (Define complete 2026-09-25)" on the user's approval relayed by the orchestrator. Open questions: all resolved.
- Final set: REQ-001 to REQ-022, with REQ-012 struck through (replaced by REQ-020 and REQ-021). For Design to pick up: who writes the anchor to project docs (REQ-011, 020, 021), since the phase-agent contract limits Define to its own artifact.
