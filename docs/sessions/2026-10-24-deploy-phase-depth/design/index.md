# Design: Deploy phase depth

> Phase: Design | Started: 2026-10-24 | Status: Ready for the Design gate (all questions resolved 2026-11-03)
> Requirements: [`define/index.md`](../define/index.md) · Session history: [`log.md`](../log.md)

## Contents

- This file only. The primary kind has no in-depth path, so there is no `solution.md` (see Open questions).

## Prior knowledge

- **Read:**
  - `docs/registry/index.md`, `docs/registry/patterns.md` (release completeness; phase-artifact ownership; commit, push, then GitHub; hooks fail open; plugin paths vs. project paths; extend by adding files; session work reaches the default branch only through a pull request; the no-merge anti-pattern).
  - ADRs: [ADR-002](../../../registry/decisions/002-session-lifecycle.md), [ADR-004](../../../registry/decisions/004-design-path.md), [ADR-005](../../../registry/decisions/005-implement-as-built-record.md), [ADR-006](../../../registry/decisions/006-session-branch-guard.md).
  - `docs/reference/constructs/SessionBranchGuard.md`, `docs/explanation/session/overview.md`, `README.md` (project anchor).
  - Code and manifests: `agents/deploy.md`, `agents/orchestrator.md`, `agents/implement.md`, `skills/session/SKILL.md` (one-time setup, Deploy gate a2, no-merge rule, scripts table), `skills/session/workflows/feature.json`, `skills/session/templates/release.md`, `skills/session/reference/phase-agent-contract.md`, `skills/session/scripts/check-design.sh`, `skills/implement/SKILL.md` (the shape of a phase standard), `skills/init/SKILL.md` (greenfield Phase 6 and brownfield Phase 7, their commit steps), `skills/bootstrap-new-project/SKILL.md`, `skills/design/reference/stack-defaults.md`, `hooks/session-guard.sh`, `hooks/session-branch-guard.sh`, `hooks/session-commit-guard.sh`, `Taskfile.yml`, `.claude-plugin/plugin.json` (v2.2.1), `.claude-plugin/marketplace.json`.
  - Issue #38 (`init` writes the project anchor at creation).
  - This session: the frozen `define/` folder (including REQ-026 to REQ-028 and the revised anchor note in `framing.md`, added 2026-11-03) and `log.md`.
- **Not read:** any past session folder, including `docs/sessions/archive/`. Where Define cites archived release records, this design relies on Define's summary of them only.
- **Stack detected:** infrastructure has no signal file (no `*.tf`, no `.github/`). The Terraform default doesn't apply, because no cloud resource is in scope (non-goals #81, #20). The repository's only automation target is its GitHub host.

## Classification

- **Primary kind:** Plugin/tooling: the work is a new standard skill for Deploy (REQ-001, REQ-014, REQ-016), changes to the Deploy agent, its template and the Deploy gate in the plugin (REQ-002 to REQ-013, REQ-015, REQ-017, REQ-025, REQ-027), the declaration offer and the starter workflow (REQ-026, REQ-028), and compass-labs' own release tooling: its declaration and a merge-triggered pipeline (REQ-018 to REQ-024).
- **In-depth path:** none yet: dkoenawan/compass-labs#51, see Open questions.

*Confirmed by the user, 2026-10-31. REQ-026 to REQ-028 (2026-11-03) fall inside the same kind and scope.*

## Scope checklist

*Confirmed by the user, 2026-10-31. Rows updated for REQ-026 to REQ-028, 2026-11-03; no area changes in or out.*

| Area | In scope? | Reason |
|---|---|---|
| Plugin/tooling | in (primary) | The Deploy standard skill, the Deploy agent, the release template, the Deploy gate and one-time setup in the `session` skill, the `init` skill's offer, the declaration contract, the starter workflow and its installer, and plugin registration (REQ-001 to REQ-017, REQ-025 to REQ-028) |
| Process/workflow | in | Inside the Deploy phase: how L1 is told from L2, routine against production-affecting steps, who runs the routine steps, what a release session is, the gate's tier confirmation, and the offer at Deploy for an uncovered part (REQ-005, REQ-006, REQ-009 to REQ-012, REQ-015, REQ-025, REQ-027). The offer at project initiation (REQ-026). No in-depth path: dkoenawan/compass-labs#49 |
| Infrastructure | in (narrow) | compass-labs' merge-triggered pipeline on its repository host (REQ-019 to REQ-024), and the starter a GitHub-hosted repo may copy (REQ-028). No cloud resources, networking or Terraform (non-goals #81, #20). No in-depth path: dkoenawan/compass-labs#50 |
| Tests and fixture repos | in | The fixture repos the criteria name (`fixture-service`, `fixture-no-declaration`, `fixture-new-part`, `fixture-docs-only`) for REQ-003, REQ-004, REQ-006 to REQ-013, REQ-026 to REQ-028, and the harness the plugin already has (`tests/run.sh`) |
| Frontend | out | No live requirement touches a user interface. Per-layer deploy guidance is deferred to #78 |
| Backend | out | No service or API changes. Per-layer deploy guidance is deferred to #79 |
| Database | out | No stored data. Database deploy guidance is deferred to #80 |
| Visual UI design | out | No screens |
| Project docs (`docs/explanation`, `docs/reference`, `docs/registry`) | out | Close folds the shipped result back and writes any ADR flagged here |
| Per-cloud references | out | Deferred to #82 |

## Context view

*Notation: C4 L1 context view, drawn as a Mermaid `flowchart` with delta styling.*

```mermaid
flowchart LR
  classDef new fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef changed fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef deprecated fill:#FEE2E2,stroke:#991B1B,color:#450A0A,stroke-dasharray:4 3
  classDef unchanged fill:#F1F5F9,stroke:#475569,color:#0F172A
  U["User: answers the offers, approves at the gate, merges the PR (person)"]
  PLUGIN["compass-labs plugin: init, session setup, Deploy phase and its standard (software system) [changed]"]:::changed
  DECL["Repo's deploy declaration, .claude/deploy.json (file in each repo) [new]"]:::new
  STARTER["Repo's copy of the starter workflow (files in a GitHub-hosted repo, owned by the repo) [new]"]:::new
  DESIGN["Session's frozen design (session artifact) [unchanged]"]:::unchanged
  TOOLS["Repo's own deploy tooling (external system) [unchanged]"]:::unchanged
  HOST["GitHub: PR, tags, releases, Actions (external system) [unchanged]"]:::unchanged
  PIPE["compass-labs' merge-triggered pipeline (this repo's own L1, installed from the starter) [new]"]:::new
  INSTALL["User's local plugin install (external system) [unchanged]"]:::unchanged
  U -->|"says yes, later or nothing to deploy"| PLUGIN
  PLUGIN -->|"writes on the user's yes; reads steps, check, rollback"| DECL
  PLUGIN -->|"copies on the user's yes"| STARTER
  PLUGIN -->|"reads the delta list for L1"| DESIGN
  PLUGIN -->|"runs routine steps and the check"| TOOLS
  PLUGIN -->|"pushes the branch, marks the PR ready"| HOST
  U -->|"confirms the tier, approves the milestone"| PLUGIN
  U -->|"merges"| HOST
  HOST -->|"merge event"| PIPE
  HOST -->|"merge event"| STARTER
  PIPE -->|"creates the tag and release"| HOST
  U -->|"refreshes, as a listed step"| INSTALL
```

*Notation: C4 component view of the plugin (plugin/tooling), drawn as a Mermaid `flowchart` with delta styling.*

