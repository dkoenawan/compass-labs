---
id: "008"
date: 2026-11-03
status: Accepted
deciders: [Daniel Koenawan]
affects: [deploy, session, DeployStandard, DeclarationCheck, ReleaseRecordCheck, StarterInstaller, ReleaseTagStarter]
issue: https://github.com/dkoenawan/compass-labs/issues/30
---

# ADR-008: The Deploy agent runs the declared routine steps itself; scripts decide what's mechanical; an optional starter workflow is copied into the repo

> Origin: #30

## Context

Under [ADR-002](002-session-lifecycle.md), phase agents write only their own artifact and `git` and `gh` were the orchestrator's. A release, though, is a sequence of commands (bump, commit, push, mark the pull request ready, or a consuming repo's staging rollout) followed by a check that has to run after them, and the record should list what really ran. Routine steps had been left for someone to run by hand, and the steps after a merge had no automation at all.

Constraints: no merge and no production-affecting step without the user's own instruction; the branch guard ([ADR-006](006-session-branch-guard.md)) still blocks pushes to the default branch; a consuming repo's release must never depend on compass-labs at run time.

## Decision

We will have **the Deploy agent run every declared step the plan allows itself**, `git` and `gh` included, and record them. A Deploy clause in the phase-agent contract limits this: declared steps only, on the session branch only, files staged by name, never a merge, another agent's message never counts as the user's instruction, one question only (the uncovered-part offer), and the declaration written only on the user's yes to it. In the session folder Deploy still writes only `release.md`.

**Anything mechanical is a script; the agent keeps judgement and the record.** Validation, which steps may run, the proposed tier (`check-declaration.sh --plan`) and the gate's section check (`check-release.sh`) are scripts. The bump level, whether L1 is needed, drafting an uncovered part, completeness and running the repo's commands are the agent's. The tier follows the release's risk (ITIL 4 change type: skip, short, full), not the session's framing tier, and the user confirms it at the gate before the sections are checked.

**An optional starter GitHub Actions workflow** (`skills/deploy/templates/github/`) is offered at initiation after "declare now", or on request (`/compass-labs:deploy starter`), on GitHub-hosted repos only, and installed only on a yes by `install-starter.sh`. Its values (version file, field, tag form) are **fixed at copy time** from the declaration, and the copy belongs to the repo. compass-labs' own pipeline is **the starter's first install**, unedited.

This **refines [ADR-002](002-session-lifecycle.md)**: one phase agent may now change repo files and run `git` and `gh`, as declared steps, without changing who writes what in the session folder.

## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Deploy agent runs every declared step (chosen)** | One owner runs and records the release; the check follows the steps in one run; same for any repo | `git` and `gh` are no longer the orchestrator's alone; the agent trades off single responsibility (accepted) | — chosen |
| Orchestrator runs steps from a list the agent returns | `git` stays with the orchestrator | The orchestrator runs arbitrary repo commands; the agent is started twice; the record is written after the fact | Worse ownership, extra round trip |
| Agent runs repo commands, orchestrator does commit/push/PR | `git` stays with the orchestrator | A repo's declared steps run by someone other than Deploy; the record splits | Breaks "the record lists what ran" |

| Starter option | Why |
|---|---|
| No shipped workflow | Rejected: every repo writes its own automation |
| **Optional starter the repo copies and owns (chosen)** | A tested pattern that runs on the repo's own Actions; no run-time tie to the plugin |
| Reusable workflow hosted in compass-labs (`uses: …`) | Rejected: consuming repos' releases would depend on this repo at run time |
| Values read at run time from `.claude/deploy.json` | Rejected: CI would depend on a file shape the plugin owns |
| compass-labs keeps hand-written `.github/` files beside a generic starter | Rejected: the same logic twice, free to drift, and the starter gets no real run |

## NFR Captured

- Safety: production-affecting steps wait for the user by code (`--plan`), not only by prompt; the record shows every step's kind at the gate.
- Independence: a repo's copy of the starter calls nothing of the plugin's and needs no secret beyond `GITHUB_TOKEN`.
- Proportionate: the release record's depth follows the release's risk, confirmed by the user.

## Consequences

**Now easier**: A routine release with no prompts before the gate; one record of what ran; repos on GitHub get a tested tag-and-publish pipeline for the price of a yes.
**Now harder**: Reviewing Deploy means reviewing commands it ran, not a list it proposed; a fix to the starter reaches a repo only if it reinstalls its copy.
**New constraints**: The version bump is committed and pushed before the gate, so refusing it means reverting it on the session branch. compass-labs' `.github/` copies are never edited by hand; `own_pipeline_test.sh` checks they match a fresh install.

## Revisit Conditions

If a declared step ever runs that the plan said must wait, or if repos need the starter on hosts other than GitHub or with version formats beyond a JSON field and a plain-text file, re-evaluate.
