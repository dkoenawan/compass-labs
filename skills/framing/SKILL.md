---
name: framing
description: The shared problem-framing step every session type runs before writing its problem statement and requirements. Proposes a depth tier (full, short or skip), then runs the checks that tier needs, solution-first (XY), symptom vs cause, the project anchor and registry/ADR overlap, and records the outcomes in the session type's framing artifact. Names no phase; each session type plugs in through a `framing` block in its workflow.
---

# Framing Skill

Framing makes sure a session solves the right problem before anyone writes requirements for it. Without it, a session takes the issue's wording at face value, so its requirements can be precise about the wrong thing: a fix the user picked too early, a symptom mistaken for its cause, work that already exists, or work that quietly widens the project.

This skill is defined once and **names no phase**. The workflow of each session type decides which of its phases runs framing and what framing produces (see [What a session type supplies](#what-a-session-type-supplies)). Everything below applies to every session type; the content of the problem statement and requirements comes from the standards skills the type lists.

## Procedure

1. **Read the type's `framing` block** in `${CLAUDE_PLUGIN_ROOT}/skills/session/workflows/{type}.json`: the artifact framing produces, the standards skills that apply, the per-type file name and the tiers allowed.
2. **Propose a depth tier** from the allowed tiers, with a one-line reason drawn from the issue and the size of the work (see [Depth tiers](#depth-tiers)). Ask the user to confirm it: as a phase agent, you return `needs_input`, and the orchestrator asks. Use the tier the user confirms, and record it and its reason in the framing artifact's main doc.
3. **Run the checks for the confirmed tier**, in the order in the [check × tier table](#check--tier). Skip tier runs none of them.
4. **Record each check's outcome** in the framing artifact, where the type's templates put it. A check that finds nothing still records that it ran ("none found", "aligns", "the fix is the need").
5. **Hand over to the standards.** Write the problem statement and requirements to the confirmed tier, following each standards skill's `types/{type_file}.md`.

## Depth tiers

| Tier | Use it when | Example |
|---|---|---|
| **full** | The work adds or changes a capability, crosses several components or contracts, changes a process people follow, or carries real risk of solving the wrong problem. | A new workflow step, a new public API, a change to how every session is framed |
| **short** | The work is contained and its problem is mostly clear, but it's still worth checking the need, the evidence and how success is measured. | A new option on an existing command, a focused behaviour change |
| **skip** | The work is so small or so mechanical that framing would cost more than it saves. | A typo, a dependency bump, a one-line config change |

The proposal is a judgement, not a formula. Say why in one line ("touches the guard hook and every session type", "one-line typo fix"). The user can pick a different tier; record the one they confirm.

**The tier is a floor, not a ceiling.** When the work calls for it and the user agrees, include an element from a higher tier. The tier still records what was confirmed; the extra element is simply there.

## Check × tier

Every check has a stated tier. No cell is blank.

| Check | full | short | skip |
|---|---|---|---|
| Propose a tier and record the confirmed tier and reason | runs | runs | runs |
| [Solution-first (XY)](#solution-first-xy) | runs | runs | skipped |
| [Symptom vs cause](#symptom-vs-cause) | runs | runs | skipped |
| [Anchor: locate and assess](#anchor-locate-assess-verdict) | runs | runs | skipped |
| Anchor: draft missing or failing elements | runs when the anchor is missing or incomplete | runs when the anchor is missing or incomplete | skipped |
| [Anchor: aligns/extends verdict](#anchor-locate-assess-verdict), and an anchor update when it extends | runs | runs | skipped |
| [Registry and ADR overlap](#registry-and-adr-overlap) | runs where a registry or ADRs exist | runs where a registry or ADRs exist | skipped |

At skip tier every check is skipped, **the anchor checks included**. A missing anchor is created at the next full- or short-tier session.

Which **artifact sections** each tier requires is set by each standards skill's `types/{type}.md` tier table, which is part of this standard for that type. Which files exist at each tier follows from those tables and the type's templates.

## Solution-first (XY)

Full and short tiers. An issue often names a fix ("add a retry flag") rather than the need behind it ("builds fail on flaky network calls and people rerun them by hand").

- Find the need behind the request: who has it, when it arises, and what outcome they want.
- If the issue names a fix, either the user confirms the fix *is* the need, or the fix moves to **Candidate solutions** in the framing record, outside the problem statement, where later work can pick it up.
- Record the outcome either way. The problem statement then states the need, not the fix.

## Symptom vs cause

Full and short tiers. An issue often reports what was seen ("the build fails on Mondays"), not why.

- Record the **observed symptom**, with its source, separately from the **cause**.
- Name the cause only when it's actually known. Otherwise record the cause as **unknown**. Don't promote a guess to a cause; a guess is an assumed claim.

## Anchor: locate, assess, verdict

Full and short tiers. The project anchor is the project's one authoritative statement of its vision, mission, scope and non-goals. Its contract is in [`reference/anchor-contract.md`](reference/anchor-contract.md).

1. **Locate** the anchor: the root `README.md`, between the `<!-- compass:anchor -->` and `<!-- /compass:anchor -->` markers.
2. **Assess** it against the contract's checklist. There are three outcomes:
   - **complete**: every check passes. Use the anchor as it stands, and **ask no anchor questions**.
   - **incomplete**: some checks fail, including a broken or duplicated marker pair. Draft **only** the missing or failing elements with the user, and leave the existing wording untouched.
   - **missing**: there's no README, or no markers. Draft a vision, mission and scope with the user, plus non-goals if the user states any. A README that has anchor-like wording but no markers counts as missing; offer to reuse that wording in the draft.
3. **Verdict**: record exactly one of **aligns** (the work fits the anchor's scope and non-goals) or **extends** (the work widens the scope, or crosses a non-goal). Cite the scope and non-goal lines the verdict rests on. The verdict cites only the anchor, never the registry.
4. **Anchor update**: an *extends* verdict drafts the anchor change, and *incomplete* or *missing* drafts the missing elements. Get the user's approval (through `needs_input`), then record the action (`create`, `complete` or `extend`), the elements, and the exact agreed text in the framing record's anchor-update block. When nothing needs writing, the action is `none`.

**You never write the anchor yourself.** A phase agent writes only its own artifact. When there's agreed anchor text, return a `decision` log entry for the anchor update; the orchestrator writes the agreed text into the README in the same commit as that decision, and its milestone gate refuses the framing milestone until the README contains it. So an *extends* verdict is settled, and the anchor updated, before the framing milestone is approved.

## Registry and ADR overlap

Full and short tiers, and only where the project has a construct registry (`docs/registry/index.md`) or ADRs (`docs/registry/decisions/`). Skip it silently where neither exists; the plugin runs in repos that have neither.

- Search the registry's "Does" column for constructs that already do what the new work proposes (**overlap**).
- Search the ADR index for recorded decisions the new work would contradict (**conflict**).
- Record each overlap or conflict found, naming the construct or ADR, or record **none found**.

This check is about duplication and contradiction, not fit. Fit with the project is the anchor verdict's job.

## What a session type supplies

This is the extension point. A session type that supplies everything in this list can run framing with **no change to this skill**.

1. **A `framing` block** in `skills/session/workflows/{type}.json`:

   | Field | What it is | Feature's value |
   |---|---|---|
   | `run_in_phase` | The phase of this workflow that runs framing. The phase is named here, never in this skill. | `"define"` |
   | `produces` | The framing artifact: a file, or a folder ending in `/`. It must be that phase's `artifact`. | `"define/"` |
   | `standards` | The standards skills that apply, one per artifact section | `["compass-labs:problem-statement", "compass-labs:requirements"]` |
   | `type_file` | The per-type file name each standards skill reads: `types/{type_file}.md` | `"feature"` |
   | `tiers` | The depth tiers this type allows | `["full", "short", "skip"]` |

2. **The framing artifact and its templates.** If `produces` is a folder, the phase declares it as a folder artifact with its fixed file set (`artifact_files`), and `skills/session/templates/{folder}/` holds a template for each file. The templates say where each check's outcome is recorded: the tier and reason, the XY and symptom/cause outcomes, the anchor state, verdict and update block, and the overlaps.
3. **A `types/{type_file}.md` in each standards skill it lists**, each with a tier × section table: which sections of that artifact section are required at each allowed tier, what each must contain, and the methods that apply (with their verdicts in that skill's `reference/methods.md`).
4. **An owner agent** for the phase named in `run_in_phase`, which preloads this skill and the listed standards skills. It follows the phase-agent contract, so it asks the user through `needs_input` and never writes the anchor itself.

**Checked against Research (#25).** A Research session type would add a `framing` block to `workflows/research.json` (its own phase name in `run_in_phase`, its own `produces`, the standards it uses, `type_file: "research"`, and its tiers), templates for its framing artifact, and `types/research.md` in each standards skill it lists. Nothing in this skill names Feature, Bugfix or a phase, so nothing here changes. Bugfix (#24) plugs in the same way; its type files already exist in both standards skills.

## Defaults, not rigid rules

Real work doesn't fit a framework neatly. The checks above say *what* must be found out and recorded; the wording, order and layout are defaults.

- Where a check asks whether something is good enough (a real need, a cause that's actually shown, a verdict that cites the right lines), you or the reviewer make that call. It isn't a string match.
- The mechanical parts stay mechanical, because a gate or tool depends on them: the anchor markers, the anchor-update block's action and agreed text (the milestone gate reads them), and the artifact file set the guard hook enforces.
