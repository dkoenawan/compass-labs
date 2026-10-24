# Design: Deploy phase depth

> Phase: Design | Started: 2026-10-24 | Status: Draft (classification and scope awaiting confirmation)
> Requirements: [`define/index.md`](../define/index.md) · Session history: [`log.md`](../log.md)

## Contents

- This file only, so far. The primary kind has no in-depth path, so there is no `solution.md` (see Open questions).

## Prior knowledge

- **Read:**
  - `docs/registry/index.md`, `docs/registry/patterns.md` (release completeness; phase-artifact ownership; commit, push, then GitHub; hooks fail open; plugin paths vs. project paths; extend by adding files; session work reaches the default branch only through a pull request; the no-merge anti-pattern).
  - ADRs: [ADR-002](../../../registry/decisions/002-session-lifecycle.md), [ADR-004](../../../registry/decisions/004-design-path.md), [ADR-005](../../../registry/decisions/005-implement-as-built-record.md), [ADR-006](../../../registry/decisions/006-session-branch-guard.md).
  - `docs/reference/constructs/SessionBranchGuard.md`, `docs/explanation/session/overview.md`, `README.md` (project anchor).
  - Code and manifests: `agents/deploy.md`, `agents/orchestrator.md`, `skills/session/SKILL.md` (Deploy gate a2, no-merge rule), `skills/session/workflows/feature.json`, `skills/session/templates/release.md`, `skills/session/reference/phase-agent-contract.md`, `skills/implement/SKILL.md` (the shape of a phase standard), `hooks/session-guard.sh`, `Taskfile.yml` (`release`, `_bump-version`, `_tag-and-push`, `_update-cache`), `.claude-plugin/plugin.json` (v2.2.1), `.claude-plugin/marketplace.json`.
  - This session: the frozen `define/` folder and `log.md`.
- **Not read:** any past session folder, including `docs/sessions/archive/`. Where Define cites archived release records, this design relies on Define's summary of them only.

## Classification

- **Primary kind:** Plugin/tooling: the work is a new standard skill for Deploy (REQ-001, REQ-014, REQ-016), changes to the Deploy agent, its template and the Deploy gate in the plugin (REQ-002 to REQ-013, REQ-015, REQ-017, REQ-025), and compass-labs' own release tooling: its declaration and a merge-triggered pipeline (REQ-018 to REQ-024).
- **In-depth path:** none yet: dkoenawan/compass-labs#51, see Open questions.

*Awaiting the user's confirmation.*

## Scope checklist

*Awaiting the user's confirmation.*

| Area | In scope? | Reason |
|---|---|---|
| Plugin/tooling | in (primary) | The Deploy standard skill, the Deploy agent, the release template, the Deploy gate in the `session` skill, the declaration contract, and plugin registration (REQ-001 to REQ-017, REQ-025) |
| Process/workflow | in | Inside the Deploy phase: how L1 is told from L2, routine against production-affecting steps, who runs the routine steps, what a release session is, and the gate's tier confirmation (REQ-005, REQ-006, REQ-009 to REQ-012, REQ-015, REQ-025). No in-depth path: dkoenawan/compass-labs#49 |
| Infrastructure | in (narrow) | compass-labs' merge-triggered pipeline on its repository host (REQ-019 to REQ-024). No cloud resources, networking or Terraform (non-goals #81, #20). No in-depth path: dkoenawan/compass-labs#50 |
| Tests and fixture repos | in | The fixture repos the criteria name (`fixture-service`, `fixture-no-declaration`, `fixture-new-part`, `fixture-docs-only`) for REQ-003, REQ-004, REQ-006 to REQ-013, and the harness the plugin already has (`tests/run.sh`) |
| Frontend | out | No live requirement touches a user interface. Per-layer deploy guidance is deferred to #78 |
| Backend | out | No service or API changes. Per-layer deploy guidance is deferred to #79 |
| Database | out | No stored data. Database deploy guidance is deferred to #80 |
| Visual UI design | out | No screens |
| Project docs (`docs/explanation`, `docs/reference`, `docs/registry`) | out | Close folds the shipped result back and writes any ADR flagged here |
| Per-cloud references | out | Deferred to #82 |

## Context view

*Drawn once classification and scope are confirmed.*

## Delta list

*Written once classification and scope are confirmed.*

## Components (DES)

*Pending.*

## Decisions

*Draft. Every choice below is waiting for the user. "Recommended" marks the agent's recommendation, not a choice. These assume the classification above. If the user changes it, they get revisited.*

**D1: How a repo declares deploy (REQ-001, REQ-003, REQ-004, REQ-018) (ADR).**

| Option | Pros | Cons |
|---|---|---|
| **A JSON declaration file at `.claude/deploy.json`, its shape set by the Deploy standard (recommended)** | Structured, so a missing item can be named mechanically (REQ-004). Stack-independent. jq is already the plugin's parser. Optional: no file means "no declaration" (REQ-003). Sits beside `.claude/rules/` | A new file format to document. JSON has no comments, so the "why" goes in a `note` field |
| A `## Deploy` section in `CLAUDE.md` | No new file. Claude already reads it | Free prose: a missing item can't be found mechanically. Loaded into every conversation. Mixed with unrelated guidance |
| A repo skill (`.claude/skills/deploy/SKILL.md`) | Rich prose and scripts, Claude-native | Heavier. Its structure is unchecked. Loads outside Deploy too |
| A Taskfile target | Executable | Ties the declaration to Task (not stack-independent). Can't state routine against production-affecting, rollback or release mode. `task release` already doesn't fit squash-merge |