```mermaid
flowchart TB
  classDef new fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef changed fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef deprecated fill:#FEE2E2,stroke:#991B1B,color:#450A0A,stroke-dasharray:4 3
  classDef unchanged fill:#F1F5F9,stroke:#475569,color:#0F172A
  INIT["init skill: greenfield and brownfield (component) [changed]"]:::changed
  ORCH["session skill: one-time setup, Deploy gate (component) [changed]"]:::changed
  AGENT["Deploy agent, agents/deploy.md (component) [changed]"]:::changed
  STD["Deploy standard, skills/deploy/: contract, tiers, offer procedure, starter mode (component) [new]"]:::new
  CD["check-declaration.sh (component) [new]"]:::new
  IS["install-starter.sh (component) [new]"]:::new
  TMPL["Starter templates: release.yml, release-tag.sh (component) [new]"]:::new
  CR["check-release.sh (component) [new]"]:::new
  TPL["release.md template (component) [changed]"]:::changed
  CONTRACT["Phase-agent contract (component) [changed]"]:::changed
  GUARD["Session and branch guards (component) [unchanged]"]:::unchanged
  INIT -->|"follows the offer procedure in"| STD
  ORCH -->|"follows the offer procedure in"| STD
  ORCH -->|"starts, relays the Deploy offer"| AGENT
  ORCH -->|"runs at the gate"| CR
  AGENT -->|"follows"| STD
  AGENT -->|"follows"| CONTRACT
  AGENT -->|"validates and plans with"| CD
  AGENT -->|"writes the record from"| TPL
  STD -->|"runs on the user's yes"| IS
  IS -->|"reads the declaration with"| CD
  IS -->|"copies, filled in"| TMPL
  CR -->|"reads the tier table of"| STD
  GUARD -->|"blocks a push to the default branch by"| AGENT
```

*Notation: simple process flow for the Deploy phase (process/workflow), drawn as a Mermaid `flowchart` with delta styling. `blocked` stops the phase. Steps already in the phase are marked unchanged.*

```mermaid
flowchart TD
  classDef new fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef changed fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef deprecated fill:#FEE2E2,stroke:#991B1B,color:#450A0A,stroke-dasharray:4 3
  classDef unchanged fill:#F1F5F9,stroke:#475569,color:#0F172A
  S1["Validate the declaration [new]"]:::new
  B1["blocked: how to declare, or the missing item (REQ-003, REQ-004) [new]"]:::new
  N1["Record: nothing to deploy (REQ-013) [new]"]:::new
  S2["Completeness check [unchanged]"]:::unchanged
  B2["blocked: names the gap (REQ-017) [unchanged]"]:::unchanged
  S3["Is L1 needed? Declaration against delta list (D9) [new]"]:::new
  O1["Offer: add the uncovered part's L1 setup, as needs_input (REQ-027) [new]"]:::new
  W1["Write the entry, re-validate [new]"]:::new
  B3["blocked: names the uncovered part, declaration unchanged (REQ-011, REQ-027) [new]"]:::new
  S4["Run the L1 setup, record why [new]"]:::new
  S5["Own session? Record: waits for a release session (REQ-012) [new]"]:::new
  S6["Run routine L2 steps, stop at the first production-affecting step (REQ-005, REQ-006) [changed]"]:::changed
  S7["Run the confirmation check [changed]"]:::changed
  B4["blocked: failure and rollback recorded (REQ-008) [new]"]:::new
  S8["Propose the tier, write the record [changed]"]:::changed
  G1["Gate: user confirms the tier, sections checked, milestone approved [changed]"]:::changed
  S1 -->|"no file, or item missing"| B1
  S1 -->|"no deployment"| N1
  S1 -->|"valid"| S2
  N1 --> S8
  S2 -->|"gap"| B2
  S2 -->|"clean"| S3
  S3 -->|"needed, part not covered"| O1
  O1 -->|"user: yes"| W1
  O1 -->|"user: no"| B3
  W1 --> S4
  S3 -->|"needed, part covered"| S4
  S3 -->|"not needed"| S5
  S4 --> S5
  S5 -->|"own session"| S8
  S5 -->|"in session"| S6
  S6 --> S7
  S7 -->|"fails"| B4
  S7 -->|"passes"| S8
  S8 --> G1
```

*Notation: simple process flow for the offers at project initiation (process/workflow), drawn as a Mermaid `flowchart` with delta styling. Both entry points follow the one procedure in the Deploy standard.*

```mermaid
flowchart TD
  classDef new fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef changed fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef deprecated fill:#FEE2E2,stroke:#991B1B,color:#450A0A,stroke-dasharray:4 3
  classDef unchanged fill:#F1F5F9,stroke:#475569,color:#0F172A
  E1["init: greenfield Phase 6 or brownfield Phase 7, before its commit [changed]"]:::changed
  E2["session one-time setup: the run that copies the commit-point rule [changed]"]:::changed
  E3["User asks: /compass-labs:deploy starter, or in words [new]"]:::new
  C1{"Declaration exists? [new]"}:::new
  X1["No offer (REQ-026) [new]"]:::new
  O1["Offer: declare now, nothing to deploy, or later [new]"]:::new
  L1["later: write nothing, carry on [new]"]:::new
  N1["nothing to deploy: write deployment none [new]"]:::new
  D1["declare now: walk REQ-001's seven items, write, validate [new]"]:::new
  C2{"GitHub remote? [new]"}:::new
  O2["Offer the starter: show the files, ask yes or no (REQ-028) [new]"]:::new
  I1["install-starter.sh: copy, filled in from the declaration [new]"]:::new
  Z1["Write nothing more [new]"]:::new
  E1 --> C1
  E2 --> C1
  C1 -->|"yes"| X1
  C1 -->|"no"| O1
  O1 --> L1
  O1 --> N1
  O1 --> D1
  D1 --> C2
  E3 --> C2
  C2 -->|"no"| Z1
  C2 -->|"yes"| O2
  O2 -->|"yes"| I1
  O2 -->|"no"| Z1
```

*Notation: C4 deployment view of the merge-triggered pipeline (infrastructure), drawn as a Mermaid `flowchart` with delta styling. compass-labs' pipeline is the starter's first install (D12).*

```mermaid
flowchart LR
  classDef new fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef changed fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef deprecated fill:#FEE2E2,stroke:#991B1B,color:#450A0A,stroke-dasharray:4 3
  classDef unchanged fill:#F1F5F9,stroke:#475569,color:#0F172A
  subgraph GH["GitHub (deployment node) [unchanged]"]
    REPO["dkoenawan/compass-labs: main, tags, releases [unchanged]"]:::unchanged
    subgraph RUNNER["GitHub Actions runner (deployment node) [unchanged]"]
      WF[".github/workflows/release.yml (workflow) [new]"]:::new
      SCRIPT[".github/scripts/release-tag.sh (script) [new]"]:::new
    end
  end
  subgraph LOCAL["Maintainer's machine (deployment node) [unchanged]"]
    INST["install-starter.sh, run once in Implement (script) [new]"]:::new
    SCRIPT2["release-tag.sh --check, as Deploy's confirmation [new]"]:::new
    CACHE["Local plugin install [unchanged]"]:::unchanged
  end
  INST -.->|"writes, committed on the session branch"| REPO
  REPO -->|"push to main, or pull request"| WF
  WF -->|"calls"| SCRIPT
  SCRIPT -->|"tag and release, GITHUB_TOKEN"| REPO
  SCRIPT2 -->|"reads tags only"| REPO
  REPO -.->|"user pulls and updates"| CACHE
```

## Delta list

Each element this design touches has exactly one status. Every visual matches this list.

