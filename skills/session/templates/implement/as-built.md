<!-- The as-built record in the implement/ folder (skills/implement/SKILL.md). Four sections, tables only: never a checklist line here, so nothing in this file can be read as a task. Frozen define/ and design/ are never edited; a difference from the design is recorded as a variation below and decided at the Implement gate. -->
# As built: {Session Title}

> Phase: Implement | Started: {date} | Status: {in progress | ready for the Implement gate}
> Design: [`design/index.md`](../design/index.md) · Plan: [`tasks.md`](tasks.md) · Session history: [`log.md`](../log.md)

## As-built

<!-- One row per DES-* item in the design, each with exactly one status: built as designed | built with variation | not built. A reason is required for any status other than built as designed. A layer with no Implement guidance records "no Implement guidance for {layer}" and its follow-up issue in the Reason. Name the unit and component tests (files or test names), or "none" with the reason. -->

| DES | Status | Reason | Unit tests | Component tests |
|---|---|---|---|---|
| DES-{nnn} | built as designed | | {test} | {test} |

## Variations

<!-- One row per difference between the design and what was built. IDs V1, V2 … are local to this file. Every variation is decided at the Implement gate: accepted as built, or sent back for rework. Write "None." under the heading when there are none. -->

| ID | DES | Designed | Built | Why |
|---|---|---|---|---|
| V1 | DES-{nnn} | {what the design said} | {what was built} | {why} |

## Layer artifacts

<!-- One subsection per layer this session built, shaped by that layer's guidance (skills/{layer}/reference/implement.md). Delete the example subsection when no layer has an artifact. -->

### {layer}

| Artifact | Path | Check |
|---|---|---|
| {artifact} | {path} | {result} |

## Handed to Test

<!-- One row per DES-* Check that needs a Test-owned test (integration, ui, playwright or inspection). Implement never writes those tests. -->

| DES | Check |
|---|---|
| DES-{nnn} | {the Check Test verifies} |