**D2: Who runs the routine steps (REQ-005, REQ-006, REQ-007; ADR-002) (ADR, refines ADR-002).**

| Option | Pros | Cons |
|---|---|---|
| **The Deploy agent runs every declared step itself, including commit, push and `gh pr ready` (recommended)** | One owner runs and records the release, so `release.md` lists what really ran. Works the same for a consuming repo's staging step (REQ-006) and the check that follows it (REQ-007). No extra round trip. The branch guard still blocks any push to the default branch (ADR-006). The session guard doesn't watch files outside `docs/sessions/` | The phase-agent contract has to say Deploy may change repo files and run git and `gh` as declared steps. Git and `gh` are no longer the orchestrator's alone |
| The orchestrator runs them from a list the Deploy agent returns | Git and `gh` stay with the orchestrator, as today | The orchestrator runs arbitrary declared commands for any repo. The confirmation check has to run after the steps, so the agent is started twice. The record is written after the fact |
| Split: the agent runs the repo's own commands, the orchestrator does the commit, push and PR-ready | Git stays with the orchestrator | compass-labs' declared steps would be run by someone other than Deploy, which goes against REQ-002 |

**D3: The merge-triggered pipeline (REQ-019 to REQ-024; ADR-006) (ADR).**

| Option | Pros | Cons |
|---|---|---|
| **A GitHub Actions workflow `.github/workflows/release.yml` that calls one script, `.github/scripts/release-tag.sh` (recommended)** | Native to the host. Needs only `GITHUB_TOKEN` (`contents: write`). The tag is created by Actions on the merge commit, never pushed by Claude (ADR-006). The same script runs the pre-merge check (REQ-019), as a pull-request job and locally, and the harness can test it | GitHub-specific (acceptable: it's compass-labs' own L1, not something the plugin ships for others). Two files |
| The same workflow with its logic inline in the YAML | One file | The pre-merge check would repeat the logic. Can't be tested locally |
| release-please or semantic-release | Established, writes changelogs | Wants to own the version bump, which clashes with REQ-005. A new dependency. Opens release PRs of its own |
| A local post-merge hook or task that the user runs | No CI | The user runs a step after the merge (fails REQ-020). Pushes from the user's machine |

Within the recommended option: trigger on `push` to the default branch, and compare `plugin.json`'s version at `HEAD` with `HEAD^1` (the earlier default-branch tip, for both squash and merge commits). If it changed and `compass-labs--v{version}` doesn't exist: tag `HEAD` and run `gh release create --generate-notes`. If it exists: fail and name it (REQ-022). If it didn't change: log "no version change" (REQ-021). `--check` mode prints the tag it would create, and warns if that tag already exists.

**D4: The local plugin-cache refresh (REQ-023).**

| Option | Pros | Cons |
|---|---|---|
| **Stays a user step, listed in `release.md` with its commands: `git switch main && git pull`, `claude plugin update compass-labs@compass-labs`, restart Claude (recommended)** | Honest about what a remote pipeline can't reach. No new mechanism. The user's install is a local-directory marketplace, which has to be on the merged `main` first | One manual step stays after the merge |
| A `SessionStart` notice in the plugin when the install is behind the latest tag | Reminds the user | Runs in every consuming repo for compass-labs' own problem. Still a user step. No REQ asks for it |
| Move the user's install to the GitHub marketplace source and rely on its updates | Possibly no manual step | Changes the user's setup. The update behaviour hasn't been verified. Needs a restart anyway |

**D5: What a separate release session is (REQ-012).**

| Option | Pros | Cons |
|---|---|---|
| **Define it in the Deploy standard only: a later session whose Deploy runs the declared L2 steps for every change since the last release, found from release records that say "waits for a release session". The session type itself goes to a follow-up issue (recommended)** | Meets REQ-012, which asserts only the feature session's side. YAGNI. No workflow change | A repo that declares "own session" has nothing to run that session with yet |
| Build a Release session type now (`workflows/release.json`: Deploy, then Close) | Complete | Large, no REQ asserts it, over the appetite. Touches ADR-002's revisit condition |
| Run it as a Feature session with a skip-tier Define | No new type | Design, Implement and Test have nothing to do. Clumsy |

**D6: Deploy tiers and the risk that points to each (REQ-014, REQ-025).**