| Element | Status | DES | Note |
|---|---|---|---|
| Deploy standard, `skills/deploy/` (`SKILL.md`, `reference/declaration.md`, `reference/frameworks.md`) | new | DES-001, DES-014 | Sets the declaration contract, tiers and frameworks. Holds the offer procedure and the `starter` mode |
| `.claude-plugin/marketplace.json`, `README.md` | changed | DES-001 | List the new skill (release completeness) |
| `skills/deploy/scripts/check-declaration.sh` | new | DES-002 | Plugin script, not a repo command |
| Deploy phase: validate, L1 decision, offer for an uncovered part, stop at production-affecting steps | new | DES-002, DES-004 | The new steps in the Deploy process flow |
| `skills/session/templates/release.md` | changed | DES-003 | Tier line plus seven sections |
| `agents/deploy.md` | changed | DES-004 | Preloads the standard, drops the TODO and the `task release` text, makes the REQ-027 offer |
| `skills/session/reference/phase-agent-contract.md` | changed | DES-005 | Deploy may change repo files and run git and `gh` as declared steps, may write the declaration on the user's yes, and may return `needs_input` for the REQ-027 offer only |
| `skills/session/scripts/check-release.sh` | new | DES-006 | Beside `check-design.sh` |
| `skills/session/SKILL.md` (one-time setup, Deploy gate, scripts table) | changed | DES-007, DES-014 | Tier confirmation and the new check; relays the Deploy offer; a2 stays. One-time setup gains the declaration offer |
| `skills/deploy/templates/github/release-tag.sh` | new | DES-008 | The starter's script. Settings block filled in at copy time (D13) |
| `skills/deploy/templates/github/release.yml` | new | DES-009 | The starter's workflow |
| `.github/scripts/bump-version.sh` | new | DES-010 | compass-labs' own |
| `.claude/deploy.json` (this repo) | new | DES-011 | Declaration read by this session's Deploy. Covers the pipeline part, so no offer fires here |
| `skills/deploy/scripts/install-starter.sh` | new | DES-015 | Copies the starter into a GitHub-hosted repo, on the user's yes |
| `.github/workflows/release.yml`, `.github/scripts/release-tag.sh` (this repo) | new | DES-016 | **Deployable part:** compass-labs' first L1 case, installed from the starter (D12) |
| `skills/init/SKILL.md` | changed | DES-014 | Greenfield and brownfield each gain the offer step before their commit. #38 edits the same file in a different phase |
| `.claude-plugin/plugin.json` | unchanged | — | Implement doesn't touch it. Deploy bumps it as a declared step (REQ-005) |
| `Taskfile.yml`: `release`, `_bump-version`, `_tag-and-push`, `_update-cache` | deprecated | DES-012 | Removed (D11) |
| `Taskfile.yml`: `check-upgrade` | changed | DES-012 | Its hint names `task release`, so the text changes |
| `tests/fixtures/deploy/` and tests for the new scripts | new | DES-013 | Four fixture repos |
| `hooks/session-guard.sh`, `hooks/session-branch-guard.sh`, `hooks/session-commit-guard.sh` | unchanged | — | ADR-006 still blocks a push to the default branch |
| `agents/orchestrator.md` | unchanged | — | Relaying `needs_input` is already the `session` skill's job |
| `skills/session/workflows/feature.json`, `skills/session/scripts/check-design.sh` | unchanged | — | One `release.md` stays (D7) |
| Design standard (`skills/design/`) | unchanged | — | D9 reads the delta list as it is |
| Session's frozen design | unchanged | — | Read by Deploy for L1 |
| Repo's own deploy tooling | unchanged | — | Declared, never supplied by the plugin |
| Repo's copy of the starter (in a consuming repo) | new | DES-015 | Written only on the user's yes. Owned by the repo afterwards |
| GitHub host, Actions runner | unchanged | — | Hosts the new workflow. Repo settings aren't changed |
| User's local plugin install | unchanged | — | Refresh stays the user's step (D4) |
| Maintainer's machine | unchanged | — | Where Deploy and the installer run |
| `skills/bootstrap-new-project/SKILL.md` | unchanged | — | Deprecated before this session. Gets no new work (D1a) |

## Components (DES)

Each item names the `REQ-*` it covers, the result Implement must produce, the check that shows it's done, and the items it depends on.

