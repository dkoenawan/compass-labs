---
id: "005"
date: 2026-10-17
status: Accepted
deciders: [Daniel Koenawan]
affects: [implement, backend, session, verification, task-executor, post-hook-validator, doc-maintainer]
issue: https://github.com/dkoenawan/compass-labs/issues/28
---

# ADR-005: Implement's artifact is an `implement/` folder with an as-built record, a fixed testing boundary, and a variation path to Close

> Origin: #28

## Context

A Feature session's Implement phase produced code and a root `tasks.md`: a checklist with a free-prose "Deviations from design" section. Nothing reviewable showed, for each `DES-*` item, whether it was built as designed, so a reviewer at the Implement gate couldn't check the build against the design without reading the code. Nothing checked a built API against the API the design specified. Differences found while building went nowhere: Close read only `define/`, `design/` and the log, so the as-built docs, which the next session's Design reads as its only prior knowledge, described the design rather than what was built. Which tests belonged to Implement and which to Test was never stated, and the Test phase's Method column allowed `unit`.

Constraints: the phase-agent contract stays as it is (one artifact per phase, no `log.md` writes by agents); past sessions with a root `tasks.md` must get exactly the gate, guard and traceability results they got before; layers ship one per issue, so a later layer must plug in without changing the Implement phase; and the plugin serves any established stack.

## Decision

We will make **Implement's artifact an `implement/` folder** holding `tasks.md` (the plan) and `as-built.md` (the record of what was built), give Implement a **standard skill** (`implement`) with a per-layer plug-in, fix the **testing boundary** between Implement and Test, and route every **variation** from the design through the Implement gate to Close.