| Option | Pros | Cons |
|---|---|---|
| **Three tiers named like the plugin's others (skip, short, full), with the risk signal taken from ITIL 4 change types (recommended).** skip: nothing deployed (REQ-013), or the release waits for a release session (REQ-012). short: a standard change, so every step Deploy runs is routine and pre-authorised by the declaration. full: a normal change, so the release has a production-affecting step, run or waiting. The merge doesn't count: every repo has one, and it's always the user's | One vocabulary across the plugin. The signal can be read straight from the declaration (REQ-025). This session's release comes out as short, as REQ-025's criterion expects | ITIL's names (standard, normal) appear only in the reason, not the tier |
| The same three, named after ITIL directly: none, standard, normal | Literal ITIL | A second set of tier names in the plugin |
| Two tiers only, short and full | Simplest | Nothing-to-deploy and waiting records would have to carry sections that say nothing |

**D7: The shape of the release record.**

| Option | Pros | Cons |
|---|---|---|
| **Keep one `release.md`, with a new template: a `Deploy tier` header line plus the seven sections. A record without that line is a past record, and the new gate check skips it (recommended)** | No workflow, guard or allowlist change. Past records aren't migrated and still pass | Its layout is told apart by a header line, not by a folder |
| A `release/` folder (`index.md` plus a file for each lifecycle), as `define/`, `design/` and `implement/` | Matches the other phases. The layout tells old from new | Changes `feature.json`, the guard's tests and the gate. The record is small, so the split isn't needed |

**D8: How the gate checks the sections (REQ-015, REQ-025).**

| Option | Pros | Cons |
|---|---|---|
| **A gate script, `skills/session/scripts/check-release.sh`, beside `check-design.sh`. The orchestrator first asks the user to confirm or change the tier. If they change it, it relays that to the Deploy agent to rewrite the record, then runs the script (recommended)** | Mechanical (ADR-002), and testable in the harness. Names the missing section | One more script |
| Orchestrator instruction only, as the completeness check a2 is today | No new code | Holds only by prompt. The plugin's practice is a script for each gate check |

**D9: How Deploy tells that L1 is needed (REQ-009, REQ-010, REQ-011).**

| Option | Pros | Cons |
|---|---|---|
| **The Deploy agent compares the declaration's parts with the frozen design's delta list (rows marked `new` or `changed` that are deployable parts: a C4 container, a service or a deployed resource), and records which rows it read and why. A repo with no declared setup always needs L1 (recommended)** | No change to the Design standard. Works with every past design | Judgement: "deployable part" is read, not marked |
| The Design standard adds a "deployable" marker to the delta list, which Deploy reads mechanically | Mechanical | Changes the Design standard, its template and `check-design.sh`. Past designs have no marker |

**D10: The frameworks behind each release-record section (REQ-016).** Proposed verdicts, to go into the Deploy standard's `reference/frameworks.md`:

| Section | Framework | Verdict | Reason |
|---|---|---|---|
| Lifecycles run and why | Continuous Delivery (Humble and Farley): the deployment pipeline | adapt | L1 is creating or changing a part's pipeline. L2 is a run through it |
| Lifecycles run and why | ITIL 4 deployment management against release management | adapt | Keeps "put in place" apart from "made available". The plugin names them L1 and L2 |
| Release strategy | SRE release engineering, and the Continuous Delivery strategies (big bang, rolling, blue-green, canary) | adapt | Name one strategy for each release. A plugin's is "tagged release" |
| Completeness | The plugin's "never ship an incomplete product" pattern | adopt | Kept as is (a non-goal to change it) |
| Steps run | SRE release engineering: reproducible, declared steps | adapt | The steps come from the declaration word for word, with each step's kind |
| Confirmation | SRE post-release verification, and DORA's change failure rate | adapt | A declared check with a recorded pass or fail. The metric isn't collected |
| Rollback | SRE workbook ("roll back first"), and ITIL 4 remediation | adapt | The declared rollback, stated before it's needed |
| Change record | ITIL 4 change enablement: change record, change type, change authority | adapt | The user at the gate is the change authority. The type sets the tier (D6) |
| Change record | SemVer | adopt | The versioning rule a repo declares, such as compass-labs' `CLAUDE.md` rules |
| Change record | Keep a Changelog | reject | A repo changelog file, which no REQ asks for |
| Confirmation and rollback | DORA four keys as collected metrics | reject | Measuring them is a runtime concern (an anchor non-goal). Cited only as the reason for both sections |
| Tiers | ITIL 4 change types (standard, normal, emergency) | adapt | standard points to short, normal to full. Emergency is rejected: no REQ covers it |

**D11: `task release` in `Taskfile.yml` (REQ-002, REQ-022).**

| Option | Pros | Cons |
|---|---|---|
| **Remove `release` and `_tag-and-push` (deprecated: the declaration and the pipeline replace them). Keep `_bump-version` and `_update-cache` only if the declaration uses them (recommended)** | One source of release steps. Nobody can tag a branch commit by hand and clash with the pipeline (REQ-022) | Changes a target someone may have used |
| Leave `Taskfile.yml` unchanged | No change | Two ways to release that disagree. Drift risk, the root cause Define found |

## Principles check

*Pending.*

## Risks

*Pending.*

## Open questions

- The primary kind (plugin/tooling) has no in-depth path: dkoenawan/compass-labs#51. The in-scope process/workflow and infrastructure areas have none either: dkoenawan/compass-labs#49, dkoenawan/compass-labs#50. All three are covered in the all-kinds sections here.
