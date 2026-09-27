# Feature problem statement

> Standard: [problem-statement](../SKILL.md) · Methods: [reference/methods.md](../reference/methods.md) · Diagrams: [requirements/reference/diagrams.md](../../requirements/reference/diagrams.md) · Worked example: [feature-full](../../requirements/examples/feature-full/index.md)

A Feature problem statement goes deeper by tier. The framing step's confirmed tier sets which elements are required. A Feature session's framing artifact is the `define/` folder: the skip-tier paragraph goes in `define/index.md`, and at short and full tier each element is a `###` heading in `define/problem.md`, with a short summary in `index.md` that names the `NEED-nn` and `OUT-nn` IDs and links to `problem.md` without repeating them.

## Tier table

| Element | Skip | Short | Full | Where |
|---|---|---|---|---|
| [One paragraph](#one-paragraph-skip) | ✓ | — | — | `index.md` |
| [Context](#context) | — | — | ✓ | `problem.md` |
| [Need and stakeholders](#need-and-stakeholders) | — | ✓ | ✓ | `problem.md` |
| [Evidence](#evidence) | — | ✓ | ✓ | `problem.md` |
| [Impact and why now](#impact-and-why-now) | — | — | ✓ | `problem.md` |
| [Success outcomes](#success-outcomes) | — | ✓ | ✓ | `problem.md` |
| [Appetite and no-gos](#appetite-and-no-gos) | — | — | ✓ | `problem.md` |
| Diagrams: [impact map, context, as-is/to-be](#diagrams-this-section-owns) | — | — | ✓ | `diagrams.md` |

The short and skip rows require no diagram. The tier is a floor, not a ceiling: when the work calls for it and the user agrees, include a full-tier element at short tier.

Only the **Must contain** column below is checked. The optional templates and example layouts are defaults; plain prose that has the content passes.

## Elements

### One paragraph (skip)

- **Must contain:** what's wrong, for whom, and why it matters, in two to four sentences, with no design or solution talk.
- **Checked by:** a reader can say who has the problem and why it matters.
- **Bad:** "Add a dark-mode toggle."
- **Good:** "People who read the docs at night find the white pages glaring, and several have asked for a darker theme in the issue tracker."

### Context

- **Must contain:** the **situation** (what's true today) and the **complication** (what has changed or gone wrong), each in at least one sentence of its own.
- **Checked by:** the situation and the complication can each be pointed to.
- **Optional template (SCQ/Minto, adopt):** "Situation: … Complication: …". The *question* is left implicit, because the XY check has already turned it into the need.
- **Bad:** "Password resets are a problem."
- **Good:** "Situation: wiki admins reset forgotten passwords by hand from the admin panel. Complication: the team doubled this year, and resets now wait up to a day for an admin."

### Need and stakeholders

- **Must contain:** one `NEED-nn` line per need, each naming a **specific stakeholder group** (not only "users"), **when** the need arises, the **need**, and the **outcome** they want. A fix the issue pre-chose isn't a need: it moves to `framing.md`'s candidate solutions (the XY check).
- **Checked by:** every need names a group, a situation, a need and an outcome. Whether the group is specific enough is the reviewer's call.
- **Optional template (job story, adopt):** "**NEED-01:** When ⟨situation⟩, ⟨group⟩ wants to ⟨need⟩, so they can ⟨outcome⟩."
- **Bad:** "Users want a reset button."
- **Good:** "**NEED-01:** When a wiki member forgets their password outside office hours, they want to regain access themselves, so they can keep working without waiting for an admin."

### Evidence

- **Must contain:** every claim about the problem tagged **observed**, with its source (issue, report, data or quote), or **assumed**. None is untagged.
- **Checked by:** no untagged claim. The symptom/cause check feeds this: the symptom is observed, and the cause stays assumed until it's shown.
- **Optional template (observed/assumed evidence, adopt):** `- {claim} [observed: {source}]` and `- {claim} [assumed]`.
- **Bad:** "Resets take too long."
- **Good:** "Reset requests waited 9 hours on average in March [observed: admin panel export, #212]. Most requests come in outside office hours [assumed]."

### Impact and why now

- **Must contain:** who or what is affected if nothing changes, and how; and at least one reason it's timely now.
- **Checked by:** both parts are present.
- **Optional template:** none mandated. SCQ's complication often supplies the "why now".
- **Bad:** "It would be nice to fix this."
- **Good:** "If nothing changes, locked-out members lose up to a working day, and admins keep spending about two hours a week on resets. Now, because the team doubles again next quarter."

### Success outcomes

- **Must contain:** at least one outcome, with IDs `OUT-01`, `OUT-02` and so on. Each names an observable or measurable **signal**, a **target** value or state, **when** it's checked, and the **need** it serves. No bare goals like "better UX".
- **Checked by:** every outcome has a signal, a target and a check point, and names an existing `NEED-nn`. Every outcome is later served by at least one requirement (the requirements standard's Serves column).
- **Optional template (Impact Mapping goal level, adapt):** a table `Outcome | Signal | Target | Checked when | For need`. An Opportunity Solution Tree's desired outcome (adapt, optional) works too.
- **Bad:** "OUT-01: faster resets."
- **Good:** "OUT-01 | median time from reset request to regained access | under 10 minutes | 30 days after release, from the auth log | NEED-01".

### Appetite and no-gos

- **Must contain:** the **appetite**, as an amount of effort or time (a budget, not an estimate); and the **no-gos**, listed here or by a link to `index.md`'s Non-goals.
- **Checked by:** the appetite is an amount; the no-gos are listed or linked.
- **Optional template (Shape Up appetite and no-gos, adapt):** "Appetite: two weeks for one developer. No-gos: see [Non-goals](index.md#non-goals)."
- **Bad:** "As soon as possible."
- **Good:** "Appetite: one week. No-gos: no SMS reset, no change to how admins create accounts."

## Diagrams this section owns

At full tier these go in `define/diagrams.md`. The catalogue in [requirements/reference/diagrams.md](../../requirements/reference/diagrams.md) gives each diagram's Mermaid type, what it must show, its check, an example and the rendering rules.

- **Impact map** (required at full tier): each `OUT-nn` → stakeholder → behaviour change → `REQ-nnn`.
- **Context diagram** (required at full tier): the work in scope, every stakeholder group from the `NEED-nn` rows and every external system named.
- **As-is / to-be** (required at full tier when an existing process changes).
- **Customer journey** and **opportunity solution tree** (optional at any tier).

## Methods applied

Every method this file uses has a Feature **adopt** or **adapt** verdict in [reference/methods.md](../reference/methods.md), with its rationale and when it applies: the XY problem, SCQ/Minto, job stories, observed/assumed evidence, symptom vs cause, Impact Mapping, the Opportunity Solution Tree, and Shape Up's appetite and no-gos. 5 Whys and PR-FAQ are rejected for Feature.

## Checklist

Short and full tier:

- [ ] Every need is a `NEED-nn` line naming a specific group, when the need arises, the need, and the outcome they want.
- [ ] No pre-chosen fix is stated as the need; any is in `framing.md`'s candidate solutions.
- [ ] Every claim about the problem is tagged observed (with a source) or assumed.
- [ ] At least one `OUT-nn`, each with a signal, a target, when it's checked, and the need it serves.

Full tier adds:

- [ ] Context has a situation and a complication.
- [ ] Impact says who or what is affected if nothing changes, and gives a reason it's timely now.
- [ ] Appetite is an amount of effort or time, and no-gos are listed or linked.
- [ ] The impact map, context diagram and (when a process changes) as-is/to-be are in `diagrams.md`.

## Worked example

[`requirements/examples/feature-full/`](../../requirements/examples/feature-full/index.md) is a complete full-tier `define/` folder for self-service password reset on a team wiki. Its `problem.md` shows every element above.