| # | Decision |
|---|---|
| D1 | Implement's artifact is the `implement/` folder: `tasks.md` (a `task-executor`-format checklist, one task per `DES-*` Result, in Depends-on order) and `as-built.md` (four table-only sections: As-built, Variations, Layer artifacts, Handed to Test). `feature.json` declares `artifact: "implement/"` with `legacy_artifact: "tasks.md"`, so a past session keeps its root `tasks.md` and is never migrated. The guard hook already handles folder artifacts and legacy root files, so its code doesn't change. |
| D2 | Every `DES-*` item gets exactly one as-built status (*built as designed*, *built with variation* or *not built*), with a reason for any status other than *built as designed*. Every difference from the design is a variation (item, designed, built, why), with IDs local to `as-built.md`. Frozen `define/` and `design/` are never edited. |
| D3 | **Testing boundary.** Implement writes unit and component tests only. Test owns integration (including a harness test that runs real hooks and scripts), UI, Playwright and inspection (for a requirement about a document or instructions). Each live `REQ-*` needs at least one `VER-*` row with a Test-owned method. An Implement test may be cited only inside a Test-owned row's Evidence, prefixed "Supporting:", never as a row of its own. The rule is enforced by the Test standard, not by `check-traceability.sh`, whose column order and behaviour are unchanged. |
| D4 | **Variation path.** Implement records each variation when it happens. At the Implement gate the orchestrator shows every status and variation above the approve, adjust and rethink options, asks the user to accept each variation as built or send it back for rework, and records one `decision` entry naming every outcome. Rework changes the code, never the design. The milestone isn't approved while rework is outstanding, so every variation in a frozen `as-built.md` was accepted. Close folds accepted variations into the as-built docs as the built behaviour, replacing what the design said. |
| D5 | **Layer plug-in contract** for ADR-004 D7's per-layer home: for a `DES-*` item whose Component cell names layer L, Implement reads `skills/L/reference/implement.md` if it exists. That file supplies how to build the layer, which unit and component tests to write, the layer's artifact (recorded under Layer artifacts), and the check against the design, whose mismatches become variations. The Implement standard keeps no list of layers. The only edit outside the layer's folder is listing the skill in the marketplace manifest and README, which is plugin registration. |
| D6 | **Missing layer guidance.** A layer without `reference/implement.md` is built with the repository's conventions and the general standard. Its As-built row records "no Implement guidance for {layer}" and cites the layer's follow-up issue. Implement doesn't stop. |
| D7 | **Backend, the first layer.** Backend guidance builds in the established stack, writes at least one unit and one component test per backend item, commits an OpenAPI 3.x document of the API as built, renders it with Scalar (without adding Scalar to the repo's dependencies), and compares it with the design's API contract one row per designed endpoint. Each mismatch is a variation. Non-OpenAPI APIs use the fallback (D6). |

**This refines [ADR-002](002-session-lifecycle.md) and [ADR-004](004-design-path.md) D7.** As with `define/` (ADR-003) and `design/` (ADR-004 D5), Implement still owns exactly one artifact, now a folder with a fixed file set, one level deep. ADR-004 D7's per-layer home gains its Implement half and a concrete lookup rule. **Construct registration is unchanged from ADR-004 D8:** Close is the only phase that registers a session's constructs, once the Implement gate has decided every variation. `task-executor` reads the registry but no longer writes it, and `post-hook-validator` runs by construct name after Close registers it. No new decision record is needed for that.

## Options Considered

**The form of the as-built record**

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **An `implement/` folder: `tasks.md` plus `as-built.md` (chosen)** | Plan and record are separate, so as-built tables can never be parsed as tasks. Define, Design and Implement share one folder layout that Close folds section by section. Room for per-layer files later | `feature.json`, the plan lookup, `doc-maintainer`'s fold-back eligibility and the tests change | — chosen |
| New table-only sections in a root `tasks.md` | No schema change; past-session compatibility by construction | One file holds plan and record, and any checklist line in the record becomes a phantom task for `select-next-task.sh` | Mixes the plan with the record |
| A second root file, `as-built.md` | Small change | Two artifacts for one phase; the guard maps one artifact per phase | Breaks one artifact per phase |

**How the built API is checked against the design**

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **The Implement agent compares them, one row per designed endpoint (chosen)** | Works in any stack, no parser or new dependency; an unbuilt endpoint shows as a row | Not mechanical: a missed mismatch depends on the agent and the reviewer | — chosen |
| A script extracting endpoints from the design | Mechanical | The design's contract is prose; realistically checks only method and path | Fragile, and can't compare shapes |
| A contract test in the consuming repo | Checks real behaviour | It's an integration test, which Test owns, and adds a dependency per stack | Breaks the testing boundary |

**How "at least one Test-owned `VER-*` per `REQ-*`" is enforced, and how supporting evidence is marked**

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **By instruction; Implement tests cited in Evidence as "Supporting:" (chosen)** | `check-traceability.sh` and its column order are unchanged for every session, past and new | A unit-only row would pass the gate if the Test agent ignored the rule | — chosen |
| `check-traceability.sh` counts only Test-owned methods | Mechanical | Needs a layout marker to keep past sessions identical, and new fixtures | More moving parts than the risk warrants |
| A separate `unit (supporting)` row, or a new Evidence column | Structured | A supporting row would satisfy the gate on its own; a new column breaks the load-bearing column order | Defeats the rule, or breaks the gate script |

**Missing layer guidance**

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Build with the repo's conventions, record and cite the follow-up (chosen)** | Mirrors Design's missing-layer fallback; the gap is visible at the gate | Quality for that layer rests on judgement until its guidance ships | — chosen |
| Fall back silently to `task-executor` and judgement | No new text | The gap is invisible and the layer isn't checked | Hides the gap |
| Return `blocked` | Strict | Blocks every session touching an unguided layer | Stops work for a documentation gap |

## NFR Captured

- Compatible: a past session with a root `tasks.md` gets exactly the guard, gate and traceability results it got before the `implement/` folder existed (0 differing results).
- Pluggable: 0 files outside `skills/{layer}/` change to add a layer's Implement guidance, apart from listing the skill in the marketplace manifest and README.
- Stack-neutral: 0 files of the plugin's default backend stack added by Implement to a repo with an established backend stack.
- Complete record: 100% of a session's `DES-*` items have an as-built status at the Implement gate.

## Consequences

**Now easier**: Checking a build against its design at the Implement gate without reading the code; seeing every designed endpoint compared with the API as built; keeping as-built docs true to what was built, so later designs read accurate prior knowledge; knowing which phase owns each kind of test; adding a layer's Implement guidance as its own issue by adding files.
**Now harder**: The Implement gate asks the user to decide each variation; Implement writes and maintains an OpenAPI document for every backend API it changes; the testing boundary is held by instruction, not by the gate script.
**New constraints**: `as-built.md` holds tables only, never a checklist line. Implement never writes integration, UI or Playwright tests, and Test never counts an Implement test as a row of its own. A session never holds both `implement/` and a root `tasks.md`. Rework after a variation changes the code, never a frozen `define/` or `design/`. Only Close registers the constructs a session built. As-built docs never cite variation IDs.

## Revisit Conditions

If a unit-only `VER-*` row reaches an approved Test milestone, enforce the Test-owned rule in `check-traceability.sh`. If agent-run API comparison misses a mismatch that reaches a release, or the design standard starts producing an OpenAPI draft, revisit the comparison method. If a layer can't plug in through `skills/{layer}/reference/implement.md` alone, revisit the plug-in contract (D5). If the Implement standard is better kept as an orchestrator reference than as its own skill, that move is tracked in #63.
