# Feature requirements

> Standard: [requirements](../SKILL.md) · Methods: [reference/methods.md](../reference/methods.md) · Diagrams: [reference/diagrams.md](../reference/diagrams.md) · Worked example: [feature-full](../examples/feature-full/index.md)

Feature requirements go deeper by tier, beyond the shared rules (EARS, one Given/When/Then, the 29148 checks). The framing step's confirmed tier sets which elements are required. In a Feature session they live in `define/`: the `REQ-*` table and the Deferred table in `define/requirements.md`; quality coverage, NFR measures, and assumptions and dependencies in `define/quality.md`; Open questions in `define/index.md`.

## Tier table

| Element | Skip | Short | Full | Where |
|---|---|---|---|---|
| [Requirement sentence](#requirement-sentence) (EARS) | ✓ | ✓ | ✓ | `requirements.md` |
| [Priority](#priority) column | — (may be "—") | ✓ | ✓ | `requirements.md` |
| [Deferred table](#deferred-table) | ✓ | ✓ | ✓ | `requirements.md` |
| [Serves](#serves-and-outcome-coverage) column | — (may be "—") | ✓ | ✓ | `requirements.md` |
| [Outcome coverage](#serves-and-outcome-coverage) | — | ✓ | ✓ | checklist |
| [NFR form](#nfr-form) | — | — | ✓ | `requirements.md`, `quality.md` |
| [Quality coverage](#quality-coverage) (ISO/IEC 25010:2023) | — | — | ✓ | `quality.md` |
| [Assumptions and dependencies](#assumptions-and-dependencies) | — | — | ✓ | `quality.md` |
| [Acceptance criterion](#acceptance-criterion) | ✓ | ✓ | ✓, built from a concrete example | `requirements.md` |
| [Unknowns](#unknowns) to Open questions | ✓ | ✓ | ✓ | `index.md` |
| [Checklist](#checklist) | ✓ | ✓ | ✓ | — |
| Diagram: [traceability](#diagrams-this-section-owns) | — | — | ✓ | `diagrams.md` |

The short and skip rows require no diagram. The tier is a floor, not a ceiling: when the work calls for it and the user agrees, include a full-tier element at a lower tier.

## Table columns

```text
| ID | Requirement | Priority | Serves | Acceptance criterion |
```

`ID` stays the first column: `check-traceability.sh` reads only that column, from lines matching `^\| *REQ-[0-9]+`. So:

- **Extra columns are safe.** Priority and Serves sit after `ID`, and the gate never reads them.
- **Struck-through rows** (`| ~~REQ-nnn~~ |`) don't match the pattern, so dropped rows and "never" Won'ts need no `VER-*`.
- **Deferred rows** start with the follow-up issue (`| #nnn |`) and carry the requirement's ID in the second column, so they don't match either. A deferred requirement needs no `VER-*`.
- **Other tables can't clash.** The success outcomes, quality coverage, NFR measures and assumptions all live in other files the gate never reads, so `quality.md`'s NFR measures table can start its rows with `REQ-nnn`. Inside `requirements.md`, the `REQ-*` table is the only table whose rows start with `REQ-`.

## Elements

### Requirement sentence

- **Must contain:** one EARS sentence per row, as in the shared rules.
- **Optional templates:** EARS, 5 patterns (adopt). A user or job story (adapt) may be where a row comes from, but the row itself is written in EARS.

### Priority

- **Must contain:** exactly one of `Must`, `Should`, `Could` or `Won't` on every live row (short and full tier).
- **A Won't is never a live row.** A live Won't would need a passing `VER-*` at the Test gate. So it takes one of two forms:
  - **"We will never do this":** strike the row through in the table, with its reason.
  - **"Not this session, later":** move it to the [Deferred table](#deferred-table), with its follow-up issue.
- **Method:** MoSCoW (adopt).
- A Could that isn't delivered after the freeze is struck through, or moved to the Deferred table, by a logged decision.

### Deferred table

```text
## Deferred

| Follow-up | Was | Requirement | Reason |
```

- **Must contain:** one row per requirement moved to later work. The **follow-up issue link (`#nnn`) is required and comes first**; `Was` holds the requirement's ID in this session; the table says "None" when empty.
- The column order is fixed, because the gate depends on it (the row must not start with `REQ-`).
- Deferred work becomes a linked GitHub issue. The orchestrator creates it, so ask for it through `needs_input` and record the number it gives you.
- **Bad:** `| | REQ-007 | Export to PDF | later |` (no issue). **Good:** `| #88 | REQ-007 | Members can export a page to PDF | Out of this session's appetite |`.

### Serves and outcome coverage

- **Serves must contain:** one or more `OUT-nn` or `NEED-nn` IDs, each of which exists in `problem.md` (short and full tier). This makes 29148's "necessary" traceable (adopt).
- **Outcome coverage:** every `OUT-nn` appears in at least one live row's Serves cell. It's a checklist item, and at full tier the traceability diagram shows it too. Story mapping (adapt) can help find a gap, as an optional story map.
- **Bad:** Serves `better UX`. **Good:** Serves `OUT-01, NEED-02`.

### NFR form

Full tier, on every non-functional requirement.

- **Must contain:** the Requirement cell states the **condition** (the trigger and the environment) and the **response**. `quality.md`'s NFR measures table gives the row's **scale**, **Tolerable** and **Goal**; Tolerable and Goal are required when the measure is numeric.
- **Default form:** an EARS While/When clause, then the response, then `Measure: see quality.md`.
- **Methods:** SEI quality-attribute scenario (adapt: source, stimulus and environment collapse into the condition). Planguage (adapt: Scale, Tolerable and Goal only).
- **Bad:** "The reset page shall be fast." **Good:** "While the wiki serves up to 200 concurrent members, when a member submits the reset form, the wiki shall send the reset email. Measure: see quality.md." with `| REQ-005 | seconds from submit to email accepted by the email service, 95th percentile | 60 | 10 |`.

### Quality coverage

Full tier, in `quality.md`.

- **Must contain:** each of the nine ISO/IEC 25010:2023 characteristics — functional suitability, performance efficiency, compatibility, interaction capability, reliability, security, maintainability, flexibility and safety — either covered by at least one `REQ-*`, or not applicable with a one-line reason.
- **Default layout:** `Characteristic | Covered by | Not applicable because`.
- **Method:** ISO/IEC 25010:2023 (adopt). The quality utility tree is an optional diagram.
- Whether an N/A reason actually says why is the reviewer's call. "N/A" alone fails.

### Assumptions and dependencies

Full tier, in `quality.md`.

- **Must contain:** two lists, each non-empty or explicitly "none". Each dependency (external work, a system or a decision) names what relies on it, for example "relied on by REQ-004".

### Acceptance criterion

- **Must contain:** one Given/When/Then per row, as in the shared rules. At full tier it's built from **one concrete example**, with specific starting state or input values and the specific expected result.
- **Methods:** Given/When/Then (adopt). Example Mapping (adapt: the rule is the row, the example is the criterion, and questions go to Open questions). Specification by Example (adapt: the example is the criterion).
- **Bad:** "Given a user, when they reset their password, then it works." **Good:** "Given member `ana@example.org` with a link issued at 10:00, when she opens it at 10:20 and sets `Tide-Pool-42`, then she can log in with `Tide-Pool-42` and the old password is refused."

### Unknowns

- **Must contain:** a question about a requirement or its criterion that can't be answered yet goes to `index.md`'s Open questions, and no criterion asserts a result for it. This applies at every tier.
- **Method:** Example Mapping's question cards (adapt).

## Checklist

Every tier: the six 29148 checks from the shared rules, one EARS sentence and one Given/When/Then per row, and unknowns in Open questions.

Short and full tier add:

- [ ] Every live row has exactly one of Must, Should or Could; no live Won't.
- [ ] Every "later" Won't is in the Deferred table with a real `#nnn` first; every "never" Won't is struck through with its reason.
- [ ] Every live row's Serves names at least one `OUT-nn` or `NEED-nn` that exists in `problem.md`.
- [ ] Every `OUT-nn` is served by at least one live row.

Full tier adds:

- [ ] Every acceptance criterion uses specific values or states, not only placeholders.
- [ ] Every NFR states its condition and response, and has a row in NFR measures, with Tolerable and Goal when numeric.
- [ ] All nine 25010:2023 characteristics are covered or N/A with a reason.
- [ ] Assumptions and dependencies are listed, or "none", and each dependency names what relies on it.
- [ ] The traceability diagram is in `diagrams.md`.

## Diagrams this section owns

At full tier these go in `define/diagrams.md`; see the [catalogue](../reference/diagrams.md) for each one's Mermaid type, check, example and the rendering rules.

- **Traceability diagram** (required at full tier): every `OUT-nn` linked to the live `REQ-nnn` that serve it. Pick `requirementDiagram` or `flowchart LR`, whichever is easier to review. If it's still too big to review after splitting per outcome, ask the user whether the feature should be two sessions.
- **Story map**, **quality utility tree**, **priority quadrant** and **example map** (optional at any tier).

## Methods applied

Every method this file uses has a Feature **adopt** or **adapt** verdict in [reference/methods.md](../reference/methods.md), with its rationale and when it applies: EARS, 29148, user and job stories, story mapping, ISO/IEC 25010:2023, SEI quality-attribute scenarios, Planguage, Given/When/Then, Example Mapping, Specification by Example and MoSCoW. Use cases, FURPS+, Kano, RICE and WSJF are rejected.

## Worked example

[`examples/feature-full/`](../examples/feature-full/index.md) is a complete full-tier `define/` folder for self-service password reset on a team wiki. It meets every element above, and it's also the fixture `tests/session/check_traceability_test.sh` runs the gate on.
