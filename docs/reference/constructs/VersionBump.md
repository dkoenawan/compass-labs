---
name: VersionBump
type: Utility
layer: Shared
file: .github/scripts/bump-version.sh
status: built
planned_in: null
last_verified: null
---

# VersionBump

> Origin: #30

## Does

compass-labs' own version bump: sets `.claude-plugin/plugin.json`'s `version` to the next patch, minor or major version and prints it. Declared as the first L2 step in `.claude/deploy.json`. It does NOT choose the level (the Deploy agent does, by the declared rule), commit (a separate declared step does) or tag (ReleaseTagStarter does after the merge).

## Functional Requirements

- [ ] `2.2.1` with `minor` gives `2.3.0`, printed, with only the `"version"` line of `plugin.json` changed.
- [ ] A bad level, or a version that isn't `MAJOR.MINOR.PATCH`, exits 1 and changes nothing.
- [ ] It never commits.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/session/bump_version_test.sh

## Interface

```text
bump-version.sh <patch|minor|major>   # prints the new version; exit 1 on a bad level or version
```

## Dependencies

- Calls: (none)
- Called by: the Deploy agent, as compass-labs' declared L2 step `bash .github/scripts/bump-version.sh {level}`
- Reads: `.claude-plugin/plugin.json`
- Writes: `.claude-plugin/plugin.json` (the version line only)

## Patterns Applied

- (none)

## Key Decisions

- [ADR-008](../../registry/decisions/008-deploy-runs-declared-steps.md): version arithmetic is a script; the level is the agent's choice by the declared rule.
