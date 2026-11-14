---
last_updated: 2026-11-14
adr_count: 9
---

# Architecture Decision Record Index

> Origin: #22 · #27 · #28 · #30 · #37

> Each row is one significant decision. Click the title to read the full ADR.
> Status: Proposed | Accepted | Deprecated | Superseded

| ID | Date | Status | Decision | Affects |
|----|------|--------|----------|---------|
| [001](001-diataxis-docs-restructure.md) | 2026-08-15 | Proposed | Diataxis-based docs/ restructure + docs/sessions/ fold-back | doc-maintainer, plan, task-executor, adr |
| [002](002-session-lifecycle.md) | 2026-09-24 | Accepted | Session lifecycle: main-session orchestrator, one artifact per phase, hook-enforced | session, requirements, verification, doc-maintainer, plan, task-executor |
| [003](003-framing-and-project-anchor.md) | 2026-09-27 | Accepted | Shared framing step, per-type standards, README project anchor, Define output as a `define/` folder | framing, problem-statement, requirements, session, verification, doc-maintainer |
| [004](004-design-path.md) | 2026-10-10 | Accepted | One Design path, layered by solution kind, with a `design/` folder and visual deltas; `plan` retired | design, session, plan, init, bootstrap-new-project, explore, task-executor |
| [005](005-implement-as-built-record.md) | 2026-10-17 | Accepted | Implement's artifact is an `implement/` folder with an as-built record; Implement owns unit and component tests, Test owns integration, UI, Playwright and inspection; variations decided at the Implement gate and folded back by Close | implement, backend, session, verification, task-executor, post-hook-validator, doc-maintainer |
| [006](006-session-branch-guard.md) | 2026-10-20 | Accepted | Session work reaches the default branch only through a pull request, enforced by a `PreToolUse` hook on `Bash` that blocks session commits and pushes to the default branch | session, SessionBranchGuard, DefaultBranchLookup, SessionLister |
| [007](007-deploy-declaration.md) | 2026-11-03 | Accepted | A repo declares deploy in `.claude/deploy.json` (L1 setup per part, L2 steps, step kinds, confirmation, rollback, release mode), offered at project initiation and at Deploy for a part it doesn't cover | deploy, session, init, DeployStandard, DeclarationCheck |
| [008](008-deploy-runs-declared-steps.md) | 2026-11-03 | Accepted | The Deploy agent runs the declared routine steps itself (refines ADR-002); scripts decide what's mechanical; the tier follows release risk; an optional starter GitHub Actions workflow is copied into the repo, compass-labs' pipeline being its first install | deploy, session, DeployStandard, DeclarationCheck, ReleaseRecordCheck, StarterInstaller, ReleaseTagStarter |
| [009](009-merge-triggered-release-pipeline.md) | 2026-11-03 | Accepted | A merge into the default branch tags and publishes the release through a GitHub Actions workflow calling one script, with a pre-merge check; tags are never overwritten (relates to ADR-006) | deploy, ReleaseTagStarter |
