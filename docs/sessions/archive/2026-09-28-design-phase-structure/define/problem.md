<!-- tier: full -->
# Problem: Design phase structure, with layered design skills and visual deltas

> Part of [index](index.md) · Define

### Context

**Situation:**
- #22 gave every Feature session a Design phase whose agent writes `design.md` from a five-section template: Approach, DES table, Decisions, Risks and Open questions [observed: `skills/session/templates/design.md`, `agents/design.md`].
- #23 then gave Define real depth: framing, per-type standards, tiers and diagrams [observed: ADR-003].
- Separately, the older `plan` skill designs features layer by layer (DB → Backend → Frontend, Prisma, CQRS) and writes its own spec file [observed: `skills/plan/SKILL.md`].

**Complication:**
- Design is now the thinnest conversational phase. Its agent still carries a `TODO (#27)` for a skill that doesn't exist [observed: `agents/design.md`].
- The last session's design had to invent its own visual overview and delta sections to be reviewable [observed: #23 `design.md`].
- Two paths now produce a design (`plan` and the Design phase), with different structures and different stack assumptions [observed: `skills/plan/SKILL.md`, `skills/session/templates/design.md`].
- #28 is about to add per-layer Implement skills with no matching per-layer design to follow [observed: #22 requirements, #28 row].

### Need and stakeholders

- **NEED-01:** When a Feature session reaches the Design gate, the **person approving the design** (the session's user) wants to see how the design fits the process and the project, and what is new, changed, deprecated or unchanged against today, so they can approve or adjust it without reconstructing the delta from prose.
- **NEED-02:** While a solution is being designed, **the session's user and the Design agent** want the design's depth to follow the kind of solution, with each significant choice in each layer made explicitly with its options, pros and cons (for example extending a table versus adding one), so no layer's decision is skipped or made silently.
- **NEED-03:** When Implement starts, **the Implement and Test agents** want a design they can break into tasks and test components without making new design decisions, so what gets built and tested is what was approved.
- **NEED-04:** When changing or extending how design works, **compass-labs maintainers** want one design path, which later solution kinds and layers extend without rewriting it, so `plan`, Design and #28's layer skills don't drift apart.
- **NEED-05:** When a design builds on earlier work (a feature researched before, an established pattern, a recorded decision), **the session's user** wants Design to take that knowledge from the project's current documentation, not from past session folders, so the design rests on what is true now rather than on superseded session narrative.
- **NEED-06:** When reviewing a design, **the person approving it** wants every component to be as simple as the requirements allow and actually needed, so no speculative or over-engineered parts get built.

### Evidence

- The Design template has five sections and no visuals, no delta and no per-layer structure [observed: `skills/session/templates/design.md`].
- The Design agent has no skill to follow: "once the `design` skill exists (split out of `plan`), preload it here" [observed: `agents/design.md`, TODO (#27)].
- #23's design added "Visual overview", "What's new, changed, superseded and unchanged" and "Current vs new standards" sections that aren't in the template [observed: `docs/sessions/archive/2026-09-25-define-phase-depth/design.md`].
- Reviewers can't see how a design fits the process or project, or what is new, changed, deprecated or unchanged, from prose and tables [observed: #39].
- `plan` hard-codes DB → Backend → Frontend, Prisma models and CQRS naming, and writes `overview.md` outside the session's artifact set [observed: `skills/plan/SKILL.md`, Phases 2–5].
- #22 planned to split `plan` into `requirements` and `design`. Define's half was done in #23, and Design's half is still open [observed: #22 design, "Retire / redirect `plan`" row; ADR-003].
- The user finds Design "too light" and wants per-layer depth [observed: user brief, `log.md` "session opened"].
- Without a standard, design depth depends on how the agent improvises in each session [assumed].
- A layer choice such as extending the schema versus adding a table is sometimes made without options being written down [assumed; no session record shows either way].
- The Implement agent will need to make design decisions itself when the design lacks per-item results or checks [assumed; no session has run Implement against a thin design yet].
- Past session folders must not be Design's source of prior knowledge, because reading them "corrupts context" [observed: user, Define gate adjust feedback]. How the corruption happens is **assumed**: a session folder records drafts, rejected options and decisions later changed, and the Close fold-back (ADR-003 D14) rewrites only what stayed true into the Diátaxis docs.
- Close folds each session's still-true content into `docs/explanation`, `docs/reference` and `docs/registry`, and session IDs never appear there [observed: ADR-003 D14].
- Close doesn't fold back when those Diátaxis trees are missing [observed: #45, as relayed by the orchestrator].
- Nothing in the current Design agent or template stops it from reading `docs/sessions/archive/**` [observed: `agents/design.md`, `skills/session/templates/design.md`].
- Design should always follow SOLID, YAGNI and KISS, especially for software [observed: user, Define gate adjust feedback]. No current design artifact records a check against any design principle [observed: `skills/session/templates/design.md`; `skills/plan/SKILL.md` names none].

### Impact and why now

- **If nothing changes:**
  - every Feature session's design keeps varying with the agent's improvisation [assumed], and reviewers keep reconstructing the delta themselves [observed: #39];
  - `plan` and Design keep producing two differently shaped specs [observed: `skills/plan/SKILL.md`];
  - #28's layer skills get built with no layer design to follow [assumed].
- **Why now:**
  - Define's depth has just landed (#23, merged in `db34939`), so Design is the next phase in the lifecycle build-out (#26–#30) [observed: git log];
  - #28's per-layer Implement skills need the per-layer structure this work sets [observed: user decision Q6].

### Success outcomes

| Outcome | Signal | Target | Checked when | For need |
|---|---|---|---|---|
| OUT-01 | Two checks on the approver's view. First, the share of elements the design touches that appear in the context view and delta list with exactly one delta status (new, changed, deprecated, unchanged). Second, any Design-gate "adjust" feedback in `log.md` that asks what changes. | 100% of touched elements shown with a status; no "what changes?" adjust request | At the Design gate of the first Feature session opened after this work ships | NEED-01 |
| OUT-02 | The number of significant choices in the whole-system and layer designs that record fewer than two options with pros and cons, or that name no chosen option and reason | 0 | At the Design gate of the first three-tier Feature session opened after this work ships | NEED-02 |
| OUT-03 | The number of Implement tasks or "Deviations from design" entries in that session's `tasks.md` that record a design decision the design didn't make | 0 (tolerable: 1) | At the Implement milestone of the first Feature session opened after this work ships | NEED-03 |
| OUT-04 | The number of plugin skills that produce a solution design or spec document | 1 (the Design path), from 2 today | At this session's Test gate, by inspecting `skills/` | NEED-04 |
| OUT-05 | The Design phase's reads of any path under `docs/sessions/` outside the current session folder, counted from the Design agent's tool calls | 0 | At the Design gate of the first Feature session opened after this work ships | NEED-05 |
| OUT-06 | The number of `DES-*` items or significant choices with no recorded KISS/YAGNI check (plus SOLID for software), or that serve no live `REQ-*` | 0 | At the Design gate of the first Feature session opened after this work ships | NEED-06 |

### Appetite and no-gos

- **Appetite:** two focused days for this session. The sub-issues and follow-ups in the [Deferred table](requirements.md#deferred) aren't included.
- **No-gos:** see [Non-goals](index.md#non-goals).
