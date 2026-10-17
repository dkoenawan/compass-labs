---
last_updated: 2026-10-17
adr_count: 5
---

# Architecture Decision Record Index

> Origin: #22 · #27 · #28

> Each row is one significant decision. Click the title to read the full ADR.
> Status: Proposed | Accepted | Deprecated | Superseded

| ID | Date | Status | Decision | Affects |
|----|------|--------|----------|---------|
| [001](001-diataxis-docs-restructure.md) | 2026-08-15 | Proposed | Diataxis-based docs/ restructure + docs/sessions/ fold-back | doc-maintainer, plan, task-executor, adr |
| [002](002-session-lifecycle.md) | 2026-09-24 | Accepted | Session lifecycle: main-session orchestrator, one artifact per phase, hook-enforced | session, requirements, verification, doc-maintainer, plan, task-executor |
| [003](003-framing-and-project-anchor.md) | 2026-09-27 | Accepted | Shared framing step, per-type standards, README project anchor, Define output as a `define/` folder | framing, problem-statement, requirements, session, verification, doc-maintainer |
| [004](004-design-path.md) | 2026-10-10 | Accepted | One Design path, layered by solution kind, with a `design/` folder and visual deltas; `plan` retired | design, session, plan, init, bootstrap-new-project, explore, task-executor |
| [005](005-implement-as-built-record.md) | 2026-10-17 | Accepted | Implement's artifact is an `implement/` folder with an as-built record; Implement owns unit and component tests, Test owns integration, UI, Playwright and inspection; variations decided at the Implement gate and folded back by Close | implement, backend, session, verification, task-executor, post-hook-validator, doc-maintainer |
