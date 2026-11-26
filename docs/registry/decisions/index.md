---
last_updated: 2026-11-26
adr_count: 12
---

# Architecture Decision Record Index

> Origin: #22 · #27 · #28 · #30 · #37 · #86 · #98 · #102

> Each row is one significant decision. Click the title to read the full ADR.
> Status: Proposed | Accepted | Deprecated | Superseded

| ID | Date | Status | Decision | Affects |
|----|------|--------|----------|---------|
| [003](003-framing-and-project-anchor.md) | 2026-09-27 | Accepted · superseded in part by [012](012-retire-feature-session-pipeline.md) | Shared framing step, per-type standards, README project anchor, Define output as a `define/` folder | framing, problem-statement, requirements, session, verification, doc-maintainer |
| [007](007-deploy-declaration.md) | 2026-11-03 | Accepted · superseded in part by [012](012-retire-feature-session-pipeline.md) | A repo declares deploy in `.claude/deploy.json` (L1 setup per part, L2 steps, step kinds, confirmation, rollback, release mode), offered at project initiation and at Deploy for a part it doesn't cover | deploy, session, init, DeployStandard, DeclarationCheck |
| [009](009-merge-triggered-release-pipeline.md) | 2026-11-03 | Accepted | A merge into the default branch tags and publishes the release through a GitHub Actions workflow calling one script, with a pre-merge check; tags are never overwritten (relates to ADR-006) | deploy, ReleaseTagStarter |
| [010](010-read-only-scheduled-triage-run.md) | 2026-11-14 | Accepted | An unattended triage run is a read-only headless model (Read, Grep, Glob) in a `--restricted`, plugin-free session; deterministic scripts take the snapshot and make every GitHub write | triage, StockTakeProcedure, TriageSnapshot, TriageReportPublisher, TriageScheduledRun |
| [011](011-adopt-pstack-work-layer.md) | 2026-11-26 | Accepted | The official pstack (`cursor/plugins`) is the work layer, installed unchanged and made lite through subscription-safe model settings. Karpathy's rules and pstack's principles set the behaviour. Compass narrows to the controller (schedule, next task, weekly brief) | session, orchestrator, task-executor, triage, explore, doc-maintainer, brand-designer |
| [012](012-retire-feature-session-pipeline.md) | 2026-11-26 | Accepted | Retire the gated Feature session pipeline (orchestrator, phase agents, per-phase standards, session hooks), task-executor and five standalone skills. problem-statement and close are repurposed (short brief, indexed docs and findings), and the controller and weekly brief are added. pstack runs the work, and the PR is the one review point: a summary with drill-down. History is kept | session, orchestrator, phase agents, standards, session hooks, explore, doc-maintainer, brand-designer, post-hook-validator, bootstrap-new-project |

## Archived

> Overridden decisions, removed from the tree to keep the repo light. Each link opens the ADR at its last commit. Read it locally with `git show b1d47e1:docs/registry/decisions/<file>`.

| ID | Date | Decision | Overridden by |
|----|------|----------|---------------|
| [001](https://github.com/dkoenawan/compass-labs/blob/b1d47e1/docs/registry/decisions/001-diataxis-docs-restructure.md) | 2026-08-15 | Diataxis-based docs/ restructure + docs/sessions/ fold-back | [012](012-retire-feature-session-pipeline.md) |
| [002](https://github.com/dkoenawan/compass-labs/blob/b1d47e1/docs/registry/decisions/002-session-lifecycle.md) | 2026-09-24 | Session lifecycle: main-session orchestrator, one artifact per phase, hook-enforced | [012](012-retire-feature-session-pipeline.md) |
| [004](https://github.com/dkoenawan/compass-labs/blob/b1d47e1/docs/registry/decisions/004-design-path.md) | 2026-10-10 | One Design path, layered by solution kind, with a `design/` folder and visual deltas; `plan` retired | [012](012-retire-feature-session-pipeline.md) |
| [005](https://github.com/dkoenawan/compass-labs/blob/b1d47e1/docs/registry/decisions/005-implement-as-built-record.md) | 2026-10-17 | Implement's artifact is an `implement/` folder with an as-built record; Implement owns unit and component tests, Test owns integration, UI, Playwright and inspection; variations decided at the Implement gate and folded back by Close | [012](012-retire-feature-session-pipeline.md) |
| [006](https://github.com/dkoenawan/compass-labs/blob/b1d47e1/docs/registry/decisions/006-session-branch-guard.md) | 2026-10-20 | Session work reaches the default branch only through a pull request, enforced by a `PreToolUse` hook on `Bash` that blocks session commits and pushes to the default branch | [012](012-retire-feature-session-pipeline.md) |
| [008](https://github.com/dkoenawan/compass-labs/blob/b1d47e1/docs/registry/decisions/008-deploy-runs-declared-steps.md) | 2026-11-03 | The Deploy agent runs the declared routine steps itself (refines ADR-002); scripts decide what's mechanical; the tier follows release risk; an optional starter GitHub Actions workflow is copied into the repo, compass-labs' pipeline being its first install | [012](012-retire-feature-session-pipeline.md) |
