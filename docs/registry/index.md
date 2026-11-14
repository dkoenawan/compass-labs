---
last_updated: 2026-11-14
construct_count: 11
verified: 0
stubs: 0
---

# System Model — Construct Registry

> Origin: #22 · #23 · #28 · #30 · #37

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
| [DeployStandard](../reference/constructs/DeployStandard.md) | Component | Defines a repo's deploy declaration, which declared steps Deploy may run, when L1 setup is needed, the risk-based Deploy tiers and release-record sections, and the declaration offer and starter mode | Shared | `skills/deploy/SKILL.md` | built |
| [DeclarationCheck](../reference/constructs/DeclarationCheck.md) | Utility | Validates `.claude/deploy.json`, naming anything missing, and with `--plan` lists which steps may run and which wait, the release mode and the proposed tier; runs nothing from the repo | Shared | `skills/deploy/scripts/check-declaration.sh` | built |
| [ReleaseRecordCheck](../reference/constructs/ReleaseRecordCheck.md) | Utility | Deploy-gate check that `release.md` has every section its confirmed tier requires, naming each missing one; passes a past record | Shared | `skills/session/scripts/check-release.sh` | built |
| [StarterInstaller](../reference/constructs/StarterInstaller.md) | Utility | Copies the starter release workflow and script into a GitHub-hosted repo, filled in from the declaration's versioning; never overwrites, never edits the declaration | Shared | `skills/deploy/scripts/install-starter.sh` | built |
| [ReleaseTagStarter](../reference/constructs/ReleaseTagStarter.md) | Resource | GitHub Actions workflow and script that check the tag on each pull request and, on a version-changing merge into the default branch, tag the merge commit and publish the release; never overwrites a tag. Installed as compass-labs' own pipeline | Infra | `skills/deploy/templates/github/release-tag.sh` | built |
| [VersionBump](../reference/constructs/VersionBump.md) | Utility | Sets compass-labs' `plugin.json` version to the next patch, minor or major and prints it; doesn't commit | Shared | `.github/scripts/bump-version.sh` | built |

## Feature Cross-Reference

| Feature | Constructs |
|---------|-----------|
| Implement phase: as-built record, testing boundary, backend OpenAPI artifact | ImplementStandard, BackendImplementGuidance |
| Session branch: session work reaches the default branch only through a pull request | SessionBranchGuard, DefaultBranchLookup, SessionLister |
| Deploy phase: per-repo deploy declaration, L1 setup and L2 release, risk-based tiers, merge-triggered release pipeline | DeployStandard, DeclarationCheck, ReleaseRecordCheck, StarterInstaller, ReleaseTagStarter, VersionBump |

## Known Gaps

- (none yet — add entries as gaps are discovered)

## Patterns

[Cross-cutting conventions](patterns.md) — 16 patterns established
