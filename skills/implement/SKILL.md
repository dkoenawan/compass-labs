---
name: implement
description: The Implement standard for a Feature session's Implement phase. It turns the frozen design's DES items into a task checklist, builds them with unit and component tests only, records an as-built status for every DES item and every variation from the design, and plugs in per-layer guidance from skills/{layer}/reference/implement.md. Preloaded by the Implement agent.
---

# Implement standard

This is the standard for a Feature session's Implement phase. It turns the frozen design into working code, and into a record of what was actually built that a reviewer can check at the Implement gate. It has six parts: tasks, the testing boundary, the as-built record, the layer plug-in contract, the fallback for a layer with no guidance, and past sessions.

**Where the output goes.** A new session writes an `implement/` folder, from `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/implement/`:

| File | Holds |
|---|---|
| `implement/tasks.md` | The plan: a `task-executor`-format checklist, one line per task. Nothing else |
| `implement/as-built.md` | The as-built record: As-built, Variations, Layer artifacts and Handed to Test, as tables only |

The design is read from `design/index.md` (its Components (DES) table and Implementation order), and from `design/solution.md` and any layer file it links. Frozen `define/` and `design/` are never edited. A difference from the design is recorded as a variation, never fixed by changing the design.

## 1. Tasks

Derive the checklist in `implement/tasks.md` from the design's Components (DES) table:

- **Each task comes from one `DES-*` item's Result.** A task names the item it implements as `[DES-nnn]`. One item can need several tasks. A task never spans two items.
- **The item's Check goes on its last task**, as `— check: {Check}`, so the item is done only when its Check passes. If the Check needs a Test-owned test (part 2), don't put it on a task. List it under Handed to Test in `as-built.md` instead.
- **Tasks follow the Depends-on order.** Use the design's Implementation order. A task's `(depends on: n, m)` names the tasks it needs. Every task of an item depends on the tasks of the items in its Depends on cell.
- **One commit per ticked task**, holding the code, its tests and the tick together.

`task-executor` derives tasks by this same rule. It links here rather than restating it.

## 2. Testing boundary

Testing is split between Implement and Test. Implement writes **unit and component tests only**:

| Test | What it exercises | Owner |
|---|---|---|
| Unit | One unit (a function, class or module) in isolation. Its collaborators are replaced by test doubles, and it touches no network, real database or other process | Implement |
| Component | One component (a module, service, script or endpoint handler) through its public interface. Its own internals run for real, and anything outside it (other services, the network, a shared database) is a test double or an in-memory fake | Implement |
| Integration | Real parts running together, including a harness test that runs the real hooks and scripts | Test |
| UI | A user interface exercised as a user would | Test |
| Playwright | Browser-automated end-to-end tests | Test |
| Inspection | A requirement about a document or instructions, checked by reading it | Test |

**Implement never writes integration, UI or Playwright tests.** A Check that needs one goes under Handed to Test. Where a unit or component test isn't practicable for an item (for example, an item that only changes documentation), say so in its As-built row instead of writing a test of the wrong kind.

## 3. As-built record

`implement/as-built.md` records what was built, against the design, in four table-only sections. Never write a checklist line (`- [ ]`) in it.

- **As-built:** one row per `DES-*` item in the design, every item, with **exactly one status**:
  - *built as designed*;
  - *built with variation*, naming the variation's ID in the Reason;
  - *not built*, with the reason.

  Every status other than *built as designed* needs a reason. The row names the item's unit and component tests, or says why there are none.
- **Variations:** one row per difference between the design and what was built, with IDs V1, V2 … local to the file. Each records the item, what was designed, what was built, and why. Record a variation when it happens, not at the end. Each one is decided at the Implement gate: accepted as built, or sent back for rework. Rework changes the code, not the design.
- **Layer artifacts:** one `### {layer}` subsection per layer that produced an artifact, shaped by that layer's guidance (part 4).
- **Handed to Test:** one row per `DES-*` Check that needs a Test-owned test, which Test verifies.

Return `done` only once the As-built section has a row for every `DES-*` item.

## 4. Layer plug-in contract

A `DES-*` item's Component cell names its layer first (the Design standard's handoff rule). For an item whose Component cell names layer `{layer}`, read:

```
${CLAUDE_PLUGIN_ROOT}/skills/{layer}/reference/implement.md
```

if that file exists. It supplies four things for the layer:

1. **How to build it:** the stack detection and build guidance for the layer.
2. **Which tests:** the unit and component tests the layer needs, within the testing boundary above.
3. **The layer's artifact:** what to record under Layer artifacts → `{layer}` in `as-built.md`.
4. **The check against the design:** how to compare what was built with the layer's design. Each mismatch becomes a variation.

The lookup is this path convention and nothing else. This standard keeps no list of layers: a layer plugs in by adding `skills/{layer}/SKILL.md` and `skills/{layer}/reference/implement.md`, with no edit to this standard. The only edit outside the layer's folder is listing the skill in `.claude-plugin/marketplace.json` (and the README), which is plugin registration rather than a change to how Implement works.

## 5. When a layer has no guidance

If a `DES-*` item names a layer and `skills/{layer}/reference/implement.md` doesn't exist, don't stop:

- Build the item with the repository's existing conventions and this standard: the as-built status, variations, and unit and component tests where practicable.
- In the item's As-built row, record "no Implement guidance for {layer}" in the Reason and cite the layer's follow-up issue. If no issue exists for it, open one and cite it.

The gap stays visible at the Implement gate, the same way Design handles a layer with no design standard.

## 6. Past sessions

A past session that already has a root `tasks.md` (the legacy layout) is treated as before. It keeps that file and its "Deviations from design" section, writes no `implement/` folder, and is never migrated. It reads a root `design.md` if it has no `design/` folder.
