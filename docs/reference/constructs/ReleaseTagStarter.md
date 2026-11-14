---
name: ReleaseTagStarter
type: Resource
layer: Infra
file: skills/deploy/templates/github/release-tag.sh
status: built
planned_in: null
last_verified: null
---

# ReleaseTagStarter

> Origin: #30

## Does

The starter's merge-triggered release: `release.yml` runs `release-tag.sh --check` on each pull request (reporting the tag a merge would create) and `release-tag.sh` on a push to the default branch, which creates the tag on the merge commit and publishes the release when the version changed. compass-labs' `.github/workflows/release.yml` and `.github/scripts/release-tag.sh` are an unedited install of it. It does NOT bump the version (the repo's declared step does), push to any branch, or overwrite a tag.

## Functional Requirements

- [ ] `--check` on a branch whose version changed prints "would create {tag}" and creates no tag and no release.
- [ ] On a version-changing merge into the default branch, the tag resolves to the merge commit and a published release exists, with no step run by the user.
- [ ] On a merge that leaves the version unchanged, it logs "no version change" and creates no tag or release.
- [ ] If the tag already exists, the run fails naming it, and the tag and its release are unchanged.
- [ ] `--check` on an unchanged version notes that merging creates no tag instead of warning about an existing one.
- [ ] A plain-text version file works with an empty `VERSION_FIELD`.
- [ ] The script refuses to run while its settings still hold the template's placeholders.
- [ ] The workflow has both triggers, `contents: read` for the check and `contents: write` for the release, `fetch-depth: 2`, only `actions/checkout`, no secret beyond `GITHUB_TOKEN`, and no reference to `dkoenawan/compass-labs` or `CLAUDE_PLUGIN_ROOT`.
- [ ] For compass-labs, the tag is visible on `origin` within 10 minutes of the merge (30 at worst).

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/session/release_tag_test.sh, tests/session/release_workflow_test.sh, tests/session/own_pipeline_test.sh

## Interface

```text
release-tag.sh            # push to default branch: tag + release if version changed (exit 1 if tag exists)
release-tag.sh --check    # pull request or local: print the tag a merge would create; create nothing
settings: VERSION_FILE, VERSION_FIELD (jq path or empty), TAG_FORMAT (with {version})
release.yml jobs: check (pull_request) · release (push, ref_name == default branch)
installed in compass-labs: .github/workflows/release.yml, .github/scripts/release-tag.sh
```

## Dependencies

- Calls: `git` (`ls-remote` on `origin`), `jq` (JSON version file), `gh release create` (with `GH_TOKEN`)
- Called by: GitHub Actions (`release.yml`); the Deploy agent, as compass-labs' declared confirmation check (`--check`)
- Reads: the version file at `HEAD` and `HEAD^1`; tags on `origin`
- Writes: a tag and a GitHub release

## Patterns Applied

- [Session work reaches the default branch only through a pull request](../../registry/patterns.md#session-work-reaches-the-default-branch-only-through-a-pull-request)

## Key Decisions

- [ADR-009](../../registry/decisions/009-merge-triggered-release-pipeline.md): workflow calling one script, triggered by the merge.
- [ADR-008](../../registry/decisions/008-deploy-runs-declared-steps.md): compass-labs' pipeline is the starter's first install.
