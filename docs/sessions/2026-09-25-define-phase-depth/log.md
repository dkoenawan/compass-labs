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
next_step: "Hand off to compass-labs:define to agree the problem statement for the three threads"
---
# Session Log: Define phase depth — problem framing, per-type standards, project anchoring (#23)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`requirements.md`](requirements.md) · [`design.md`](design.md) · [`tasks.md`](tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- Issue #23's title and body still describe the original, narrower proposal (a Q0 problem-framing step in `skills/plan/SKILL.md`). Rewrite both once Define's problem statement is agreed.

## Key decisions

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
