# Implement: the standard, the as-built record and the testing boundary

> → Concepts: [Implement overview](../../explanation/implement/overview.md) · → [Session workflow and artifacts](../session/workflow-and-artifacts.md#the-implement-folder) · → Decision: [ADR-005](../../registry/decisions/005-implement-as-built-record.md)
> Origin: #28

The standard itself is [`skills/implement/SKILL.md`](../../../skills/implement/SKILL.md), preloaded by the Implement agent (`agents/implement.md`). This page lists the facts other docs, tools and sessions rely on. The `implement/` folder's place in the session schema is in the [session reference](../session/workflow-and-artifacts.md#the-implement-folder).

## Inputs

| Source | Used for |
|---|---|
| `design/index.md`: Components (DES) table and Implementation order | Tasks, their order, and each item's Check |
| `design/solution.md` and any layer file `design/index.md` links (`design/backend.md` once it exists) | Build detail and the design's API contract |
| A past session's root `design.md` | The same, when the session has no `design/` folder |
| `${CLAUDE_PLUGIN_ROOT}/skills/{layer}/reference/implement.md` | Layer guidance, per the plug-in contract below |

Frozen `define/` and `design/` are never edited. A difference from the design is recorded as a variation, never fixed by changing the design.

## Tasks (`implement/tasks.md`)

- One task comes from one `DES-*` item's Result and names it as `[DES-nnn]`. An item can need several tasks. A task never spans two items.
- The item's Check goes on its last task as `— check: {Check}`, unless the Check needs a Test-owned test, in which case it goes under Handed to Test in `as-built.md`.
- Tasks follow the design's Implementation order. `(depends on: n, m)` names the tasks a task needs.
- One commit per ticked task: the code, its tests and the tick together.
- The checklist format is `task-executor`'s, and `task-executor` derives tasks by this same rule. The template is `skills/session/templates/implement/tasks.md`. It has no "Deviations from design" section.

## As-built record (`implement/as-built.md`)

Four sections, tables only. A checklist line (`- [ ]`) never appears in this file, so nothing in it can be read as a task. Template: `skills/session/templates/implement/as-built.md`.

| Section | Columns | Rule |
|---|---|---|
| As-built | `DES \| Status \| Reason \| Unit tests \| Component tests` | One row per `DES-*` item in the design, every item. Status is exactly one of *built as designed*, *built with variation* (naming the variation in Reason) or *not built*. Any status other than *built as designed* has a reason. Tests are named, or "none" with the reason |
| Variations | `ID \| DES \| Designed \| Built \| Why` | One row per difference between the design and what was built, including an item not built and an endpoint built but not designed. IDs (V1, V2 …) are local to the file. "None." when there are none |
| Layer artifacts | One `### {layer}` subsection per layer | Shaped by that layer's guidance (for the backend, see below) |
| Handed to Test | `DES \| Check` | Each `DES-*` Check that needs a Test-owned test |

Implement returns `done` only once the As-built section has a row for every `DES-*` item.

## Testing boundary

| Test | What it exercises | Owner |
|---|---|---|
| Unit | One function, class or module in isolation, collaborators replaced by test doubles; no network, real database or other process | Implement |
| Component | One component (module, service, script or endpoint handler) through its public interface; its internals run for real, everything outside it is a test double or in-memory fake | Implement |
| Integration | Real parts running together, including a harness test that runs the real hooks and scripts | Test |
| UI | A user interface exercised as a user would | Test |
| Playwright | Browser-automated end-to-end tests | Test |
| Inspection | A requirement about a document or instructions, checked by reading it | Test |

- Implement never writes integration, UI or Playwright tests. A Check that needs one is listed under Handed to Test.
- Where a unit or component test isn't practicable for an item (for example, documentation only), its As-built row says so.
- On the Test side, every `VER-*` row's Method is one of `integration`, `ui`, `playwright` or `inspection`, and every live `REQ-*` has at least one such row. An Implement unit or component test is cited only inside a Test-owned row's Evidence cell, prefixed `Supporting:`. It is never a row of its own. Past sessions' `unit`, `e2e` and `manual` rows stay as they are. The full rule is in [`skills/verification/SKILL.md`](../../../skills/verification/SKILL.md).

## Implement gate

In a session with `implement/as-built.md`, the orchestrator's gate ([`skills/session/SKILL.md`](../../../skills/session/SKILL.md)) runs in this order:

1. The gate message lists every `DES-*` status and every variation (item, designed, built, why) above the approve, adjust and rethink options.
2. For each variation the user chooses **accept as built** or **send back for rework**.
3. One `decision` entry names every outcome, mirrored to Key decisions.
4. Rework goes back to the Implement agent, which changes the code (never the design) and updates `as-built.md`. The gate runs again from step 1.
5. The milestone isn't approved while any rework is outstanding. Every variation left in a frozen `as-built.md` was accepted.

A past session with a root `tasks.md` is shown as before.

## Layer plug-in contract

A `DES-*` item's Component cell names its layer first. For layer `{layer}`, Implement reads `${CLAUDE_PLUGIN_ROOT}/skills/{layer}/reference/implement.md` if it exists. That file supplies:

1. how to build the layer (stack detection and build guidance);
2. which unit and component tests the layer needs, within the testing boundary;
3. the layer's artifact, recorded under Layer artifacts → `{layer}`;
4. the check against the layer's design, whose mismatches become variations.

The lookup is the path convention alone; the standard keeps no list of layers. A layer plugs in by adding `skills/{layer}/SKILL.md` and `skills/{layer}/reference/implement.md`. The only edit outside the layer's folder is listing the skill in `.claude-plugin/marketplace.json` and the README.

**No guidance for a layer.** Implement builds the item with the repository's conventions and this standard (status, variations, unit and component tests where practicable), records "no Implement guidance for {layer}" in the item's As-built Reason, and cites the layer's follow-up issue, opening one if none exists. It doesn't stop.

| Layer | Implement guidance | Follow-up |
|---|---|---|
| Backend | [`skills/backend/reference/implement.md`](../../../skills/backend/reference/implement.md) | Non-OpenAPI APIs (GraphQL, gRPC): #60. Backend design standard: #47 |
| Frontend | none yet | #57 |
| Database | none yet | #58 |
| AI-agent (LLM-agent code in a consuming repo) | none yet | #59 |
| Infrastructure (a Design kind, not a layer) | none yet | #50 |

## Backend layer

The backend home is [`skills/backend/`](../../../skills/backend/SKILL.md): `SKILL.md` indexes `reference/implement.md`, and `reference/design.md` once #47 delivers it.

| | Rule |
|---|---|
| (a) Stack | Detect the established backend stack with the signals in [`stack-defaults.md`](../../../skills/design/reference/stack-defaults.md#established-stack-signals) and build in it, naming it in the As-built row. The established stack always wins, and nothing that replaces part of it is added. Only a repository with no backend uses the design's stack choice. No default stack is restated here |
| (b) Tests | At least one unit test (a handler, service or domain function in isolation) and one component test (the API or service through its public interface, in one process, database and other services faked or in memory) per backend `DES-*` item, named in its As-built row. No integration test against real infrastructure, no contract test against a running server, no UI or Playwright test |
| (c) OpenAPI | Each backend item that adds or changes an HTTP API has an OpenAPI 3.x document of the API **as built**, committed in the repository: exported from the framework where it generates one, otherwise written beside the code and kept in step in the same task. It is rendered with Scalar's CLI run without adding it to the repository's dependencies (for example `npx @scalar/cli document validate {path}`). The result is recorded as *rendered*, or *not rendered* with the reason, which is raised at the gate; the document is committed either way |
| (d) API check | One row per endpoint in the design's API contract (`design/backend.md` where it exists, otherwise `design/solution.md`'s contracts and the backend `DES-*` items), comparing method, path, request, response and error cases. An endpoint never built still has a row. Each mismatch, and each endpoint built but not designed, is a variation |

Layer artifacts → `### Backend` in `as-built.md` holds the OpenAPI document's path and its Scalar result, then the API check table:

| Artifact | Path | Check |
|---|---|---|
| OpenAPI document | {path in the repo} | Scalar render: {rendered / not rendered: reason} |

| Endpoint (design) | Method | Path | Request | Response | Error cases | Result |
|---|---|---|---|---|---|---|
| {endpoint} | {match / differs: …} | … | … | … | … | {matches / V{n}} |

## Limits and targets

| Measure | Limit |
|---|---|
| `DES-*` items without an as-built status at the Implement gate | 0 |
| Files of the plugin's default backend stack added by Implement to a repository with an established backend stack | 0 |
| Files outside `skills/{layer}/` changed to add a layer's Implement guidance (marketplace and README listing excepted) | 0 |
| Gate, guard and traceability results that differ for a past session with a root `tasks.md` | 0 |

## Past sessions

A session that already has a root `tasks.md` keeps it, with its "Deviations from design" section, writes no `implement/` folder, and is never migrated. It reads a root `design.md` when it has no `design/` folder. The Implement gate, Test and Close treat it as before.
