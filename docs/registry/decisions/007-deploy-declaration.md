---
id: "007"
date: 2026-11-03
status: Accepted
deciders: [Daniel Koenawan]
affects: [deploy, session, init, DeployStandard, DeclarationCheck]
issue: https://github.com/dkoenawan/compass-labs/issues/30
---

# ADR-007: A repo declares deploy in `.claude/deploy.json`, offered at project initiation and at Deploy for a part it doesn't cover

> Origin: #30

## Context

What "deploy" means depends on the repo, and the Deploy phase had no way to be told. It worked out each release from scratch, details drifted between releases, and a consuming repo's Deploy could only stop or guess. Deploy also had no notion of deployment setup (L1) as distinct from a session release (L2), so an architecture change could ship without the setup that matches it.

Constraints: the declaration has to work in any repository and stack, and stay optional; a missing item has to be found mechanically, not by reading prose; Deploy isn't conversational; the plugin is not a deploy runner, so the commands are always the repo's own.

## Decision

We will have each repo state what deploy means for it in **one JSON file, `.claude/deploy.json`**, whose shape the Deploy standard (`skills/deploy/`) fixes: L1 setup per deployable part, L2 release steps in order, each step's kind (routine or production-affecting; a merge is always production-affecting), a confirmation check, a rollback, and whether a release runs in the feature session or its own. `{"deployment": "none"}` declares nothing to deploy. No file means no declaration, and Deploy stops before running anything and says how to declare one. `check-declaration.sh` validates the file and names anything missing.

The declaration is **offered at two points**, both through one procedure in the Deploy standard:

1. **At project initiation**, in `init` (greenfield and brownfield, before its commit) and in the `session` skill's one-time setup, skipped if a declaration exists. Answers: later (nothing written), nothing to deploy, or declare now. Initiation never runs a setup step.
2. **At Deploy**, when the frozen design adds or changes a deployable part the declaration doesn't cover. Deploy offers to add that part's entry, shown in full, before any deploy step; a no stops Deploy naming the part, with the file unchanged. This is the only question Deploy asks before its gate.

## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **JSON file at `.claude/deploy.json`, shape set by the standard (chosen)** | Structured, so a missing item is named mechanically; stack-independent; `jq` is already the plugin's parser; optional; sits beside `.claude/rules/` | A new format to document; no comments, so reasons go in `note` fields | — chosen |
| A `## Deploy` section in `CLAUDE.md` | No new file | Free prose, so a missing item can't be found mechanically; loaded into every conversation | Not checkable |
| A repo skill (`.claude/skills/deploy/SKILL.md`) | Rich, Claude-native | Heavier; structure unchecked; loads outside Deploy | Not checkable |
| A Taskfile target | Executable | Ties the declaration to Task; can't state kinds, rollback or release mode | Not stack-independent, not complete |

For when it's offered: only at one-time setup misses `init`'s moment; only in `init` misses every repo that never runs it; offering nothing leaves Deploy's first run as the only prompt. Both initiation points plus the Deploy-time offer cover every repo and keep the declaration in step as the architecture grows. A recipe field for "new parts" was dropped in favour of the offer, so "not covered" has one meaning.

## NFR Captured

- Portable: no stack in the declaration; the plugin supplies no deploy command.
- Mechanical: validity, the missing item and the steps that may run are computed by `check-declaration.sh`, which fails open (exit 4) without `jq`.
- Quiet by default: a repo whose declaration covers every part gets no question before the gate.

## Consequences

**Now easier**: Releasing the same way every time from steps declared once; running Deploy in a consuming repo with a real deployment; seeing at the gate where every step came from.
**Now harder**: A repo must declare something, even `none`, before Deploy will run; a new deployable part needs the user's yes before it ships.
**New constraints**: L1 setup steps must be safe to run again, because a covered part's setup runs whenever its row in the design changes. A declaration change made at Deploy is committed with the `decision` entry that names the part.

## Revisit Conditions

If declarations need to vary per environment or per branch in a way one file can't express, or if the agent's reading of "deployable part" from the delta list proves unreliable enough that Design should mark deployable parts explicitly, re-evaluate.
