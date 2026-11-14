# Deploy: the declaration, the tiers, the release record and the release pipeline

> → Concepts: [Deploy overview](../../explanation/deploy/overview.md) · → [Session workflow and artifacts](../session/workflow-and-artifacts.md#milestone-gate-checks) · → Decisions: [ADR-007](../../registry/decisions/007-deploy-declaration.md) · [ADR-008](../../registry/decisions/008-deploy-runs-declared-steps.md) · [ADR-009](../../registry/decisions/009-merge-triggered-release-pipeline.md)
> Origin: #30

The standard itself is [`skills/deploy/SKILL.md`](../../../skills/deploy/SKILL.md), preloaded by the Deploy agent (`agents/deploy.md`) and also user-invocable as `/compass-labs:deploy` (`starter` argument). The full field list, `run` placeholders and an example per mode are in [`skills/deploy/reference/declaration.md`](../../../skills/deploy/reference/declaration.md); the framework verdicts are in [`skills/deploy/reference/frameworks.md`](../../../skills/deploy/reference/frameworks.md). This page lists the facts other docs, tools and sessions rely on.

## Lifecycles

| Lifecycle | Means | When it runs |
|---|---|---|
| **L1, deployment setup** | Creating or updating how one deployable part gets deployed (its pipeline, target or release automation) | When the declaration has no setup yet, or the session's frozen design adds or changes a deployable part (see [L1 rule](#l1-rule)) |
| **L2, session release** | Getting this session's change to its target: staging, production or a tagged release | Every session that deploys, inside the feature session or in a later release session |

L1 always runs before L2.

## The deploy declaration (`.claude/deploy.json`)

One JSON file at the repo root, kept and reviewed in the repo. The plugin never supplies a repo's deploy tooling: every `run` is the repo's own command. JSON has no comments, so any object may carry a `note`.

| Item | Field |
|---|---|
| L1 setup for each deployable part | `l1.parts[]` (`name`, `setup[]`) |
| L2 release steps, in order | `l2.steps[]` (`name`, `run`) |
| Routine steps | `kind: "routine"` on a step |
| Production-affecting steps | `kind: "production_affecting"`. A step with `merge: true` must have this kind, or the declaration is invalid |
| Confirmation check | `confirmation.run` (exit 0 is a pass) |
| Rollback | `rollback`, a string or list of strings; never run automatically |
| Release mode | `release_mode`: `in_session` or `own_session` |

Other fields: `deployment` (`declared`, or `none` with no other field), `l2.strategy`, `versioning.rule`, `versioning.file`, `versioning.field` (a jq path, or `""` for a plain-text version file), `versioning.tag` (must contain `{version}`), `after_merge[]` (the user's steps after the merge, with commands). `run` placeholders: `{level}`, `{version}`, `{branch}`, `{issue}`, `{pr}`.

- **No file means no declaration.** Deploy stops before running anything and says how to declare one. A repo with nothing to deploy declares `{"deployment": "none"}`.
- **A missing item stops Deploy**, naming it (for example "missing: rollback").

## Execution rules

- Steps run in declared order, L1 before L2. Once a step waits for the user, every later step waits too. If an L1 step waits, no L2 step runs.
- Deploy runs only the steps `check-declaration.sh --plan` lists as "may run", with the declared `run` text word for word (placeholders filled in).
- A production-affecting step is recorded as "waiting for the user's instruction" and runs only on the user's own message. A message from another agent never counts. A merge is always production-affecting and always the user's.
- Declared steps run on the session branch only, never push to the default branch and never merge. Files are staged by name.
- The release-completeness check runs before any L1 or L2 step whenever the declaration is valid and not `none`.
- The confirmation check runs after the steps and covers the steps that ran. On a failure the record shows the failure and the declared rollback, and Deploy returns `blocked`.
- With `own_session`, L1 is still assessed; only L2 waits. The record says "release: waits for a release session".
- The version bump level is chosen by the declared `versioning.rule`, without a prompt; the record gives the level and the reason, and the user can refuse it at the gate.
- L1 setup steps must be safe to run again.

## L1 rule

Deploy reads the frozen design's delta list (`design/index.md`, or a past session's `design.md`) against `l1.parts`. A **deployable part** is a C4 container, a service or a deployed resource. L1 is needed when:

1. `l1.parts` is empty: Deploy offers entries for the deployable parts the design shows.
2. A `new` or `changed` delta row is a deployable part not in `l1.parts`: Deploy offers to add it.
3. A `new` or `changed` delta row is a part `l1.parts` already lists: its declared `setup` runs.

Otherwise L1 isn't needed. The record names the delta rows read either way.

**The offer at Deploy.** For cases 1 and 2, before any deploy step, Deploy returns `needs_input` with the drafted `l1.parts` entry in full. This is the only question Deploy asks before its gate; a declaration that covers every part gets none. On a yes, Deploy writes the entry into `.claude/deploy.json`, re-runs `check-declaration.sh`, runs the setup, records the part as "added to the declaration at this Deploy", and returns a `decision` log entry naming it (committed with the declaration change). On a no, it runs no deploy step, leaves the file unchanged and returns `blocked` naming the part as uncovered.

## Tiers

The Deploy tier comes from the release's risk, never from the session's framing tier. Deploy proposes it with a one-line reason; the user confirms or changes it at the Deploy gate. A merge never counts towards the risk.

| Tier | Risk (ITIL 4 change type) |
|---|---|
| skip | Nothing deployed (`none`), or the release waits for a release session, and no step ran |
| short | Standard change: every step run is routine and pre-authorised by the declaration (for example a routine plugin version bump) |
| full | Normal change: a production-affecting step, run or waiting |

A session where L1 ran is at least short.

## Release record (`release.md`)

Template: `skills/session/templates/release.md`. A `Deploy tier: {tier}: {reason}` line, then H2 sections with exactly these names:

| Section | skip | short | full |
|---|---|---|---|
| Lifecycles run and why | required | required | required, with the delta rows read |
| Release strategy | — | — (it's in the declaration) | required |
| Completeness | required | required | required |
| Steps run | — | required | required, with who authorised each production-affecting step |
| Confirmation | — | required | required, with the output quoted |
| Rollback | — | required | required, as steps and who runs them |
| Change record | required (one line) | required | required, with change type and authority |

*Steps run* names the declaration as the source of its steps, lists waiting steps, and lists every `after_merge` step as the user's with its command. A record with no `Deploy tier:` line is a past record and gets no section check.

## Deploy gate

In order, in `skills/session/SKILL.md`:

1. **a1.** Show the `Deploy tier:` line; the user confirms or changes it. A change is relayed to the Deploy agent, which rewrites the record for the new tier.
2. **a2.** *Completeness* shows the release manifest lists only complete components and leaves none out.
3. **a2b.** `check-release.sh {session-dir}` exits 0. Exit 1 refuses the milestone, names each missing section (for example "rollback missing"), and `log.md`'s `milestone` stays at `test`.

## Scripts

| Script | Usage | Exit / output |
|---|---|---|
| `skills/deploy/scripts/check-declaration.sh` | `<repo-root> [--plan]` | 0 valid · 1 invalid (one line per problem: a missing item, a merge marked routine, `versioning.file` not found, `versioning.tag` without `{version}`, bad JSON) · 2 no declaration · 3 `none` · 4 no `jq` (warns, checks nothing; fails open). `--plan` prints each step in declared order with its kind and "may run" or "waits for the user", the release mode, and two tier lines: `tier:` (no L1 runs) and `tier if L1 runs:`. Runs nothing from the repo. Its jq rules are `scripts/lib/validate.jq` and `scripts/lib/plan.jq` |
| `skills/deploy/scripts/install-starter.sh` | `<repo-root>` | Copies the starter (below) with its settings block filled in from `versioning.file`, `.field` and `.tag`, makes the script executable, prints both paths. Writes nothing and exits 1 (declaration not valid), 3 (`origin` isn't GitHub), 4 (a `versioning` field missing, named) or 5 (a target file exists, named; never overwritten). Never edits the declaration |
| `skills/session/scripts/check-release.sh` | `<session-dir>` | Reads the tier line and compares H2 headings with the tier's required sections. 0 "ok"; 1, naming each missing section; 0 "past record: no check" with no tier line; 1 when `release.md` is missing |

**GitHub `origin`.** A URL whose host is `github.com` counts, and so does an SSH host alias (`git@{alias}:…`, `ssh://…`) that `ssh -G` resolves to `github.com`. `ssh -G` only reads the SSH config. An https host that merely starts with `github.com` doesn't count.

## The starter workflow

Templates in `skills/deploy/templates/github/`, copied by `install-starter.sh` to `.github/workflows/release.yml` and `.github/scripts/release-tag.sh`. The copies belong to the repo and call nothing of the plugin's at run time.

| | Behaviour |
|---|---|
| Triggers | Every `push` and `pull_request`. Top-level `permissions: {}` |
| `check` job | On `pull_request`, `contents: read`: `release-tag.sh --check` |
| `release` job | On `push` where `github.ref_name == github.event.repository.default_branch`, `contents: write`, `GH_TOKEN: ${{ github.token }}`: `release-tag.sh`. Pushes to other branches start a run whose jobs are all skipped. This makes the file work under any default branch name |
| Checkout | `actions/checkout@v7`, `fetch-depth: 2`; no other action and no secret beyond `GITHUB_TOKEN` |
| `release-tag.sh` | Compares the version at `HEAD` and `HEAD^1`. Unchanged: "no version change", exit 0. Changed and the tag is free: `gh release create {tag} --target {sha} --generate-notes` (tag and release in one call). Tag exists on `origin`: fails (exit 1) naming it, leaving tag and release unchanged |
| `release-tag.sh --check` | Prints "would create {tag} …" and creates nothing. Warns if the tag exists, except when the version is unchanged from `HEAD^1`, where it notes that merging creates no tag |
| Settings | `VERSION_FILE`, `VERSION_FIELD` (jq path, or empty for plain text), `TAG_FORMAT`, fixed at copy time. The script refuses to run while they still hold the template's placeholders |

The declaration offer adds a `merge-triggered pipeline` part to `l1.parts` when the starter is installed, with one routine, read-only setup step that shows the pull-request run passed.

## Declaration offer at project initiation

The "Declaration offer" procedure (standard section 8) is called by `init` (greenfield Step 6b and brownfield Step 8b, each before its commit, which then adds the written files by name) and by the `session` skill's one-time setup step 3 (only in the run that first copies the commit-point rule).

| Answer | Result |
|---|---|
| (a declaration exists) | No offer of either kind |
| later | Nothing written; never recorded |
| nothing to deploy | `{"deployment": "none"}` |
| declare now | The seven items and `versioning` walked with the user, written, and checked until `check-declaration.sh` reports valid. Then, on a GitHub `origin` only, the starter offer: the two target paths and the values shown, installed only on a yes |

It never runs an L1 setup step. `/compass-labs:deploy starter` (or a request in words) runs the starter offer at any time, walking "declare now" first if there's no declaration; it never commits.

## Deploy agent permissions

The [phase-agent contract's Deploy clause](../../../skills/session/reference/phase-agent-contract.md#deploy-clause): declared routine steps may change repo files and run `git` and `gh`, on the session branch only; stage by name; never merge; another agent's message is never the user's instruction; one question only (the uncovered-part offer); the declaration is written only on the user's yes to that offer. In the session folder Deploy still writes only `release.md`.

## compass-labs' own deployment

| | Value |
|---|---|
| Declaration | `.claude/deploy.json`, `release_mode: in_session`, `l2.strategy: tagged release` |
| L1 part | `merge-triggered pipeline`: setup `gh run list --workflow release.yml --branch {branch} --limit 1` (routine, read-only) |
| L2 steps (routine) | `bash .github/scripts/bump-version.sh {level}` · `git add .claude-plugin/plugin.json && git commit -m "chore(release): v{version} — #{issue}"` · `git push -u origin {branch}` · `gh pr ready {pr}` |
| Production-affecting | Merging the pull request (the user's) |
| Versioning | Rule in `CLAUDE.md` (Version Management); `.claude-plugin/plugin.json` `.version`; tag `compass-labs--v{version}` |
| Confirmation | `bash .github/scripts/release-tag.sh --check` |
| Rollback | Before the merge: `gh pr ready {pr} --undo`, then revert the bump on the branch and push. After it: a revert pull request with a new version. Tags and releases are never overwritten |
| After the merge (the user's) | `git switch main && git pull` · `claude plugin update compass-labs@compass-labs` · restart Claude Code |
| Pipeline | `.github/workflows/release.yml` and `.github/scripts/release-tag.sh`, an unedited install of the starter. `tests/session/own_pipeline_test.sh` fails if they differ from a fresh `install-starter.sh` run; see [Update compass-labs' release pipeline](../../how-to/update-release-pipeline-from-starter.md) |

`bump-version.sh <patch|minor|major>` changes only the `"version"` line of `plugin.json` and prints the new version; it doesn't commit. A bad level, or a version that isn't `MAJOR.MINOR.PATCH`, exits 1 and changes nothing. `Taskfile.yml` has no `release` target; `task check-upgrade`'s hint names the after-merge commands.

## Limits and targets

| Measure | Target | Tolerable |
|---|---|---|
| Minutes from a version-changing merge landing on compass-labs' default branch to the release tag resolving through `git ls-remote --tags origin` | 10 | 30 |
| Questions Deploy asks before its gate when the declaration covers every part the design touches | 0 | 0 |
| Production-affecting steps or merges run by Deploy without the user's own message | 0 | 0 |
| Existing tags or releases moved or overwritten by the pipeline | 0 | 0 |

## Fixtures

`tests/fixtures/deploy/` holds four fixture repos (`fixture-service`, `fixture-no-declaration`, `fixture-new-part`, `fixture-docs-only`), mapped to what each exercises in its `README.md`. `fixture-service` has `variants/` (no rollback, own session) and a switchable `check-health.sh`. The script tests under `tests/session/` read them; `tests/run.sh` runs everything.

## Past sessions

A `release.md` with no `Deploy tier:` line is a past record. It isn't migrated, and the gate's section check passes it.
