---
last_updated: 2026-10-17
construct_count: 2
verified: 0
stubs: 0
---

# System Model — Construct Registry

> Origin: #22 · #23 · #28

> Before building anything: search this index.
> Column "Does" is the capability description — search it before creating a new construct.

## Constructs

| Name | Type | Does | Layer | File | Status |
|------|------|------|-------|------|--------|
| [ImplementStandard](../reference/constructs/ImplementStandard.md) | Component | Turns a frozen design into tasks, code with unit and component tests, and an `implement/` as-built record with a status per design item and every variation; plugs in layer guidance by path | Shared | `skills/implement/SKILL.md` | built |
| [BackendImplementGuidance](../reference/constructs/BackendImplementGuidance.md) | Component | Builds a backend item in the established stack with unit and component tests, commits an OpenAPI document of the API as built rendered with Scalar, and checks it endpoint by endpoint against the design | Shared | `skills/backend/reference/implement.md` | built |

## Feature Cross-Reference

| Feature | Constructs |
|---------|-----------|
| Implement phase: as-built record, testing boundary, backend OpenAPI artifact | ImplementStandard, BackendImplementGuidance |

## Known Gaps

- (none yet — add entries as gaps are discovered)

## Patterns

[Cross-cutting conventions](patterns.md) — 14 patterns established
