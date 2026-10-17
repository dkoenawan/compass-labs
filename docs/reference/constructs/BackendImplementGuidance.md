---
name: BackendImplementGuidance
type: Component
layer: Shared
file: skills/backend/reference/implement.md
status: built
planned_in: null
last_verified: null
---

# BackendImplementGuidance

> Origin: #28

## Does

Tells the Implement phase how to build a backend `DES-*` item in a consuming repo: build in the established stack, write at least one unit and one component test, commit an OpenAPI 3.x document of the API as built and render it with Scalar, and compare it with the design's API contract one row per designed endpoint, turning each mismatch into a variation. It does NOT state the plugin's default stack (`skills/design/reference/stack-defaults.md` does), cover non-OpenAPI APIs (the Implement standard's fallback does, citing #60), or hold the backend design standard (#47). Indexed by `skills/backend/SKILL.md`, the backend layer's home.

## Functional Requirements

- [ ] For each backend item, at least one unit test and at least one component test (in one process, database and other services faked or in memory) are written, run and named in its As-built row.
- [ ] For each backend item that adds or changes an HTTP API, an OpenAPI 3.x document of the API as built is committed in the repo, and its Scalar render result (*rendered*, or *not rendered* with the reason) is recorded under Layer artifacts → Backend.
- [ ] Every endpoint in the design's API contract gets one comparison row (method, path, request, response, error cases), and each mismatch, and each endpoint built but not designed, is recorded as a variation.
- [ ] In a repo with an established backend stack that produces OpenAPI, the build stays in that stack and adds no part of the plugin's default backend stack, and Scalar runs without being added to the repo's dependencies.
- [ ] It is found by the Implement standard through the `skills/backend/reference/implement.md` path alone.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/session/implement_standard_test.sh

## Interface

```text
Found at:   ${CLAUDE_PLUGIN_ROOT}/skills/backend/reference/implement.md
Applies to: DES-* items whose Component cell names the backend
Sections:   (a) Stack  (b) Tests  (c) OpenAPI document as built  (d) API check against the design
Records:    implement/as-built.md → Layer artifacts → ### Backend
              | Artifact | Path | Check |              (OpenAPI path, Scalar render result)
              | Endpoint (design) | Method | Path | Request | Response | Error cases | Result |
Render:     npx @scalar/cli document validate {path}   (not added to the repo's dependencies)
```

## Dependencies

- Calls: Scalar CLI (through `npx`)
- Called by: ImplementStandard (layer plug-in contract)
- Reads: `skills/design/reference/stack-defaults.md` (established-stack signals), the session's `design/backend.md` or `design/solution.md` contracts and backend `DES-*` items
- Writes: the consuming repo's backend code, its unit and component tests, and its OpenAPI document

## Patterns Applied

- [One source of stack defaults; an established stack wins](../../registry/patterns.md#one-source-of-stack-defaults-an-established-stack-wins)
- [Each test kind has one owning phase](../../registry/patterns.md#each-test-kind-has-one-owning-phase)
- [Variations go forward, never upstream](../../registry/patterns.md#variations-go-forward-never-upstream)

## Key Decisions

- [ADR-005](../../registry/decisions/005-implement-as-built-record.md) D7: the backend as the first layer with Implement guidance; the API check is agent-run, one row per designed endpoint.
- [ADR-004](../../registry/decisions/004-design-path.md) D10: an established stack always wins over a default.
