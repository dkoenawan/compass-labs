---
id: "002"
date: 2026-09-24
status: Accepted
deciders: [Daniel Koenawan]
affects: [session, requirements, verification, doc-maintainer, plan, task-executor]
issue: https://github.com/dkoenawan/compass-labs/issues/22
---

# ADR-002: Session lifecycle: a main-session orchestrator, one artifact per phase, hook-enforced

> Origin: #22

## Context

The plugin's skills are capabilities (plan, explore, write an ADR). Moving a piece of work through its phases (sequencing, tracking progress, deciding when it's done) is a separate job, and nothing owned it. Session documents also had no lifecycle: which files exist at which phase, who writes them, when they're frozen, and how they become as-built docs. Left to themselves, agents create a new Markdown file per step, and prompt instructions alone don't stop that.

Constraints: state has to survive a conversation ending (no reliance on memory); the session folder has to stay small and fixed; as-built docs must carry no session narrative; everything has to ship through the plugin structure; and subagents can't ask the user questions (`AskUserQuestion` isn't available to them), though they can nest.

## Decision

We will run every session through an **orchestrator in the main session** (the `session` skill, reachable as the repo-default agent, `claude --agent compass-labs:orchestrator`, or `/compass-labs:session`). It hands each phase to **one phase agent**, and each phase agent owns **exactly one artifact** in `docs/sessions/{date}-{slug}/`. The orchestrator alone writes `log.md`. Workflows are data (`skills/session/workflows/{type}.json`). The folder shape, ownership, freezing and commit points are **enforced by plugin hooks**, not only by instructions. GitHub mirrors one milestone per phase and is never the source of truth. At Close, the session is folded into as-built docs and the folder is moved to `docs/sessions/archive/`.

Feature is the only workflow (Define → Design → Implement → Test → Deploy → Close). Requirements default to EARS with Given/When/Then acceptance criteria. Artifacts link by ID (`REQ` → `DES` → task → `VER`), and the Test milestone requires a passing `VER-*` for every `REQ-*`.

## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Main-session orchestrator + phase subagents + hooks (chosen)** | Only the main session can ask the user questions; phase agents stay single-purpose; hooks enforce the file set | Needs a SessionStart hook for the session list, because plugin agents can't set an initial prompt | — chosen |
| `plan` skill drives the whole session | No new components | One skill doing agent work; no Implement/Test/Deploy/Close; mixes requirements and design | Violates single responsibility; doesn't close the loop |
| Claude Code workflow as the orchestrator | Built-in fan-out | Can't take user input mid-run; resumable only within the same session | Can't be conversational or resumable across a pause |
| Prompt-only rules for files and commits | Simple | Agents drift, and file sprawl comes back | Enforcement has to be mechanical |

## NFR Captured

- Resumable: a fresh conversation restores phase, next step, open items and key decisions from `log.md` alone.
- Bounded: a session folder never holds more than the workflow's allowlist plus non-Markdown `assets/`.
- Offline-tolerant: a failed `gh` call never stops a session; it syncs at the next milestone.
- Portable: every hook and script fails open when `jq` or git is missing.

## Consequences

**Now easier**: Picking a session back up after a break; seeing which phase owns what; tracing any requirement to its verification; keeping as-built docs free of process narrative.
**Now harder**: Changing a frozen artifact (it needs a logged decision first); adding a new file to a session (it needs an allowlist change in the workflow file).
**New constraints**: Only the orchestrator writes `log.md`. Every `decision`/`milestone` log entry is one commit. At each milestone, commit and push come before any `gh` call. See [patterns](../patterns.md). This supersedes the `doc-maintainer`-driven fold-back in [ADR-001](001-diataxis-docs-restructure.md) for sessions run through the lifecycle: the Close phase folds back, and the orchestrator archives.

## Revisit Conditions

If Bugfix or Research sessions (#24, #25) can't be expressed as a new workflow file without changing the orchestrator or the guard hook, or if one milestone per phase proves too coarse for GitHub tracking, re-evaluate this decision.
