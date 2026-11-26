<!-- The release record, written by a /trellis:deploy run from the Deploy standard, saved as docs/releases/{YYYY-MM-DD}-{slug}.md (skills/deploy/SKILL.md). The Deploy tier line sets which sections are required (the standard's tier table); check-release.sh refuses a record missing one. Delete a section only if the confirmed tier doesn't require it. A record with no Deploy tier line is a past record and gets no check. -->
# Release: {Change title}

> Phase: Deploy | Started: {date} | Status: Draft
> Deploy tier: {skip | short | full}: {one-line reason, from the release's risk}
> PR: {#N link} · Issue: {#N link} · Declaration: `.claude/deploy.json`

## Lifecycles run and why

- **L1:** {needed or not needed, and why: the delta rows read from the frozen design, e.g. "L1: not needed, no deployable part changed" or "L1: needed, `{part}` has no deployment setup"}
- **Added to the declaration at this Deploy:** {the part and its entry, on the user's yes; or "none"}
- **L1 setup run:** {each part's setup that ran, in order; or "none"}
- **L2:** {release run now; or "release: waits for a release run"; or "nothing to deploy, per the declaration"}

## Release strategy

{The declared `l2.strategy`, e.g. tagged release, rolling, blue-green, canary.}

## Completeness

{Release manifest checked as it ships (e.g. `marketplace.json`): every listed component exists and is complete (no placeholders, stubs or TODO bodies), and every complete component is listed. Note how it was checked. With `deployment: none`, say nothing ships.}

## Steps run

Source: the deploy declaration, `.claude/deploy.json`, word for word.

| # | Step | Kind | Command | Result |
|---|---|---|---|---|
| 1 | {step} | {routine \| production_affecting} | `{command as run}` | {result} |

**Waiting for the user's instruction:**

- {step}: waiting for the user's instruction (`{command}`){, authorised by: the user's message on {date}, once it runs}

**The user's steps after the merge:**

- {step}: `{command}`

## Confirmation

{The declared check (`confirmation.run`), its output quoted, and passed or failed. If it failed: the declared rollback is shown below and the release isn't complete.}

## Rollback

{The declared rollback, stated as the steps and who runs them. Never run automatically.}

## Change record

{What changed (linking the PR and its issue), the version and the bump level with its reason (e.g. "MINOR: a new skill"), the change type (standard or normal) and the change authority (the user, who confirmed the tier).}
