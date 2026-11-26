# Framing: tiers, checks, anchor contract and the framing block

> → Concepts: [Framing overview](../../explanation/framing/overview.md) · → [Session workflow and artifacts](../session/workflow-and-artifacts.md)
> Origin: #23

The procedure itself is in [`skills/framing/SKILL.md`](../../../skills/framing/SKILL.md). This page lists the facts other docs and tools rely on, and links to the skill files that define them.

## Depth tiers

Framing proposes one tier with a one-line reason, and the user confirms it. The confirmed tier and its reason are recorded in the framing artifact's main doc (`define/index.md` for Feature). The tier is a floor, not a ceiling: a higher-tier element can be included when the user agrees.

| Tier | Used when |
|---|---|
| `full` | The work adds or changes a capability, crosses several components or contracts, changes a process people follow, or carries real risk of solving the wrong problem |
| `short` | The work is contained and its problem mostly clear, but the need, evidence and success measure are still worth checking |
| `skip` | The work is so small or mechanical that framing would cost more than it saves |

## Checks by tier

| Check | full | short | skip |
|---|---|---|---|
| Propose a tier; record the confirmed tier and reason | runs | runs | runs |
| Solution-first (XY): the need behind a requested fix; the fix is confirmed as the need or recorded as a candidate solution | runs | runs | skipped |
| Symptom vs cause: the observed symptom recorded apart from the cause, which is named or recorded as unknown | runs | runs | skipped |
| Anchor: locate and assess (outcome `complete`, `incomplete` or `missing`) | runs | runs | skipped |
| Anchor: draft the missing or failing elements | runs when missing or incomplete | runs when missing or incomplete | skipped |
| Anchor: `aligns` or `extends` verdict, citing the scope and non-goal lines it rests on; an anchor update when it extends | runs | runs | skipped |
| Registry and ADR overlap and conflict | runs where a registry or ADRs exist | runs where a registry or ADRs exist | skipped |

At skip tier every check is skipped, the anchor checks included. A missing anchor is created at the next full- or short-tier session. A complete anchor is used as it stands, with no anchor questions to the user. The verdict cites only the anchor, never the registry.

## Feature content by tier

Which sections each tier requires is set by the standards skills' type files. Each has a tier table and a checklist:

| Section | Standard | Skip | Short adds | Full adds |
|---|---|---|---|---|
| Problem statement | [`problem-statement/types/feature.md`](../../../skills/problem-statement/types/feature.md) | One paragraph in `index.md` | Need and stakeholders, tagged evidence, measurable success outcomes | Context (situation and complication), impact and why now, appetite and no-gos |
| Requirements | [`requirements/types/feature.md`](../../../skills/requirements/types/feature.md) | EARS rows, one Given/When/Then each, the Deferred table | MoSCoW priority and a Serves trace on every row; every outcome served | ISO/IEC 25010:2023 coverage, NFR measures with Tolerable and Goal levels, assumptions and dependencies, criteria built from concrete examples |
| Diagrams | [`requirements/reference/diagrams.md`](../../../skills/requirements/reference/diagrams.md) | None required | None required | Impact map, context diagram, traceability diagram, and as-is/to-be when a process changes |

- Every diagram is Mermaid of a type GitHub renders. Six optional diagram types (customer journey, opportunity solution tree, story map, quality utility tree, priority quadrant, example map) are never required.
- Named frameworks (SCQ, job stories, Shape Up and the rest) are offered as templates. A definition that has the required content passes, whatever its form.
- The verdict behind every method is in each skill's `reference/methods.md`: [problem statement](../../../skills/problem-statement/reference/methods.md), [requirements](../../../skills/requirements/reference/methods.md).
- A worked full-tier Feature definition is in [`requirements/examples/feature-full/`](../../../skills/requirements/examples/feature-full/index.md).
- Bugfix type files exist in both standards skills at a shallower depth (#40).

## Anchor contract

The full contract is [`skills/framing/reference/anchor-contract.md`](../../../skills/framing/reference/anchor-contract.md). In summary:

| Aspect | Fact |
|---|---|
| Location | The consuming repo's root `README.md`. Creating the anchor creates the README if there isn't one. |
| Form | A `## Project anchor` heading with `### Vision`, `### Mission`, `### Scope` and optionally `### Non-goals`, in that order, between one `<!-- compass:anchor -->` line and one `<!-- /compass:anchor -->` line |
| Required elements | Vision, mission and scope, each non-empty. Non-goals are optional, but an empty `### Non-goals` heading fails. |
| Restatements | Any restatement of an anchor element elsewhere in the README, or in a doc it links to, must match the anchor or link to it |
| Assessment | `complete` (every checklist item passes), `incomplete` (markers found, an item fails, including a duplicate or unpaired marker), `missing` (no README or no markers) |
| Who writes it | The orchestrator only, from the agreed text in the framing record's anchor-update block (action `create`, `complete`, `extend` or `none`). Only the named elements are written. |

The contract assumes no tech stack, kind of work or `docs/` layout. compass-labs' own anchor is in its [README](../../../README.md#project-anchor).

## The framing block

A session type plugs into framing through a `framing` block in `skills/session/workflows/{type}.json`. The guard hook doesn't read it.

| Field | Meaning | Feature's value |
|---|---|---|
| `run_in_phase` | The phase that runs framing. The phase is named only here, never in the framing skill. | `"define"` |
| `produces` | The framing artifact: a file, or a folder ending in `/`. It must be that phase's `artifact`. | `"define/"` |
| `standards` | The standards skills that apply, one per artifact section | `["compass-labs:problem-statement", "compass-labs:requirements"]` |
| `type_file` | The per-type file each standards skill reads: `types/{type_file}.md` | `"feature"` |
| `tiers` | The depth tiers this type allows | `["full", "short", "skip"]` |

Besides the block, a session type supplies templates for its framing artifact, a `types/{type_file}.md` with a tier table in each standards skill it lists, and an owner agent for the `run_in_phase` phase that preloads `framing` and those standards. The list is in the skill's [What a session type supplies](../../../skills/framing/SKILL.md#what-a-session-type-supplies) section.
