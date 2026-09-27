# Requirements: methods record

> Standard: [requirements](../SKILL.md) · Types: [feature](../types/feature.md), [bugfix](../types/bugfix.md)

This is the verdict record for the requirements candidates in the #32 research (functional requirements, non-functional requirements, acceptance criteria and priority), bounded as agreed in #23 (Scope item 7). Each candidate has one Feature verdict and one Bugfix verdict. Adopt and adapt verdicts say when the method applies and, for Feature, which outcome requirement it serves (the Serves column cites #23's `REQ-023` to `REQ-045`). A Bugfix verdict of "deferred to #40" is settled when Bugfix framing is deepened, and needs no rationale here.

**Verdicts:** *adopt* means the type file uses the method as it is. *Adapt* means the type file uses part of it, as the rationale says. *Reject* means the type file doesn't use it. Every method is still a template, never a mandate: requirements that have the required content pass whatever method produced them. The exceptions are the table rules `check-traceability.sh` depends on, which are conventions, not methods.

## Verdicts

| Method | Group | Feature verdict | Rationale | Applies when | Serves (REQ-023–045) | Bugfix verdict | Bugfix rationale / applies when |
|---|---|---|---|---|---|---|---|
| EARS (5 patterns) | Functional requirements | adopt | One sentence per requirement in one of five fixed patterns keeps rows unambiguous and testable, and the While/When patterns give non-functional requirements their condition. | Every tier, on every requirement row, including the condition part of an NFR | REQ-031 | adopt | Corrected-behaviour rows fit the "If ⟨trigger⟩, then … shall" pattern naturally. Applies to every Bugfix requirement. |
| ISO/IEC/IEEE 29148 quality checks | Functional requirements | adopt | The six checks (necessary, unambiguous, verifiable, implementation-free, consistent, feasible) are the standard test of a single requirement, and "necessary" becomes checkable once each row names what it serves. | Every tier, before a row goes in the table and again before freezing | REQ-033, REQ-037 | adopt | The same checks apply to corrected-behaviour rows. Applies to every Bugfix requirement. |
| User and job stories | Functional requirements | adapt | A story is a good source for a requirement and says who it's for, but it's too loose to test. A story may prompt a row, and the row itself is written in EARS and serves a `NEED-nn` or `OUT-nn`. | Short and full tier, when a need is easiest to explore as a story | REQ-024, REQ-033 | deferred to #40 | — |
| Story mapping | Functional requirements | adapt | Laying stories out by user activity shows gaps and whether every outcome is covered. Only the map as an optional diagram and the coverage idea are used; release slicing belongs to Design and Deploy. | Any tier, as an optional story map; short and full tier for outcome coverage | REQ-034, REQ-043 | deferred to #40 | — |
| Use cases | Functional requirements | reject | Full use-case documents (actors, main and alternate flows, extensions) duplicate what EARS rows and Given/When/Then criteria already say, at several times the length. | — | — | deferred to #40 | — |
| ISO/IEC 25010:2023 | Non-functional requirements | adopt | The nine 2023 quality characteristics are a complete, current checklist, so a missing quality concern is either covered or ruled out with a reason. | Full tier, as the quality coverage table | REQ-030 | deferred to #40 | — |
| SEI quality-attribute scenarios | Non-functional requirements | adapt | Stating an NFR as condition → response → measure makes it testable. The six-part scenario is collapsed: source, stimulus and environment become the condition, written as an EARS While/When clause. | Full tier, on every non-functional requirement | REQ-031 | deferred to #40 | — |
| Planguage | Non-functional requirements | adapt | Scale, Tolerable and Goal give a numeric NFR a measure and two levels without a full specification language. Only those three keywords are used. | Full tier, on every NFR whose measure is numeric | REQ-031 | deferred to #40 | — |
| FURPS+ | Non-functional requirements | reject | An older quality taxonomy that ISO/IEC 25010:2023 supersedes. Using both would give two overlapping checklists. | — | — | deferred to #40 | — |
| Given/When/Then | Acceptance criteria | adopt | One criterion per row, in a form Test can turn straight into a check. It's already the house style and stays unchanged. | Every tier, one per requirement row | REQ-036 | adopt | The criterion reproduces the original failure, so it doubles as the regression check. Applies to every Bugfix requirement. |
| Example Mapping | Acceptance criteria | adapt | Rule → example → question maps onto the table: the rule is the row, the example is the criterion, and questions go to Open questions rather than into a guessed answer. The workshop format and card colours aren't used. | Full tier for concrete criteria; every tier for sending unknowns to Open questions; optional example map diagram | REQ-036, REQ-037, REQ-043 | deferred to #40 | — |
| Specification by Example | Acceptance criteria | adapt | Using a concrete example, with specific values, as the criterion makes it unambiguous. The worked example applies the same idea to the standard itself. Living-documentation tooling isn't used. | Full tier, on every acceptance criterion | REQ-036, REQ-038 | deferred to #40 | — |
| MoSCoW | Priority | adopt | Must, Should, Could and Won't fit a per-row priority column with no scoring, and Won't gives dropped and deferred rows a clear meaning. | Short and full tier, on every live requirement | REQ-032 | deferred to #40 | — |
| Kano | Priority | reject (at requirement level) | Kano classifies features by customer satisfaction from surveys. It's a product-level tool, and there's no survey data behind a single session's rows. | — | — | deferred to #40 | — |
| RICE | Priority | reject (at requirement level) | Reach × impact × confidence ÷ effort ranks backlog items against each other. Within one session's requirements the scores would be guesses, and effort is a Design concern. | — | — | deferred to #40 | — |
| WSJF | Priority | reject (at requirement level) | Weighted shortest job first sequences work across a portfolio by cost of delay. That's a planning decision above a single session's requirements. | — | — | deferred to #40 | — |

Every method the [Feature type file](../types/feature.md) lists has a Feature adopt or adapt verdict above, and every method the [Bugfix type file](../types/bugfix.md) lists (EARS, 29148, Given/When/Then) has a Bugfix adopt verdict.

## Additions

Methods beyond the candidate list, at most three for this section, each naming the gap it fills.

None. The candidate list covers every element the Feature type file requires.

## Deferred

Further method proposals, each with its follow-up issue.

None.
