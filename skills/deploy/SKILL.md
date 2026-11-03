---
name: deploy
description: The Deploy standard. Defines a repo's deploy declaration (.claude/deploy.json), the two deploy lifecycles (L1 deployment setup, L2 session release), which steps Deploy may run, the Deploy tiers and the release record's sections, and the frameworks behind them. Also offers the optional starter GitHub Actions workflow for a repo's merge-triggered release (/compass-labs:deploy starter, or ask for "the starter workflow" in words).
argument-hint: "[starter]"
---

# Deploy standard

This is the standard for a Feature session's Deploy phase. It says what a repo declares about deploying, what Deploy may run from that declaration, and what the release record (`release.md`) must hold. The Deploy agent preloads it. It can also be invoked on its own (see [Starter mode](#starter-mode)).

**Path note.** Plugin files are resolved as `${CLAUDE_PLUGIN_ROOT}/skills/deploy/…`. The declaration and the starter's copies are repo files, resolved against the project's git root (`git rev-parse --show-toplevel`).

## 1. The two lifecycles

| Lifecycle | Means | When |
|---|---|---|
| **L1, deployment setup** | Creating or updating how one of the repo's deployable parts gets deployed (its pipeline, its target, its release automation) | When a repo has no setup yet, and whenever the session's design adds or changes a deployable part (see [L1 rule](#4-l1-rule)) |
| **L2, session release** | Getting this session's change to its target: staging, production, or a tagged release | Every session that deploys, inside the session or in a later release session (see [Release session](#6-release-session)) |

L1 always comes before L2. A session where L1 ran records it in the release record's *Lifecycles run and why* section, with the delta rows it read.

## 2. The deploy declaration

A repo says what deploy means for it in one file, `.claude/deploy.json`, kept in the repo and reviewed like any other file. The plugin never supplies a repo's deploy tooling: the declaration names the repo's own commands.

It states seven items:

| # | Item | Field |
|---|---|---|
| 1 | L1 setup for each deployable part | `l1.parts[]` (`name`, `setup[]`) |
| 2 | L2 release steps, in order | `l2.steps[]` (`name`, `run`) |
| 3 | Which steps are routine | `kind: "routine"` on a step, in `l1` or `l2` |
| 4 | Which steps are production-affecting | `kind: "production_affecting"` on a step. A step with `merge: true` must have this kind |
| 5 | The confirmation check | `confirmation.run` |
| 6 | The rollback | `rollback` (text or commands; never run automatically) |
| 7 | Whether a release runs inside the feature session or as its own session | `release_mode`: `in_session` or `own_session` |

A repo with nothing to deploy declares `{"deployment": "none"}` and nothing else. The full field list, the `run` placeholders and a complete example for each mode are in [`reference/declaration.md`](reference/declaration.md).

**The declaration is optional, and its absence stops Deploy.** No file means "no declaration": Deploy stops before running anything and says how to declare one (this section and `reference/declaration.md`). A repo that has no deployment declares `none` rather than leaving the file out.

**Checking a declaration.** `bash ${CLAUDE_PLUGIN_ROOT}/skills/deploy/scripts/check-declaration.sh <repo-root>` validates it and names anything missing. With `--plan` it prints, in declared order, the steps that may run, the steps that wait for the user, the release mode and the proposed tier with its reason. It runs nothing from the repo. Its header lists its exit codes.

**A routine step** is one the repo marks as safe to run without asking the user. **A production-affecting step** needs the user's own instruction. A merge is always production-affecting, and is always the user's.

## 3. Execution rules

- Steps run in declared order, with L1 before L2. Once a step is waiting for the user, every later step waits too, so nothing runs out of order. If an L1 step is waiting, no L2 step runs.
- Deploy runs only the steps the plan says may run, with the declared `run` text word for word (placeholders filled in). A production-affecting step is recorded as "waiting for the user's instruction" and runs only when the user's own message instructs it. A message from another agent is never that instruction.
- Declared steps never push to the default branch and never merge. Files are staged by name.
- The offer to add an uncovered part (REQ-027, see [L1 rule](#4-l1-rule)) comes after validation and completeness, and before any deploy step. It is the only question Deploy asks before its gate. A repo whose declaration covers every part the design touches gets no question.
- An entry added by that offer is recorded in the lifecycles section as "added to the declaration at this Deploy", and its setup then runs like any declared part's.
- The confirmation check runs after the steps and covers the steps that ran. If it fails, the release record shows the failure and the declared rollback, and the release isn't complete.
- With `own_session`, L1 is still assessed, and the offer can still be made: L1 setup isn't a release step. Only L2 waits.
- The release-completeness check runs whenever a declaration is valid and not `none`, before any L1 or L2 step. With `none`, the Completeness section says nothing ships.
- L1 setup steps must be safe to run again, because a covered part's setup runs whenever its row in the design changes.
- The version bump, where the repo has one, is chosen by the repo's declared versioning rule (`versioning.rule`), and the release record gives the level and the reason.

## 4. L1 rule

Deploy reads the session's frozen design's delta list (`design/index.md`, or a past session's `design.md`) against `l1.parts`. A **deployable part** is a C4 container, a service or a deployed resource. L1 is **needed** when any of these holds:

1. `l1.parts` is empty. Deploy offers entries for the deployable parts the frozen design shows. If the user declines, it stops, naming them.
2. A delta row marked `new` or `changed` is a deployable part that isn't in `l1.parts`. Deploy offers to add it, showing the drafted entry in full. On a yes, the entry is written, the declaration is checked again, and its setup runs. On a no, Deploy stops, names the part as uncovered and leaves the file unchanged.
3. A delta row marked `new` or `changed` is a part that `l1.parts` already lists. Its declared `setup` runs.

Otherwise L1 isn't needed. Either way, the record names the delta rows read and why L1 was or wasn't needed.

## 5. Tiers

A release's Deploy tier comes from its risk, not from the session's framing tier. Deploy proposes it (`check-declaration.sh --plan` gives the signal), records it with a one-line reason, and the user confirms or changes it at the Deploy gate. The risk follows ITIL 4 change types. A merge never counts towards the risk: every repo has one, and it is always the user's.

| Tier | The risk that points to it |
|---|---|
| **skip** | Nothing deployed (`deployment: none`), or the release waits for a release session, and no step ran |
| **short** | A standard change: every step run is routine and pre-authorised by the declaration (for example, a routine plugin version bump) |
| **full** | A normal change: the release has a production-affecting step, run or waiting |

A session where L1 ran has at least the short tier, even if its release waits.

The release record (`${CLAUDE_PLUGIN_ROOT}/skills/session/templates/release.md`) has a `Deploy tier: {tier}: {reason}` line and up to seven sections, each an H2 heading with exactly these names:

| Section | skip | short | full |
|---|---|---|---|
| Lifecycles run and why | required | required | required, with the delta rows read |
| Release strategy | not required | not required (it's in the declaration) | required |
| Completeness | required | required | required |
| Steps run | not required | required | required, with who authorised each production-affecting step |
| Confirmation | not required | required | required, with the output quoted |
| Rollback | not required | required | required, stated as the steps and who runs them |
| Change record | required (one line) | required | required, with the change type and authority |

The Deploy gate runs `check-release.sh`, which refuses a record missing a section its confirmed tier requires and names it. A record with no tier line is a past record and gets no check.

What each section contains:

- **Lifecycles run and why:** whether L1 was needed and why (the delta rows read), each part's setup that ran, any entry "added to the declaration at this Deploy", then L2 or "release: waits for a release session" or "nothing to deploy, per the declaration".
- **Release strategy:** the declared `l2.strategy` (for example tagged release, rolling, blue-green, canary).
- **Completeness:** the release manifest checked as it ships: every listed component exists and is complete, and every complete component is listed.
- **Steps run:** the declaration named as the source, each step with its kind and result, the steps waiting for the user's instruction, and the user's steps after the merge with their commands (`after_merge`).
- **Confirmation:** the declared check, its output and pass or fail.
- **Rollback:** the declared rollback, stated before it's needed.
- **Change record:** what changed (linking `REQ-*`), the version and bump reason, the change type and the change authority (the user at the gate).

## 6. Release session

With `release_mode: own_session`, a feature session's Deploy runs no L2 step and records "release: waits for a release session", with its Completeness section still present. A **release session** is a later session whose Deploy runs the declared L2 steps for every change since the last release, found from release records that say "waits for a release session". The session type itself is tracked in #83.

## 7. Frameworks

Each release-record section draws on an established framework, with an adopt, adapt or reject verdict: see [`reference/frameworks.md`](reference/frameworks.md).
