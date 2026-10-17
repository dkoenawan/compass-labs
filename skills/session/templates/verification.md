# Verification: {Session Title}

> Phase: Test | Started: {date} | Status: Draft
> Requirements: [`define/index.md`](define/index.md) · As built: [`implement/as-built.md`](implement/as-built.md)

Every requirement must be traceable to at least one passing test before the Test milestone can be approved (REQ-011). Each requirement needs at least one Test-owned row (Method `integration`, `ui`, `playwright` or `inspection`). Implement's unit and component tests appear only in Evidence, prefixed "Supporting:".

<!-- Cover every Check in implement/as-built.md's Handed to Test section. In a past session, read the root tasks.md instead. -->

| ID | Covers REQ | Method | Result | Evidence |
|---|---|---|---|---|
| VER-001 | REQ-{nnn} | {integration / ui / playwright / inspection} | {pass / fail / pending} | {CI run link, commit, test name or inspection note}; Supporting: {Implement unit or component test, optional} |