| ID | Component | Covers | Result | Check | Depends on |
|---|---|---|---|---|---|
| DES-001 | Deploy standard: `skills/deploy/SKILL.md`, `reference/declaration.md`, `reference/frameworks.md`; listed in `marketplace.json` and `README.md` | REQ-001, REQ-012, REQ-014, REQ-016 | The declaration's shape, with a table mapping REQ-001's seven items to named fields, and the optional `versioning` fields the starter reads (see [Declaration shape](#declaration-shape)). The tier table (see [Tier table](#tier-table)). The [execution rules](#execution-rules) and the [L1 rule](#l1-rule) (D9). The release session's definition (D5). The framework verdicts (D10). The skill's description names the starter, so a request in words loads it | A reviewer writes `fixture-service`'s declaration from the standard alone. Each tier has its risk and seven section rows. Rollback and change record each name a framework and verdict. `tests/session/marketplace_test.sh` passes with the skill listed | — |
| DES-002 | `skills/deploy/scripts/check-declaration.sh <repo-root> [--plan]` | REQ-003, REQ-004, REQ-006, REQ-012, REQ-013, REQ-025, REQ-027, REQ-028 | Validates with jq. Reports one of: no declaration, the missing items by name, a merge marked routine, `none`, or valid. When `versioning.file` or `versioning.tag` is present, checks the file exists and the tag form contains `{version}`. `--plan` prints, in declared order, the steps that may run, those waiting for the user, the release mode and the proposed tier with its reason. It runs nothing from the repo. With no jq it warns and exits with a distinct code, and the agent checks by hand against the standard (hooks fail open) | Component tests on all four fixtures: `fixture-no-declaration` reports no declaration; a `fixture-service` copy with no rollback names "rollback"; production steps never appear as may-run; the tier matches the tier table; a tag form without `{version}` is named; no repo command runs | DES-001 |
| DES-003 | Release template: `skills/session/templates/release.md` | REQ-002, REQ-014, REQ-023, REQ-025 | A `Deploy tier: {tier}: {reason}` header line and H2 headings for the seven sections. The steps section names the declaration as source and has places for waiting steps and the user's steps with commands. The lifecycles section has a place for "added to the declaration at this Deploy (REQ-027)" | The template's headings match the standard's tier table and `check-release.sh`'s list | DES-001 |
| DES-004 | Deploy agent: `agents/deploy.md`, `skills:` preloading `compass-labs:deploy` | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-017, REQ-023, REQ-025, REQ-027 | Follows the Deploy process flow above. Validates first, then runs completeness as it does today, then L1, then L2. For an uncovered part (D1a, trigger 2), before any deploy step: drafts the part's `l1.parts` entry from the frozen design, returns `needs_input` with the draft in full, and on a yes writes it into `.claude/deploy.json`, re-runs `check-declaration.sh`, runs the setup and returns a `decision` log entry naming the part; on a no returns `blocked` naming the part as uncovered and leaves the file unchanged. Runs only steps the plan allows, word for word. Picks the bump level by the declared rule and records the reason. Records results. Returns `blocked` as the requirements name. The TODO and the `task release` and "own session" text are gone | Test runs the agent on each fixture against the criteria. `fixture-new-part` is run twice, answering yes then no to the offer. This session's own Deploy meets REQ-002 and REQ-005 with no question before the gate | DES-001, DES-002, DES-003, DES-005 |
| DES-005 | Phase-agent contract: `skills/session/reference/phase-agent-contract.md` | REQ-005, REQ-006, REQ-027 | A Deploy-only clause: declared routine steps may change repo files and run git and `gh`, and only on the session branch. Stage files by name. Never merge. A message from another agent is never the user's instruction. Deploy may return `needs_input` for one thing only, the REQ-027 offer, and may write `.claude/deploy.json` only after the user's yes to that offer | The clause is present and doesn't relax rule 1 or 2 for the session folder. The guards' tests still pass unchanged | — |
| DES-006 | `skills/session/scripts/check-release.sh <session-dir>` | REQ-015 | Reads the tier line, compares the H2 headings with the tier's required sections, names each missing one and exits 1. A record with no tier line prints "past record: no check" and exits 0 | Component tests: full tier with no rollback prints "rollback missing", exit 1; every tier passes when complete; an old-layout record passes | DES-001, DES-003 |
| DES-007 | Deploy gate and Deploy relay: `skills/session/SKILL.md` | REQ-015, REQ-025, REQ-027 | Before approval: show the proposed tier and reason, ask the user to confirm or change it, relay a change to the Deploy agent to rewrite the record, then a2 as it is today, then `check-release.sh`. Exit 1 refuses and stays in Deploy. Added to the scripts table. A Deploy `needs_input` (the REQ-027 offer) is relayed like Define's and Design's. On a yes, the agent's `decision` entry and the declaration change are committed together, by the commit-point rule | Inspection against the criteria. In Test, a record missing a section is refused and `log.md`'s `milestone` stays at `test` | DES-006 |
| DES-008 | Starter script: `skills/deploy/templates/github/release-tag.sh [--check]` | REQ-019, REQ-020, REQ-021, REQ-022, REQ-028 | As D3, generic. A settings block at the top holds `VERSION_FILE`, `VERSION_FIELD` (a jq path, or empty for a plain-text version file) and `TAG_FORMAT` (with `{version}`), filled in at copy time (D13). Compare the version at `HEAD` and `HEAD^1`. Unchanged: log "no version change", exit 0. Changed, tag free: `gh release create {tag} --target {sha} --generate-notes`, so tag and release are created in one call. Tag exists: fail, naming it. `--check` prints the tag it would create, warns if it exists, and creates nothing. No reference to compass-labs or `CLAUDE_PLUGIN_ROOT` | Component tests on a copy filled in with compass-labs' values, against a bare local repo and a stub `gh`: version changed, unchanged, tag exists (the tag doesn't move), and `--check` creates no tag and no release. One more case with a plain-text `VERSION` file | — |
| DES-009 | Starter workflow: `skills/deploy/templates/github/release.yml` | REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-028 | On `push` to the default branch: run the script with `contents: write` and `fetch-depth: 2`. On `pull_request`: run `--check` with `contents: read`. No secret beyond `GITHUB_TOKEN`. No push to a branch. No `uses:` reference to `dkoenawan/compass-labs`; only `actions/checkout` | A test greps the template: no `dkoenawan/compass-labs`, no `CLAUDE_PLUGIN_ROOT`, both triggers and both permission sets present | DES-008 |
| DES-010 | `.github/scripts/bump-version.sh <patch\|minor\|major>` | REQ-005 | Sets `plugin.json`'s version and prints the new one. Doesn't commit | Component test: `2.2.1` with `minor` gives `2.3.0`; a bad level exits 1 and changes nothing | — |
| DES-011 | compass-labs' declaration: `.claude/deploy.json` | REQ-002, REQ-005, REQ-018, REQ-023 | L2 routine: bump (DES-010), commit by name with the issue reference, `git push -u origin {branch}`, `gh pr ready`. Merge: production-affecting. L1 part `merge-triggered pipeline`, whose setup is one routine, read-only step that shows the pull-request run of `release.yml` on the branch passed (`gh run list --workflow release.yml --branch {branch} --limit 1`), so it's safe to repeat (D9). `versioning`: rule in `CLAUDE.md`, file `.claude-plugin/plugin.json`, field `.version`, tag `compass-labs--v{version}`. Confirmation: `.github/scripts/release-tag.sh --check`. Rollback: before the merge, `gh pr ready --undo` and revert the bump on the branch; after it, a revert PR with a new version, because tags are never overwritten. Release mode: in session. After the merge: the D4 commands | `check-declaration.sh` reports valid on it. A reviewer ticks REQ-001's seven items. The four steps are routine and the merge is production-affecting. The pipeline part is listed, so no REQ-027 offer fires in this session's Deploy | DES-001, DES-002, DES-010 |
| DES-012 | `Taskfile.yml` | REQ-002, REQ-022 | Removes `release`, `_bump-version`, `_tag-and-push` and `_update-cache`, since the declaration uses none of them. `check-upgrade`'s hint names the D4 commands | `task --list` shows no `release`, and `task check-upgrade` runs with the new hint | DES-011 |
| DES-013 | Fixtures and script tests: `tests/fixtures/deploy/{fixture-service,fixture-no-declaration,fixture-new-part,fixture-docs-only}/`, tests under `tests/session/` | REQ-003, REQ-004, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-026, REQ-027, REQ-028 | Each fixture has its declaration, its design delta list where the criterion needs one, and harmless steps (`./check-health.sh`, switchable between `healthy` and `unhealthy`). `fixture-service` also declares `versioning` (a JSON version file and a tag form). `fixture-new-part`'s design adds `billing-service`, which its declaration doesn't cover, for REQ-009, REQ-011 and REQ-027. Component tests for DES-002, DES-006, DES-008, DES-010 and DES-015 run from `tests/run.sh`; the DES-015 tests give a temp copy of `fixture-service` a GitHub `origin` and a non-GitHub one. Agent-level runs (the offers, REQ-026 and REQ-027) stay Test's | `tests/run.sh` passes. Test can run each criterion against a fixture with no change to it | DES-002, DES-006, DES-008, DES-010, DES-015 |
| DES-014 | Declaration offer at initiation: the "Declaration offer" procedure in `skills/deploy/SKILL.md`, called from `skills/init/SKILL.md` (greenfield: a new step before Phase 6 Step 7 "Commit"; brownfield: before Phase 7 Step 9 "Commit") and from `skills/session/SKILL.md` one-time setup (a new step 3, run only in the same run that copies the commit-point rule, that is, the repo's first setup) | REQ-026, REQ-028 | One procedure, two callers (D1a). If `.claude/deploy.json` exists, no offer of either kind. Otherwise three answers: **later** (writes nothing, carries on), **nothing to deploy** (writes `{"deployment": "none"}`), **declare now** (walks REQ-001's seven items from the standard, writes, and runs `check-declaration.sh` until valid). After "declare now", if `origin` is on GitHub, offers the starter (DES-015) with the files it would write and the values it would use, and runs it only on a yes. `init` adds the written files to its own commit. The standard's `starter` mode (`/compass-labs:deploy starter`, or a request in words) runs the same starter offer at any time, and never the declaration walk unless no declaration exists. It never runs a setup step | Inspection: both `init` modes and one-time setup call the procedure, and the procedure has the skip rule. Test runs `fixture-no-declaration` through a first session three times (later, nothing to deploy, declare now) and once on a repo that already has a declaration | DES-001, DES-002, DES-015 |
| DES-015 | `skills/deploy/scripts/install-starter.sh <repo-root>` | REQ-028 | Reads `versioning.file`, `versioning.field` and `versioning.tag` from the declaration (through DES-002's validation). Exits with a distinct code and writes nothing if `origin` isn't a GitHub URL, if a `versioning` field is missing (naming it), or if `.github/workflows/release.yml` or `.github/scripts/release-tag.sh` already exists (naming it; never overwrites). Otherwise copies DES-008 and DES-009 with the settings block filled in, makes the script executable, and prints both paths. Adds nothing to the declaration; the offer procedure adds the `merge-triggered pipeline` part to `l1.parts` on the same yes | Component tests: GitHub `origin` writes both files with `fixture-service`'s values and no `dkoenawan/compass-labs` in either; a non-GitHub `origin` writes nothing; an existing workflow file is left byte-for-byte unchanged; a missing `versioning.tag` is named | DES-001, DES-002, DES-008, DES-009 |
| DES-016 | compass-labs' merge-triggered pipeline: `.github/workflows/release.yml`, `.github/scripts/release-tag.sh` | REQ-019, REQ-020, REQ-021, REQ-022, REQ-024 | Produced by running DES-015 on this repo in Implement, from DES-011's `versioning` (D12). Not edited by hand afterwards in this session | The files match a fresh `install-starter.sh` run into a temp copy. The pull-request job runs on PR #77 and reports `compass-labs--v2.3.0`, with no new tag. After the merge: the criteria for REQ-020 and REQ-024 (see Risks on when that can be seen) | DES-011, DES-015 |

**Coverage:** all 28 live REQs covered. REQ-001 to REQ-028 each appear in at least one Covers cell. No deferred or struck row needs cover.

**Implementation order** (from Depends on): DES-001, DES-005, DES-008, DES-010 → DES-002, DES-003, DES-009 → DES-004, DES-006, DES-011, DES-015 → DES-007, DES-012, DES-013, DES-014, DES-016.

### Declaration shape

The standard fixes the fields. `reference/declaration.md` gives a full example for each mode.

| REQ-001 item | Field |
|---|---|
| L1 setup for each deployable part | `l1.parts[]` (`name`, `setup[]`) |
| L2 release steps | `l2.steps[]` (`name`, `run`), in order |
| Which steps are routine | `kind: "routine"` on a step, in `l1` or `l2` |
| Which steps are production-affecting | `kind: "production_affecting"` on a step. A step with `merge: true` must have this kind, or validation fails |
| Confirmation check | `confirmation.run` |
| Rollback | `rollback` (text or commands; never run automatically) |
| Inside the feature session or its own session | `release_mode`: `in_session` or `own_session` |

Other fields: `deployment` (`declared`, or `none` for REQ-013, which needs no other field), `versioning.rule` (the rule, or where the repo states it), `versioning.file`, `versioning.field` and `versioning.tag` (optional; needed only by the starter, REQ-028), `l2.strategy` (D10), `after_merge[]` (the user's steps with commands, REQ-018, REQ-023), and `note` on any object, since JSON has no comments. A `run` value can use `{level}`, `{version}`, `{branch}`, `{issue}` and `{pr}`. The earlier draft's `l1.new_part` recipe is dropped: REQ-027's offer is now the one way a new part gets covered (see Rejected under YAGNI).

### Execution rules

- Steps run in declared order, with L1 before L2. Once a step is waiting for the user, every later step waits too, so nothing runs out of order (REQ-006). If an L1 step is waiting, no L2 step runs.
- The REQ-027 offer comes after validation and completeness, and before any deploy step. It is the only question Deploy asks before its gate. A repo whose declaration covers every part the design touches, compass-labs included, gets no question (REQ-005, OUT-01).
- An entry added by the offer is recorded in the lifecycles section as "added to the declaration at this Deploy", and its setup then runs like any declared part's (REQ-009).
- The confirmation check covers the steps that ran (REQ-007).
- With `own_session`, L1 is still assessed, and the offer can still be made, because REQ-009 applies to every Deploy and L1 setup isn't a release step. Only L2 waits (REQ-012).
- Completeness runs whenever a declaration is valid and not `none` (REQ-017). With `none`, the Completeness section says nothing ships, and a2 treats that as no gap.
- L1 setup steps must be safe to run again, because a covered part's setup runs whenever its row changes (D9).

### L1 rule

L1 is **needed** when any of these holds, and Deploy records which delta rows it read and why (D9):

1. `l1.parts` is empty. Deploy offers entries for the deployable parts the frozen design shows (REQ-027). If the user declines, it returns `blocked`, naming them.
2. A delta row marked `new` or `changed` is a deployable part (a C4 container, a service or a deployed resource) that isn't in `l1.parts`. Deploy offers to add it (REQ-027). On a yes its setup runs (REQ-009). On a no, Deploy returns `blocked` naming the part as uncovered (REQ-011, REQ-027).
3. A delta row marked `new` or `changed` is a part that `l1.parts` already lists. Its declared `setup` runs (Q3, chosen). This session's pipeline is this case.

Otherwise L1 isn't needed (REQ-010).

### Tier table

D6 sets the tiers. This is the table for the standard, against REQ-014's seven sections. A merge never counts towards the risk.

| Section | skip: nothing deployed, or the release waits, and no step ran | short: every step run is routine (standard change) | full: a production-affecting step, run or waiting (normal change) |
|---|---|---|---|
| Lifecycles run and why | required | required | required, with the delta rows read |
| Release strategy | not required | not required (it's in the declaration) | required |
| Completeness | required | required | required |
| Steps run | not required | required | required, with who authorised each production-affecting step |
| Confirmation | not required | required | required, with the output quoted |
| Rollback | not required | required | required, stated as the steps and who runs them |
| Change record | required (one line) | required | required, with the change type and authority |

A session where L1 ran has at least the short tier, even if its release waits. This session's release comes out as short, with the reason REQ-025 expects: its L1 step is routine and read-only.

## Decisions

**ADRs for Close to write:** D1 (the declaration, including D1a's two offers), D2 (refines [ADR-002](../../../registry/decisions/002-session-lifecycle.md), including D2a's starter and D12, D13), D3 (relates to [ADR-006](../../../registry/decisions/006-session-branch-guard.md)). The other decisions need no ADR. D1 to D11 were chosen by the user on 2026-10-31, and D1a, D2a, D9's open case, D2's trade-off, D12 and D13 on 2026-11-03.

**D1: How a repo declares deploy (REQ-001, REQ-003, REQ-004, REQ-018) (ADR).**

| Option | Pros | Cons |
|---|---|---|
| **A JSON declaration file at `.claude/deploy.json`, its shape set by the Deploy standard (chosen)** | Structured, so a missing item can be named mechanically (REQ-004). Stack-independent. jq is already the plugin's parser. Optional: no file means "no declaration" (REQ-003). Sits beside `.claude/rules/` | A new file format to document. JSON has no comments, so the "why" goes in a `note` field |
| A `## Deploy` section in `CLAUDE.md` | No new file. Claude already reads it | Free prose: a missing item can't be found mechanically. Loaded into every conversation. Mixed with unrelated guidance |
| A repo skill (`.claude/skills/deploy/SKILL.md`) | Rich prose and scripts, Claude-native | Heavier. Its structure is unchecked. Loads outside Deploy too |
| A Taskfile target | Executable | Ties the declaration to Task (not stack-independent). Can't state routine against production-affecting, rollback or release mode. `task release` already doesn't fit squash-merge |

The user chose the recommended option, and added: "On project initiation when user use the compass-labs". That addition is D1a.

**D1a: When the declaration is offered (REQ-026, REQ-027) (ADR, with D1).**

| Option | Pros | Cons |
|---|---|---|
| 1. The offer goes in the `session` skill's one-time setup | One place, reached by every repo | Comes at the first session, not at `init` |
| 2. The offer goes in `init`, both modes | Literally at project creation | Misses every repo that never runs `init`. Edits the same skill as #38 |
| **3. Both, skipped if a declaration exists (REQ-026), plus a second trigger at Deploy for a part added later (REQ-027) (chosen)** | Earliest for `init` users, covers every other repo, and keeps the declaration in step as the architecture grows, which is when L1 is needed (NEED-04) | Two initiation entry points to keep in step: met by one procedure in the Deploy standard that both call (DES-014). Deploy gains one question, which needs a contract clause (DES-005) |
| 4. No offer in this session, a follow-up issue holds it | No requirement change | Doesn't do what the user asked |

The user chose option 3 with the skip rule, and added the Deploy-time trigger, on 2026-11-03. REQ-026 and REQ-027 were added to the frozen set by a logged decision.

How the two triggers sit with the other requirements:

- **REQ-009 and REQ-011.** The offer comes before REQ-009's "run the declared setup". A yes makes the part declared, so its setup runs and is recorded as L1. A no is REQ-011's case: no way to set the part up, so no deploy step runs and the part is named.
- **REQ-005 and OUT-01.** The offer is the only question Deploy can ask before its gate, and only for a part the declaration doesn't cover. compass-labs' declaration lists the pipeline (REQ-018, DES-011), so this session's Deploy asks nothing.
- **Only the declaration is set up at initiation, not L1 itself.** Running L1 stays in the Deploy phase (REQ-009). Initiation can copy the starter (REQ-028), but runs no setup step.
- **"Later" is never written down.** One-time setup and `init` each run once, so "later" isn't asked again by the same entry point. A repo that answers "later" at `init` is asked once more at its first session, by the skip rule as the user stated it (see Risks).
- **`bootstrap-new-project` gets nothing:** it's deprecated in favour of `init`. **#38** puts the anchor in `init`'s scaffolding; DES-014 adds a step just before each mode's commit, so the two edits don't overlap.

**D2: Who runs the routine steps (REQ-005, REQ-006, REQ-007; ADR-002) (ADR, refines ADR-002).**

| Option | Pros | Cons |
|---|---|---|
| **The Deploy agent runs every declared step itself, including commit, push and `gh pr ready` (chosen)** | One owner runs and records the release, so `release.md` lists what really ran. Works the same for a consuming repo's staging step (REQ-006) and the check that follows it (REQ-007). No extra round trip. The branch guard still blocks any push to the default branch (ADR-006). The session guard doesn't watch files outside `docs/sessions/` | The phase-agent contract has to say Deploy may change repo files and run git and `gh` as declared steps. Git and `gh` are no longer the orchestrator's alone |
| The orchestrator runs them from a list the Deploy agent returns | Git and `gh` stay with the orchestrator, as today | The orchestrator runs arbitrary declared commands for any repo. The confirmation check has to run after the steps, so the agent is started twice. The record is written after the fact |
| Split: the agent runs the repo's own commands, the orchestrator does the commit, push and PR-ready | Git stays with the orchestrator | compass-labs' declared steps would be run by someone other than Deploy, which goes against REQ-002 |

The user chose the recommended option, and added: "think about where this can be deterministic and be a default GHA". That addition is D2a. The single-responsibility trade-off this choice makes was accepted by the user on 2026-11-03 (Q4).

**D2a: What is deterministic, and the starter GitHub Actions workflow (REQ-028) (ADR, with D2).**

*What is deterministic.* Anything mechanical goes in a script, and the agent keeps judgement and the record.

| Step | Lifecycle | Runs as | Why |
|---|---|---|---|
| Is the declaration there, and complete? | both | Plugin script (DES-002) | Mechanical. Replaces reading by prompt |
| Which steps may run, and which wait? | both | Plugin script (DES-002, `--plan`) | REQ-006 holds by code, not only by prompt |
| Proposed tier | both | Plugin script (DES-002, `--plan`) | D6's signal comes straight from the declaration. The user still confirms it |
| Required sections at the gate | both | Plugin script (DES-006) | D8 |
| Which version level? | L2 | **Agent** | Reads the change against the declared rule, and gives the reason (REQ-005) |
| Version arithmetic | L2 | compass-labs script (DES-010) | Mechanical |
| Commit, push, `gh pr ready` | L2 | Fixed commands from the declaration, **run by the agent** | They act on local work, before any remote event. An Actions job can't push local commits |
| Is L1 needed? | L1 | **Agent** | Reads "deployable part" from the delta list (D9) |
| Drafting an uncovered part's entry | L1 | **Agent**, the user decides | Judgement from the design. The yes or no is the user's (REQ-027) |
| Completeness | both | **Agent, as today** | Judges stubs and TODO bodies. Changing the check is a non-goal |
| Running a repo's declared steps and check | both | **Agent**, on the plan's list | D2. The repo's own tooling does the work |
| Copying the starter | L1 setup, at initiation or on request | Plugin script (DES-015), on the user's yes | Mechanical once the values are in the declaration |
| Pre-merge tag check | L2 | Script, locally and as a pull-request job (DES-008, DES-009) | D3 |
| Tag and publish after the merge | L2 | **GitHub Actions** (DES-016) | D3 (REQ-020) |
| Local plugin refresh | L2 | User | D4. A remote job can't reach it |

*The starter.*

| Option | Pros | Cons |
|---|---|---|
| A. No shipped workflow, a follow-up issue holds the starter | No requirement change | Consuming repos write their own automation |
| **B. An optional starter in the standard (`skills/deploy/templates/github/`), which a repo copies and owns (chosen)** | Repos get a tested pattern. Runs on the repo's own Actions, so not a plugin runtime | Needs a new requirement and a framing revision (both done 2026-11-03). Only fits GitHub and tagged releases |
| C. A reusable workflow hosted here (`uses: dkoenawan/compass-labs/...`) | One copy to maintain | Consuming repos' releases depend at run time on this repo. Closest to the anchor's non-goal |

The user chose B on 2026-11-03 (REQ-028, Could; `framing.md`'s anchor note revised, verdict still "aligns"). How it's built:

- **Where it lives:** `skills/deploy/templates/github/release.yml` and `release-tag.sh` (DES-008, DES-009), copied by `skills/deploy/scripts/install-starter.sh` (DES-015) to `.github/workflows/release.yml` and `.github/scripts/release-tag.sh` in the repo.
- **How it's parameterised:** from the declaration's `versioning.file`, `versioning.field` and `versioning.tag`, written into the copy's settings block at install time (D13).
- **Its fixture and check:** a temp copy of `fixture-service` with a GitHub `origin`, and one without (DES-013, DES-015). The copied script is the one DES-008's tests cover.
- **How "when the user asks" is invoked:** the Deploy standard is a plugin skill, so it is user-invocable. `/compass-labs:deploy starter` runs the starter offer, and a request in words loads the skill by its description. No new command (see Rejected under YAGNI).
- **Never without a yes:** the offer shows both target paths and the values before asking. The installer refuses to overwrite and refuses a non-GitHub `origin`.
- **compass-labs' own pipeline and the starter:** compass-labs' pipeline is the starter's first install (D12, DES-016).

**D3: The merge-triggered pipeline (REQ-019 to REQ-024; ADR-006) (ADR).**

| Option | Pros | Cons |
|---|---|---|
| **A GitHub Actions workflow `.github/workflows/release.yml` that calls one script, `.github/scripts/release-tag.sh` (chosen)** | Native to the host. Needs only `GITHUB_TOKEN` (`contents: write`). The tag is created by Actions on the merge commit, never pushed by Claude (ADR-006). The same script runs the pre-merge check (REQ-019), as a pull-request job and locally, and the harness can test it | GitHub-specific (acceptable: it's compass-labs' own L1, and an option for other repos only through the starter). Two files |
| The same workflow with its logic inline in the YAML | One file | The pre-merge check would repeat the logic. Can't be tested locally |
| release-please or semantic-release | Established, writes changelogs | Wants to own the version bump, which clashes with REQ-005. A new dependency. Opens release PRs of its own |
| A local post-merge hook or task that the user runs | No CI | The user runs a step after the merge (fails REQ-020). Pushes from the user's machine |

Within the chosen option: trigger on `push` to the default branch, and compare the version at `HEAD` with `HEAD^1` (the earlier default-branch tip, for both squash and merge commits). If it changed and the tag doesn't exist: tag `HEAD` and publish with `gh release create --generate-notes`. If it exists: fail and name it (REQ-022). If it didn't change: log "no version change" (REQ-021). `--check` mode prints the tag it would create, and warns if that tag already exists. The user chose the recommended option.

**D4: The local plugin-cache refresh (REQ-023).**

| Option | Pros | Cons |
|---|---|---|
| **Stays a user step, listed in `release.md` with its commands: `git switch main && git pull`, `claude plugin update compass-labs@compass-labs`, restart Claude (chosen)** | Honest about what a remote pipeline can't reach. No new mechanism. The user's install is a local-directory marketplace, which has to be on the merged `main` first | One manual step stays after the merge |
| A `SessionStart` notice in the plugin when the install is behind the latest tag | Reminds the user | Runs in every consuming repo for compass-labs' own problem. Still a user step. No REQ asks for it |
| Move the user's install to the GitHub marketplace source and rely on its updates | Possibly no manual step | Changes the user's setup. The update behaviour hasn't been verified. Needs a restart anyway |

The user chose the recommended option.

**D5: What a separate release session is (REQ-012).**

| Option | Pros | Cons |
|---|---|---|
| **Define it in the Deploy standard only: a later session whose Deploy runs the declared L2 steps for every change since the last release, found from release records that say "waits for a release session". The session type itself goes to a follow-up issue (chosen)** | Meets REQ-012, which asserts only the feature session's side. YAGNI. No workflow change | A repo that declares "own session" has nothing to run that session with yet |
| Build a Release session type now (`workflows/release.json`: Deploy, then Close) | Complete | Large, no REQ asserts it, over the appetite. Touches ADR-002's revisit condition |
| Run it as a Feature session with a skip-tier Define | No new type | Design, Implement and Test have nothing to do. Clumsy |

The user chose the recommended option.

**D6: Deploy tiers and the risk that points to each (REQ-014, REQ-025).**

| Option | Pros | Cons |
|---|---|---|
| **Three tiers named like the plugin's others (skip, short, full), with the risk signal taken from ITIL 4 change types (chosen).** skip: nothing deployed (REQ-013), or the release waits for a release session (REQ-012). short: a standard change, so every step Deploy runs is routine and pre-authorised by the declaration. full: a normal change, so the release has a production-affecting step, run or waiting. The merge doesn't count: every repo has one, and it's always the user's | One vocabulary across the plugin. The signal can be read straight from the declaration (REQ-025). This session's release comes out as short, as REQ-025's criterion expects | ITIL's names (standard, normal) appear only in the reason, not the tier |
| The same three, named after ITIL directly: none, standard, normal | Literal ITIL | A second set of tier names in the plugin |
| Two tiers only, short and full | Simplest | Nothing-to-deploy and waiting records would have to carry sections that say nothing |

The user chose the recommended option. The section rows are in the [Tier table](#tier-table).

**D7: The shape of the release record.**

| Option | Pros | Cons |
|---|---|---|
| **Keep one `release.md`, with a new template: a `Deploy tier` header line plus the seven sections. A record without that line is a past record, and the new gate check skips it (chosen)** | No workflow, guard or allowlist change. Past records aren't migrated and still pass | Its layout is told apart by a header line, not by a folder |
| A `release/` folder (`index.md` plus a file for each lifecycle), as `define/`, `design/` and `implement/` | Matches the other phases. The layout tells old from new | Changes `feature.json`, the guard's tests and the gate. The record is small, so the split isn't needed |

The user chose the recommended option.

**D8: How the gate checks the sections (REQ-015, REQ-025).**

| Option | Pros | Cons |
|---|---|---|
| **A gate script, `skills/session/scripts/check-release.sh`, beside `check-design.sh`. The orchestrator first asks the user to confirm or change the tier. If they change it, it relays that to the Deploy agent to rewrite the record, then runs the script (chosen)** | Mechanical (ADR-002), and testable in the harness. Names the missing section | One more script |
| Orchestrator instruction only, as the completeness check a2 is today | No new code | Holds only by prompt. The plugin's practice is a script for each gate check |

The user chose the recommended option.

**D9: How Deploy tells that L1 is needed (REQ-009, REQ-010, REQ-011, REQ-027).**

| Option | Pros | Cons |
|---|---|---|
| **The Deploy agent compares the declaration's parts with the frozen design's delta list (rows marked `new` or `changed` that are deployable parts: a C4 container, a service or a deployed resource), and records which rows it read and why. A repo with no declared setup always needs L1 (chosen)** | No change to the Design standard. Works with every past design | Judgement: "deployable part" is read, not marked |
| The Design standard adds a "deployable" marker to the delta list, which Deploy reads mechanically | Mechanical | Changes the Design standard, its template and `check-design.sh`. Past designs have no marker |

The user chose the recommended option on 2026-10-31. The open case, a changed part the declaration already covers:

| Option | Pros | Cons |
|---|---|---|
| **A new or changed part that the declaration covers also needs L1, and its declared setup runs (chosen)** | Matches NEED-04 ("created or updated") and OUT-06, so this session's record shows L1 with no special case. No change to requirement text: it reads REQ-009 and REQ-010 together | A part's setup runs whenever its row changes, so setup steps should be safe to repeat. The standard says so |
| L1 needed only for a part the declaration doesn't cover | The literal reading of REQ-009 | OUT-06 isn't met unless the declaration is left without the pipeline, which fails REQ-018. A changed part gets no setup update |

The user chose the recommended option on 2026-11-03 (Q3). The rule is in [L1 rule](#l1-rule).

**D10: The frameworks behind each release-record section (REQ-016).** The user accepted these verdicts, for the Deploy standard's `reference/frameworks.md`:

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
| **Remove `release` and `_tag-and-push` (deprecated: the declaration and the pipeline replace them). Keep `_bump-version` and `_update-cache` only if the declaration uses them (chosen)** | One source of release steps. Nobody can tag a branch commit by hand and clash with the pipeline (REQ-022) | Changes a target someone may have used |
| Leave `Taskfile.yml` unchanged | No change | Two ways to release that disagree. Drift risk, the root cause Define found |

The user chose the recommended option. The declaration uses neither `_bump-version` (it commits, with a message that has no issue reference) nor `_update-cache` (D4 lists plain commands), so both go too (DES-012).

**D12: How the starter relates to compass-labs' own pipeline (REQ-019 to REQ-022, REQ-028) (with D2a's ADR).**

| Option | Pros | Cons |
|---|---|---|
| **A. compass-labs' pipeline is the starter's first install: Implement runs `install-starter.sh` on this repo, so `.github/` holds a filled-in copy (DES-016) (chosen)** | One copy of the logic, tested once (DES-008). The starter gets a real run before any consuming repo uses it: the pull-request job on PR #77 and the merge. compass-labs uses its own product | compass-labs' first release depends on the generic settings handling working. A later fix is made in the template and copied again, or the copy drifts like any repo's |
| B. Two separate things: compass-labs keeps D3's hand-written `.github/` files, and the starter is a second, generic copy in the skill | compass-labs' pipeline stays as simple as D3 drew it, with no settings block | The same logic twice, free to drift. The starter is covered only by component tests, with no real run |

The user chose the recommended option A on 2026-11-03 (Q5): one copy of the logic, and the starter gets a real run on PR #77 and its merge.

**D13: How the starter takes its values from the declaration (REQ-028) (with D2a's ADR).**

| Option | Pros | Cons |
|---|---|---|
| **A. Fixed at copy time: `install-starter.sh` writes `versioning.file`, `versioning.field` and `versioning.tag` into the copied script's settings block (chosen)** | The copy is self-contained and wholly the repo's, which is what "copies and owns" means. CI never reads `.claude/`. Matches REQ-028's criterion directly | Changing the tag form later means editing the copy, or deleting it and installing again |
| B. Read at run time: the copied script reads `.claude/deploy.json` with jq on each run | One source of truth for the values | The repo's CI then depends on a file shape the plugin's standard owns, so a plugin change could break a repo's release: a soft run-time tie to compass-labs. Fails if a repo keeps `.claude/` out of git |

The user chose the recommended option A on 2026-11-03 (Q6): the copy is self-contained and wholly the repo's, with no run-time tie to the plugin's file shape.

## Principles check

SOLID is checked only where it applies. Each item here is a script, a skill, an agent or a workflow, with no substitutable types, so LSP is *n/a* throughout and isn't repeated.

| Item | KISS | YAGNI | SOLID |
|---|---|---|---|
| DES-001 | met | met | SRP met; OCP met: per-layer guidance adds files (#78 to #81); ISP met; DIP met |
| DES-002 | met: reads and reports, runs nothing | met | SRP met; OCP met; ISP met: one validate mode, one plan mode; DIP met: depends on the contract, not on a stack |
| DES-003 | met | met | n/a: a document template, not software |
| DES-004 | met: the offer is one branch of the L1 step | met | SRP: traded off and accepted (D2, Q4); OCP met: repos change by declaration; ISP met; DIP met |
| DES-005 | met | met | n/a: a contract document |
| DES-006 | met: same shape as `check-design.sh` | met | SRP met; OCP met; ISP met; DIP met |
| DES-007 | met | met | SRP met: the orchestrator still only gates and relays; OCP met; ISP met; DIP met |
| DES-008 | met: one settings block, no flags beyond `--check` | met: JSON and plain-text version files only | SRP met; OCP met: other version formats are the repo's edit to its own copy; ISP met; DIP met: no tie to compass-labs |
| DES-009 | met: two triggers, one script | met | SRP met; OCP met; ISP met; DIP met |
| DES-010 | met | met | SRP met: doesn't commit, unlike `_bump-version`; OCP met; ISP met; DIP met |
| DES-011 | met | met | n/a: configuration |
| DES-012 | met: less to keep | met | SRP met; OCP met; ISP met; DIP met |
| DES-013 | met | met: only the fixtures the criteria name, plus a temp `origin` | SRP met; OCP met; ISP met; DIP met |
| DES-014 | met: one procedure, three callers | met: REQ-026, REQ-028 | SRP met: offers and writes the declaration, nothing else; OCP met; ISP met; DIP met: callers depend on the procedure, not on each other |
| DES-015 | met: copy and fill in, refuse otherwise | met: REQ-028 | SRP met: doesn't edit the declaration; OCP met; ISP met; DIP met |
| DES-016 | met: no hand-written logic, installed from the starter (D12) | met | SRP met; OCP met; ISP met; DIP met |
| D1 | met | met | ISP met; DIP met: the agent depends on a contract |
| D1a | met: one procedure for both initiation points | met: REQ-026, REQ-027 | SRP met; OCP met; ISP met; DIP met |
| D2 | met: one owner runs and records | met | **SRP traded off, accepted by the user 2026-11-03 (Q4):** the Deploy agent runs git and `gh` as well as recording, and the orchestrator no longer solely owns them. Reason: the check must follow the steps, and REQ-002 wants what really ran on record. The scripts narrow it by deciding what may run. OCP met; ISP met; DIP met |
| D2a | met: scripts only where the decision is mechanical | met: option B serves REQ-028 | SRP met; OCP met; ISP met; DIP met |
| D3 | met | met | SRP met; OCP met; ISP met; DIP met: GitHub-specific, but only in the repo's own tooling |
| D4 | met | met | n/a: a manual step |
| D5 | met | met | n/a: a definition in a document |
| D6 | met | met | n/a: a classification |
| D7 | met | met | n/a: a document layout |
| D8 | met | met | SRP met; OCP met; ISP met; DIP met |
| D9 | met | met | SRP met; OCP met; ISP met; DIP met |
| D10 | met | met | n/a: framework verdicts |
| D11 | met | met | n/a: removal |
| D12 | met: one copy of the release logic | met | SRP met; OCP met; ISP met; DIP met |
| D13 | met | met | SRP met; OCP met; ISP met; DIP met: the copy depends on nothing of the plugin's at run time |

**Rejected under YAGNI:**
- A step runner that executes declared commands itself: the agent already runs them, and a runner edges towards the deploy-runner non-goal. `--plan` gives the safety without it.
- Running `tests/run.sh` as a pull-request job: useful, but no live REQ asks for CI beyond the check in REQ-019.
- A GitHub Actions job that readies the PR: REQ-002 and REQ-005 have Deploy do it.
- A `SessionStart` notice when the install is behind (D4), a Release session type (D5), a "deployable" marker in the Design standard (D9), a changelog file (D10).
- A reusable workflow hosted here (D2a option C): REQ-028 forbids calling compass-labs at run time.
- The `l1.new_part` recipe from the earlier draft: REQ-027's offer is now the way a new part gets covered, and two ways would make REQ-027's "doesn't cover" ambiguous.
- A separate command for the starter (`commands/…`): the Deploy standard is already user-invocable (`/compass-labs:deploy starter`).
- Offering the starter at Deploy, or at the REQ-027 offer: REQ-028 names initiation and the user's request only.
- Version formats in the starter beyond a JSON field and a plain-text file (TOML, Gradle and so on): no live REQ or fixture needs them. The repo owns its copy and can edit it.
- A stored marker for "later": the entry points each run once, and REQ-026 says decline writes nothing.

## Risks

| Risk | Mitigation |
|---|---|
| **REQ-020, REQ-021, REQ-022 and REQ-024 describe real merges, but this PR merges only after Close, later than the Test gate and its traceability check.** | Test verifies REQ-020 to REQ-022 on the script with a bare repo and a stub `gh`, and verifies the workflow's triggers by inspection, stating that limit. The real result is seen after the merge, against REQ-020 and REQ-024. A failure at that point needs a new fix through a new pull request |
| The first run happens only on this PR's merge. A workflow fault shows only then. By D12, that run is also the starter's first | The pull-request job proves on PR #77 that the workflow file loads and the script runs with the filled-in settings. If the publish step fails after the merge, no tag or release exists yet, so the same `gh release create` can be re-run by the user |
| Repo or account settings stop `GITHUB_TOKEN` from writing or disable Actions [assumed not, unverified] | Implement checks the settings on PR #77 before Deploy. The workflow asks for `contents: write` explicitly |
| Tag exists but the release doesn't, after a partial failure | One `gh release create` call creates both. REQ-022's failure names the tag, so the user can see it |
| A revert PR lowers the version to one already tagged | The run fails visibly by REQ-022 and changes nothing. DES-011's rollback says a revert PR takes a new version |
| The agent runs a step the plan says must wait | `--plan` decides, the Deploy clause and standard forbid it, and the record shows each step's kind for the gate. A prompt-held rule is still only as strong as the agent, so production credentials stay with the user |
| The branch guard reads command text only, so a declared script that pushes to the default branch could pass it (ADR-006's known gap) | compass-labs' declared steps use plain `git push -u origin {branch}`. The standard says declared steps must not push to the default branch |
| A declared `run` value is arbitrary shell | It's the repo's own file, in the repo's own review. The record lists what ran. Deploy never takes steps from elsewhere |
| An entry drafted by the REQ-027 offer has a wrong or unsafe setup step | The user sees the whole entry before saying yes. Its steps carry a kind, so a production-affecting setup step still waits (REQ-006). `check-declaration.sh` validates it before anything runs. The change is committed with its `decision` entry, so it's reviewable in the PR |
| The REQ-027 offer fires in compass-labs' own Deploy and breaks REQ-005's "no question" | DES-011 lists the pipeline part, and its check says no offer fires. If Deploy reads another delta row as a deployable part, the record shows which rows it read |
| A user who answers "later" at `init` is asked again at the first session | Follows the skip rule as stated (only an existing declaration skips). Both offers say "later" is fine and that Deploy will explain how to declare (REQ-003) |
| The starter overwrites a repo's own workflow | `install-starter.sh` refuses if either target exists and names it, tested byte for byte (DES-015) |
| A repo not on GitHub is offered the starter | The offer checks `origin` first, and the installer checks it again and writes nothing |
| "Optional" could read as "Deploy passes with no file" | REQ-003 stops with `blocked`, with no repo command run. A repo with no deploy declares `none`. The standard and the blocked message both say so |
| Agent judgement on "deployable part" misses one (D9) | The record lists the rows it read, and the user sees them at the gate |
| Declared L1 setup isn't safe to repeat (D9's chosen option) | The standard says setup must be safe to re-run. compass-labs' setup step is read-only. The record shows what ran |
| The version bump is committed and pushed before the gate, so the user may want to refuse a bump that has already been made | It's on the session branch, the PR isn't merged, and the user can refuse it at the gate (confirmed at the Define gate). The rollback is declared |
| A gate-time tier change invalidates the record | D8: the Deploy agent rewrites the record, and only then does the check run |
| Removing `task release` breaks a habit | `check-upgrade`'s hint and the README point to the new path |
| #38 and DES-014 both edit `skills/init/SKILL.md` | Different steps (scaffolding against the step before commit). Whichever merges second rebases on the other |

## Open questions

**Resolved 2026-11-03** (logged as a decision by the orchestrator):

- **Q1 (D1a):** both initiation points with the skip rule (REQ-026), plus the Deploy-time offer for an uncovered part (REQ-027). Built as DES-014 and in DES-004, DES-005, DES-007.
- **Q2 (D2a):** option B, the optional starter (REQ-028). Built as DES-008, DES-009, DES-015, and in DES-014.
- **Q3 (D9):** a new or changed covered part also needs L1, and its declared setup runs.
- **Q4 (D2):** the single-responsibility trade-off on the Deploy agent is accepted.
- **Q5 (D12):** A. compass-labs' own pipeline is the starter's first install (DES-016).
- **Q6 (D13):** A. The starter's values are written into the copied script at install time (DES-008, DES-015).

All questions resolved.

**Follow-up issue the orchestrator files:** the Release session type (D5). The offers and the starter are in scope, so they need none.

**No in-depth path:** the primary kind (plugin/tooling) has none: dkoenawan/compass-labs#51. The in-scope process/workflow and infrastructure areas have none either: dkoenawan/compass-labs#49, dkoenawan/compass-labs#50. All three are covered in the all-kinds sections here.
