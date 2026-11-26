---
id: "011"
date: 2026-11-26
status: Accepted
deciders: [Daniel Koenawan]
affects: [session, orchestrator, task-executor, triage, explore, doc-maintainer, brand-designer]
issue: https://github.com/dkoenawan/compass-labs/issues/98
---

# ADR-011: The official pstack is the work layer, with Karpathy's rules and pstack's principles as the behaviour; Compass narrows to the controller

> Origin: #98

## Context

Compass Labs is for a busy person on a Claude **subscription** who wants a side project to keep moving with about one hour of their time a week. Mycelia is the first project it's being tried on. It is not the target: the plugin must work for any project.

On 2026-11-26 the maintainer stepped back from the backlog. Mycelia had barely started, because the effort had gone into the plugin. The causes were:

- **Gates.** The Feature session (ADR-002) stops for the maintainer at each of its six phases. With weekly availability, one feature takes over a month.
- **Output.** The phase artifacts (EARS requirements, VER tables, design folders) are written for traceability and are hard to read in an hour.
- **Bespoke tooling.** Most of the 42 open issues extend our own standards: per-layer guidance, notation checklists and new session types. Proven tools already cover much of this.

The maintainer set these constraints:
- Usage within the subscription is the budget.
- Claude pushes to feature branches only, and the maintainer merges.
- Output is a short visual brief, with detail in an appendix.
- Adopt proven third-party tools before building our own.

## Decision

We will split the system into four layers:

| Layer | Source | Owns |
|---|---|---|
| Behaviour | Karpathy's four rules ([forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)) and pstack's principles | How Claude reasons and edits |
| Work | **Official pstack** ([cursor/plugins](https://github.com/cursor/plugins), `pstack@cursor-plugins`, by Lauren Tan, MIT), installed unchanged | One entry point (`poteto-mode`), playbooks, verification, PR upkeep |
| Controller | Compass | Scheduling within usage limits, picking the next task, the weekly brief, subscription-safe settings, guardrails |
| Vision and merge | The maintainer | Direction, priorities, merging |

**Making pstack "lite" happens through configuration, not a fork:**
- Per-role models: Claude only, at `high` reasoning or below.
- A Compass rule listing which skills to use.
- A fork happens only if a trial shows configuration isn't enough.

**Karpathy rule 1 ("if unclear, stop and ask") becomes pstack's `principle-never-block-on-the-human` in unattended runs.** Claude assumes, records the assumption, carries on and queues the question for the weekly brief. Irreversible actions still need confirmation.

## Options Considered

**Which pstack**

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Official `cursor/plugins` (chosen)** | Written by the author. The Claude Code copy is generated and CI keeps it in sync. No hooks. The repo has about 19.6k stars | Skills keep Cursor names, which an adapter doc maps as Claude reads them | — chosen |
| Community port `michael-denyer/pstack-claude` | Names are pre-translated. Adds a routing hook | One main maintainer, covers 12 tools, carries its own changes, adds a session-start hook | Too far from the author's version for us to rely on |
| Copy a subset into Compass | Smallest context, exactly the skills we want | We'd have to keep it in sync with upstream, which is the bespoke burden we're dropping | Premature: revisit if the trial shows it's needed |

**Where the work layer comes from**

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Adopt pstack (chosen)** | Proven, verification-first, playbooks for long and unattended work | Its defaults assume a large budget and models from several vendors | — chosen; settings fix the defaults |
| gstack (garrytan/gstack) | Role-based sprint, browser QA | Needs Bun and a Codex CLI subscription for its outside review. Its own published test found no gain in fix rate | Weaker fit and its own evidence is against it |
| Keep extending the Compass Feature session | Already built | Gates every phase, heavy artifacts, a growing backlog | This is the problem we're solving |

## NFR Captured

- Budget: no pstack role runs Fable (it needs usage credits) or a model from another vendor (it needs another account). No role runs above `high` reasoning by default. `tests/pstack/models_template_test.sh` enforces this.
- Control: no unattended run merges or pushes to the default branch. pstack's autonomy pauses before irreversible actions. A Compass guard that blocks merges is a follow-up.
- Portability: nothing in the plugin is specific to one project. Project needs live in that repo's `.agents/playbooks/` and config.

## Consequences

**Now easier**:
- Most of the build, verify and PR work comes from a maintained upstream.
- Compass's own scope shrinks to the controller.

**Now harder**:
- We depend on an upstream whose skills keep Cursor names.
- Upstream updates have to be checked before we turn them on. Auto-update stays off, the default for third-party marketplaces.

**New constraints**:
- Every Compass install writes the subscription-safe model roles.
- The gated phases (ADR-002) and the layer-guidance programme stop growing. Retiring them is a follow-up.

## Revisit Conditions

- If a trial shows pstack's Cursor-name mapping regularly fails in Claude Code, or uses more than half a week's usage on one ordinary task, re-evaluate: switch to the community port, or copy a subset.
- If upstream adds a hook or a script that writes outside the project or `~/.claude/rules/`, re-audit before updating.
