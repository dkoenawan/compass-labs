# Backend: Implement guidance

How the Implement phase builds a `DES-*` item whose Component cell names the backend. The Implement standard (`${CLAUDE_PLUGIN_ROOT}/skills/implement/SKILL.md`) finds this file by the `skills/{layer}/reference/implement.md` path. Everything here is on top of that standard: tasks, the testing boundary, the as-built record and variations work as it says.

## (a) Stack

Build in the repository's established backend stack. Detect it with the backend signals in [`stack-defaults.md`](../../design/reference/stack-defaults.md#established-stack-signals), and name what you found in the item's As-built row. The established stack always wins: follow its framework, layout, naming and test runner, and add nothing that replaces part of it. Only when the repository has no backend at all, and the design chose a stack, use the design's choice. The plugin's own stack defaults are stated once, in that file, and not here.

## (b) Tests

For each backend `DES-*` item, write at least:

- **One unit test:** a handler, service or domain function in isolation, its collaborators replaced by test doubles.
- **One component test:** the item's API or service through its public interface, inside one process (for example the framework's in-process test client), with the database and other services faked or in memory.

Name both in the item's As-built row (Unit tests and Component tests columns), using the repository's test runner. Never write an integration test against real infrastructure, a contract test against a running server, or a UI or Playwright test: those are Test's. A Check that needs one goes under Handed to Test.

## (c) OpenAPI document as built

For each backend `DES-*` item that adds or changes an HTTP API, the API as built is described in an **OpenAPI 3.x document committed in the repository**:

- **Exported from the framework** where it generates one (for example from route and schema annotations), committed at a stable path and regenerated whenever the API changes. Otherwise **written beside the code**, by hand, and kept in step with it in the same task.
- It describes what was built, not what was designed. A difference from the design is a variation (see (d)), not an edit to the document.
- **Render it with Scalar** to check it's usable as API reference docs. Run Scalar's CLI without adding it to the repository's dependencies (for example `npx @scalar/cli document validate {path}`; check the CLI's `--help` for its current command names). Record the result honestly: *rendered*, or *not rendered* with the reason (for example no Node.js, or offline). The document is committed either way, and a *not rendered* result is raised at the gate.

Record it under Layer artifacts → `### Backend` in `as-built.md`:

| Artifact | Path | Check |
|---|---|---|
| OpenAPI document | {path in the repo} | Scalar render: {rendered / not rendered: reason} |

An API that isn't HTTP described by OpenAPI (for example GraphQL, gRPC or an event stream) has no guidance here yet. Build it by the Implement standard's fallback, and cite dkoenawan/compass-labs#60 in its As-built row.

## (d) API check against the design

Compare the API as built with the design's API contract: `design/backend.md` where it exists, otherwise `design/solution.md`'s contracts and the backend `DES-*` items in `design/index.md`. Write **one row per endpoint in the design's contract**, so an endpoint that was never built shows up as a row, not as an absence:

| Endpoint (design) | Method | Path | Request | Response | Error cases | Result |
|---|---|---|---|---|---|---|
| {endpoint} | {match / differs: …} | {match / differs: …} | {match / differs: …} | {match / differs: …} | {match / differs: …} | {matches / V{n}} |

Put this table under Layer artifacts → `### Backend`, below the OpenAPI row. **Each mismatch becomes a variation** in the Variations table (what the design said, what was built, why), and its row's Result names the variation. An endpoint built but not in the design is a variation too, with its own row.
