---
id: "012"
date: 2026-11-26
status: Accepted
deciders: [Daniel Koenawan]
affects: [session, orchestrator, define, design, implement, test, deploy, close, framing, problem-statement, requirements, verification, backend, explore, doc-maintainer, brand-designer, post-hook-validator, bootstrap-new-project, SessionGuard, SessionCommitGuard, SessionBranchGuard]
issue: https://github.com/dkoenawan/compass-labs/issues/102
supersedes: ["001", "002", "004", "005", "006", "008"]
---

# ADR-012: Retire the gated Feature session pipeline; pstack runs the work and the PR is the single review point

> Origin: #102

## Context

ADR-011 made the official pstack the work layer. That left two ways to build a feature:
1. The Feature session (ADR-002), with an orchestrator, six phase agents, a standard per phase, write-ownership hooks, and a stop for the maintainer at every phase.
2. One pstack `poteto-mode` run that plans, builds and verifies without stopping, then opens a PR.

The maintainer has about an hour a week. The session's seven stops per feature (six gates and the merge) are what made progress slow. Keeping both paths means maintaining both and choosing between them on every task.

The maintainer compared the two workflows stage by stage ([workflow comparison](../../explanation/workflow-today-vs-future.html)) and chose to retire the session pipeline, with three conditions:
- Historical docs are kept.
- PRs lead with a summary, and the detail stays one click away.
- Overridden ADRs are removed from the tree and listed as Archived, linked to their last commit.

## Decision

We will **remove the Feature session pipeline's runtime** and keep everything it produced.

- **Removed:**
  - the orchestrator and the six phase agents
  - the `session`, `framing`, `problem-statement`, `requirements`, `design`, `implement`, `verification` and `backend` skills
  - the session hooks (`session-guard`, `session-commit-guard`, `session-branch-guard`), and the orchestrator part of `session-start`
  - the standalone `explore` (use graphify), `doc-maintainer`, `brand-designer` (use Claude Design, #53), `post-hook-validator` and `bootstrap-new-project` skills
- **Kept:** `setup`, `triage`, `task-executor`, `deploy`, `adr` and `init`. The few files they borrowed move into them: the release template and `check-release.sh` to `deploy`, `stack-defaults.md` to `init`, and `default-branch.sh` to `hooks/lib/` for the merge guard (#99).
- **History kept:** `docs/sessions/` stays where it is. The explanation and reference docs of the removed skills move to `docs/archive/`, with an index.
- **ADRs:** 001, 002, 004, 005, 006 and 008 are overridden. Their files leave the tree and the ADR index lists them as Archived, with a link to each one's last commit (`b1d47e1`). ADR-003 and ADR-007 stay, marked superseded in part: the README anchor and the deploy declaration live on, while their session parts don't.
- **Review point:** the PR. Its body is a summary of at most 40 lines, with detail in collapsible sections. The run's decision trail is committed, so you can drill down from the summary. Release records go in `docs/releases/`.

## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Retire the whole pipeline (chosen)** | One stop per feature, one path to maintain, plugin size drops from 18 skills, 7 agents and 5 hooks to 6 skills, 0 agents and 1 hook | Loses REQ→VER traceability, automatic docs fold-back and write-ownership hooks | — chosen |
| Remove the standalone skills only | Nothing in use breaks | Two parallel workflows to maintain, and a choice of path on every task | Keeps the cost the reset set out to remove |
| Keep the session and turn off its gates | Keeps the artifacts | Six agents and standards are still maintained, and the artifacts are still heavy to read | Doesn't reach the brief-first goal |

## NFR Captured

- Reviewability: a PR body is at most 40 lines, and every claim in it links to evidence (tests, decision trail, commits).
- Recoverability: every removed file is reachable at commit `b1d47e1`, and every archived ADR has a permalink in the index.
- Control: only the maintainer merges. The removed `session-branch-guard` is replaced by the merge guard (#99), which covers all runs, not just sessions.

## Consequences

**Now easier**:
- One workflow, one review point, a much smaller plugin.
- The remaining skills don't depend on a session folder.

**Now harder**:
- There's no formal REQ/VER traceability. Evidence is tests and the decision trail.
- Docs stay current only when a PR's task includes the docs change.

**New constraints**:
- Until #99 lands, nothing in Compass blocks a merge or a push to the default branch.
- Unattended runs must not start before #99 is merged.

## Revisit Conditions

- If shipped features regularly lack the requirements or evidence needed to review them, reintroduce a light requirements step inside the pstack run (a project playbook), not a gated phase.
- If docs drift measurably from the code (three or more stale-doc issues in a quarter), add a docs step to the controller's run rule (#100).
