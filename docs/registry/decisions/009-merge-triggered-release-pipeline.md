---
id: "009"
date: 2026-11-03
status: Accepted
deciders: [Daniel Koenawan]
affects: [deploy, ReleaseTagStarter]
issue: https://github.com/dkoenawan/compass-labs/issues/30
---

# ADR-009: A merge into the default branch tags and publishes the release, through a GitHub Actions workflow that calls one script

> Origin: #30

## Context

compass-labs' release steps after the merge (tag `main`, publish the release) were done by hand and the tag name drifted. Claude can't do them: the session branch guard ([ADR-006](006-session-branch-guard.md)) blocks pushes to the default branch, and the merge is always the user's. The old `task release` tagged a branch commit, which a squash merge throws away.

Constraints: no step for the user after the merge, apart from refreshing their local install, which a remote job can't reach; never move or overwrite an existing tag; a merge that doesn't change the version must create nothing; the tag a merge would create should be visible before the merge.

## Decision

We will run **a GitHub Actions workflow, `.github/workflows/release.yml`, that calls one script, `.github/scripts/release-tag.sh`**.

- On a `push` to the default branch (the job's condition compares `github.ref_name` with the repository's default branch, so the file works under any branch name), the script compares the version at `HEAD` with `HEAD^1` (the previous default-branch tip, for squash and merge commits alike). Unchanged: it logs "no version change". Changed and the tag is free: `gh release create {tag} --target {sha} --generate-notes`, so the tag and the release are created in one call on the merge commit. The tag exists: the run fails, naming it, and changes nothing.
- On a `pull_request`, the same script with `--check` prints the tag a merge would create and creates nothing. Deploy runs `--check` locally as its confirmation check.
- Permissions are per job (`contents: read` for the check, `contents: write` for the release); no secret beyond `GITHUB_TOKEN`; only `actions/checkout`.

compass-labs' tag form is `compass-labs--v{version}`. The workflow is compass-labs' own L1 setup, installed from the Deploy standard's starter ([ADR-008](008-deploy-runs-declared-steps.md)).

This **relates to [ADR-006](006-session-branch-guard.md)**: the tag is created by Actions on the merge commit, never pushed by Claude, so the branch guard stays as it is.

## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Workflow calling one script (chosen)** | Native to the host; only `GITHUB_TOKEN`; the same script serves the pre-merge check and runs in the local test harness | GitHub-specific; two files | — chosen |
| The same workflow with its logic inline | One file | The pre-merge check would repeat the logic; can't be tested locally | Untestable, duplicated |
| release-please or semantic-release | Established; writes changelogs | Wants to own the version bump, which the declaration's rule owns; a new dependency; opens its own release PRs | Clashes with the declared bump |
| A local post-merge task the user runs | No CI | A user step after every merge; pushes from the user's machine | The thing this removes |

## NFR Captured

- Timeliness: the tag resolves on `origin` within 10 minutes of the merge (target), 30 at worst.
- Integrity: an existing tag or release is never moved or overwritten; a duplicate version fails visibly.
- No-op safety: a merge with no version change creates no tag and no release.

## Consequences

**Now easier**: Releasing is merging; the tag is always on the merge commit and always the same form; the pull request shows the tag in advance.
**Now harder**: Rolling back after a merge takes a revert pull request with a new version; a workflow fault shows only on a real merge.
**New constraints**: Releases are tied to GitHub Actions being enabled and `GITHUB_TOKEN` being allowed to write contents. A partial failure after the merge leaves no tag, so the same `gh release create` can be re-run by hand.

## Revisit Conditions

If compass-labs moves off GitHub, needs signed or annotated tags, or wants a changelog file, re-evaluate. If the merge-to-tag interval regularly exceeds the 30-minute bound, re-evaluate the trigger.
