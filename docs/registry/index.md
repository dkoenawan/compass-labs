---
last_updated: 2026-10-24
construct_count: 5
verified: 0
stubs: 0
---

# System Model — Construct Registry

> Origin: #22 · #23 · #28 · #37

> Before building anything: search this index.
> Column "Does" is the capability description — search it before creating a new construct.

## Constructs

| Name | Type | Does | Layer | File | Status |
|------|------|------|-------|------|--------|
| [ImplementStandard](../reference/constructs/ImplementStandard.md) | Component | Turns a frozen design into tasks, code with unit and component tests, and an `implement/` as-built record with a status per design item and every variation; plugs in layer guidance by path | Shared | `skills/implement/SKILL.md` | built |
| [BackendImplementGuidance](../reference/constructs/BackendImplementGuidance.md) | Component | Builds a backend item in the established stack with unit and component tests, commits an OpenAPI document of the API as built rendered with Scalar, and checks it endpoint by endpoint against the design | Shared | `skills/backend/reference/implement.md` | built |
| [SessionBranchGuard](../reference/constructs/SessionBranchGuard.md) | Hook | Blocks a session `git commit` while the default branch is checked out and a session `git push` to the default branch, so session work reaches it only through a pull request; fails open | Shared | `hooks/session-branch-guard.sh` | built |
| [DefaultBranchLookup](../reference/constructs/DefaultBranchLookup.md) | Utility | Prints the repository's default branch as `origin` reports it (`origin/HEAD`, then `ls-remote`), never assuming `main` | Shared | `skills/session/scripts/default-branch.sh` | built |
| [SessionLister](../reference/constructs/SessionLister.md) | Utility | Lists active and paused sessions from the working tree and every local branch tip, read-only, never `archive/` | Shared | `skills/session/scripts/list-sessions.sh` | built |

## Feature Cross-Reference

| Feature | Constructs |
|---------|-----------|
| Implement phase: as-built record, testing boundary, backend OpenAPI artifact | ImplementStandard, BackendImplementGuidance |
| Session branch: session work reaches the default branch only through a pull request | SessionBranchGuard, DefaultBranchLookup, SessionLister |

## Known Gaps

- (none yet — add entries as gaps are discovered)

## Patterns

[Cross-cutting conventions](patterns.md) — 15 patterns established
