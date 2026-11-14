# The deploy declaration

> Part of the [Deploy standard](../SKILL.md).

A repo's deploy declaration is one JSON file, `.claude/deploy.json`, at the repo root. It says what deploy means for this repo: the commands are the repo's own, and the plugin supplies none of them. JSON has no comments, so put the "why" of any object in a `note` field.

## Fields

| Field | Required | Holds |
|---|---|---|
| `deployment` | always | `"declared"`, or `"none"` for a repo with nothing to deploy. With `"none"`, no other field is needed |
| `release_mode` | declared | `"in_session"` (the feature session's Deploy runs L2) or `"own_session"` (L2 waits for a release session) |
| `l1.parts[]` | declared | One entry for each deployable part: `name` and `setup[]`, a list of steps. May be empty, in which case Deploy offers entries for the parts the design shows |
| `l2.steps[]` | declared | The release steps, in the order they run |
| `l2.strategy` | optional | The release strategy, such as `"tagged release"`, `"rolling"`, `"blue-green"` or `"canary"` |
| `confirmation.run` | declared | The command that shows the release worked. Exit 0 is a pass |
| `rollback` | declared | How to undo the release: a string, or a list of strings. Never run automatically |
| `versioning.rule` | optional | The repo's versioning rule, or where the repo states it (for example `"CLAUDE.md: Version Management"`) |
| `versioning.file` | optional | The file that holds the version, relative to the repo root. Needed only by the starter |
| `versioning.field` | optional | A jq path to the version inside `versioning.file` (for example `".version"`), or `""` for a plain-text version file. Needed only by the starter |
| `versioning.tag` | optional | The release tag's form, containing `{version}` (for example `"v{version}"`). Needed only by the starter |
| `after_merge[]` | optional | Steps left to the user after the merge, each with `name` and `run`. The release record lists them as the user's |
| `note` | optional | On any object: the reason for it |

### A step

Every step, in `l1.parts[].setup[]` and in `l2.steps[]`, has:

| Field | Required | Holds |
|---|---|---|
| `name` | yes | What the step does, as the release record will list it |
| `run` | yes, except on a merge step | The command, run from the repo root, word for word |
| `kind` | yes | `"routine"` (Deploy runs it without asking) or `"production_affecting"` (waits for the user's own instruction) |
| `merge` | optional | `true` on the step that merges the pull request. It must be `"production_affecting"`, or the declaration is invalid. Deploy never runs it |
| `note` | optional | Why the step is there, or why it has its kind |

### Placeholders in `run`

| Placeholder | Filled in with |
|---|---|
| `{level}` | The version bump level Deploy chose by `versioning.rule`: `patch`, `minor` or `major` |
| `{version}` | The new version |
| `{branch}` | The session branch |
| `{issue}` | The session's issue number |
| `{pr}` | The session's pull request number |

## Rules

- Steps run in declared order, with L1 before L2. Once a step waits for the user, every later step waits too.
- A merge is always production-affecting. Declared steps never push to the default branch.
- L1 setup steps must be safe to run again.
- The confirmation check covers the steps that ran.
- `check-declaration.sh` checks all of this before anything runs.

## Example: one web service, staging and production (`in_session`)

A repo like the `fixture-service` test fixture: one web service, a routine staging deploy, a production deploy that waits for the user, and a merge.

```json
{
  "deployment": "declared",
  "note": "One web service. Staging is routine; production waits for the user.",
  "release_mode": "in_session",
  "versioning": {
    "rule": "SemVer: a new feature is minor, a fix is patch",
    "file": "package.json",
    "field": ".version",
    "tag": "v{version}"
  },
  "l1": {
    "parts": [
      {
        "name": "web-service",
        "setup": [
          { "name": "check the service's deploy targets exist", "run": "./deploy.sh --check-targets", "kind": "routine", "note": "Read-only, so safe to repeat" }
        ]
      }
    ]
  },
  "l2": {
    "strategy": "rolling",
    "steps": [
      { "name": "deploy to staging", "run": "./deploy.sh staging", "kind": "routine" },
      { "name": "deploy to production", "run": "./deploy.sh production", "kind": "production_affecting" },
      { "name": "merge the pull request", "merge": true, "kind": "production_affecting" }
    ]
  },
  "confirmation": { "run": "./check-health.sh" },
  "rollback": [
    "Staging: ./deploy.sh staging --previous",
    "Production: the user runs ./deploy.sh production --previous"
  ],
  "after_merge": []
}
```

## Example: release in its own session (`own_session`)

The same shape, with `"release_mode": "own_session"`. A feature session's Deploy still assesses L1 and runs a needed part's setup, but runs no L2 step and records "release: waits for a release session".

```json
{
  "deployment": "declared",
  "release_mode": "own_session",
  "l1": { "parts": [ { "name": "web-service", "setup": [ { "name": "check targets", "run": "./deploy.sh --check-targets", "kind": "routine" } ] } ] },
  "l2": {
    "steps": [
      { "name": "deploy to production", "run": "./deploy.sh production", "kind": "production_affecting" },
      { "name": "merge the pull request", "merge": true, "kind": "production_affecting" }
    ]
  },
  "confirmation": { "run": "./check-health.sh" },
  "rollback": "./deploy.sh production --previous, run by the user"
}
```

## Example: nothing to deploy (`none`)

A docs-only repo, or any repo with no deployment:

```json
{ "deployment": "none", "note": "Documentation only: nothing is deployed." }
```

Deploy runs nothing and records "nothing to deploy, per the declaration".
