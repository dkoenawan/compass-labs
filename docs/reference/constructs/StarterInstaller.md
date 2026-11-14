---
name: StarterInstaller
type: Utility
layer: Shared
file: skills/deploy/scripts/install-starter.sh
status: built
planned_in: null
last_verified: null
---

# StarterInstaller

> Origin: #30

## Does

Copies the Deploy standard's starter workflow and script into a GitHub-hosted repo as `.github/workflows/release.yml` and `.github/scripts/release-tag.sh`, with the script's settings block filled in from the declaration's `versioning.file`, `versioning.field` and `versioning.tag`. Run only on the user's yes. It does NOT ask the user (DeployStandard's offer does), add the pipeline part to the declaration (the offer does), overwrite anything, or commit.

## Functional Requirements

- [ ] With a GitHub `origin` (https or scp form), it writes both files with the declaration's values, and neither contains `dkoenawan/compass-labs` or `CLAUDE_PLUGIN_ROOT`; the installed script runs.
- [ ] An SSH host alias that `ssh -G` resolves to `github.com` counts as GitHub; an https host that only starts with `github.com` doesn't.
- [ ] A non-GitHub or missing `origin` writes nothing and exits 3.
- [ ] A missing `versioning` field is named, nothing is written, exit 4.
- [ ] An existing target file is named and left byte for byte unchanged, exit 5.
- [ ] An invalid, missing or `none` declaration writes nothing, exit 1.
- [ ] The declaration is never changed.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/session/install_starter_test.sh

## Interface

```text
install-starter.sh <repo-root>
writes  .github/workflows/release.yml, .github/scripts/release-tag.sh (prints both paths)
exit 0 written · 1 declaration not valid · 3 origin not GitHub · 4 versioning field missing · 5 target exists
```

## Dependencies

- Calls: DeclarationCheck, `jq`, `git remote get-url origin`, `ssh -G` (config only)
- Called by: DeployStandard (declaration offer and starter mode, on a yes)
- Reads: `{repo}/.claude/deploy.json`, `skills/deploy/templates/github/`
- Writes: `{repo}/.github/workflows/release.yml`, `{repo}/.github/scripts/release-tag.sh`

## Patterns Applied

- [Plugin paths vs. project paths](../../registry/patterns.md#plugin-paths-vs-project-paths)

## Key Decisions

- [ADR-008](../../registry/decisions/008-deploy-runs-declared-steps.md): the starter is optional, copied and owned by the repo, with values fixed at copy time.
