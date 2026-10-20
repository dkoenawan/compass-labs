# Design: Session opens on a feature branch

> Phase: Design | Started: 2026-10-19 | Status: Draft
> Requirements: [`define/index.md`](../define/index.md) · Session history: [`log.md`](../log.md)

## Contents

This design has no in-depth file: its primary kind has no in-depth path yet (see [Classification](#classification)), and no layer standard applies. Everything is in this file.

## Prior knowledge

- **Read:**
  - `docs/explanation/session/overview.md` (New session flow, Resume flow, milestone gate, "mechanical enforcement over prompt instructions")
  - `docs/reference/session/hooks-and-scripts.md` (hook table, exit codes, fail-open rule, test harness)
  - `docs/registry/patterns.md` ("Commit, push, then GitHub", "Hooks fail open", "Plugin paths vs. project paths", "Atomic commit points")
  - `docs/registry/decisions/002-session-lifecycle.md` (ADR-002: enforcement has to be mechanical)
  - Code: `skills/session/SKILL.md`, `agents/orchestrator.md`, `skills/session/workflows/feature.json`, `skills/session/templates/log.md`, `hooks/hooks.json`, `hooks/session-guard.sh`, `hooks/session-commit-guard.sh`, `hooks/session-start.sh`, `hooks/lib/session-log.sh`, the `tests/` layout
  - This session: `define/` (all four files) and `log.md`
- **Not read:** any past session folder, including `docs/sessions/archive/`. The #22 design's D5 ("branch created at Implement") is known here only as Define cites it; this design supersedes it.

## Classification

- **Primary kind:** Plugin/tooling: every live requirement changes the plugin's own orchestrator skill, hooks or scripts (REQ-001 to REQ-004, REQ-007, REQ-008, REQ-010 change the `session` skill's flows; REQ-005 and REQ-006 need a hook and a default-branch lookup; REQ-009 is an orchestrator rule).
- **In-depth path:** none yet: dkoenawan/compass-labs#51, see Open questions.

## Scope checklist

| Area | In scope? | Reason |
|---|---|---|
| Plugin/tooling | in | A new hook (REQ-005), a default-branch lookup (REQ-006), and changes to the `session` skill's New session flow, Resume flow and main loop (REQ-001 to REQ-004, REQ-007, REQ-008, REQ-010) |
| Process/workflow | in | The session lifecycle's git workflow changes: the branch exists from the first commit, the PR opens at the first push, and merging stays the user's call (REQ-001, REQ-008, REQ-009). This supersedes the #22 design's D5 timing |
| GitHub integration (`gh`) | in | A draft pull request is opened through `gh` after the user agrees (REQ-008) |
| Tests (`tests/run.sh` harness) | in | The new hook and lookup get harness tests, like every existing hook |
| Frontend | out | No user interface |
| Backend | out | No service or API |
| Database | out | No stored data beyond the session folder |
| Infrastructure | out | No hosting or deployment; branch protection, CI and merge settings are a non-goal |
| Visual UI design | out | No screens |
| As-built docs (`docs/explanation/`, `docs/reference/`) | out | Close folds the change in at the end of the session, including retiring #22's D5 timing in `docs/explanation/session/overview.md` |

## Context view

*Pending: drawn once the classification and scope are confirmed.*

## Delta list

*Pending.*

## Components (DES)

*Pending.*

## Decisions

*Pending.*

## Principles check

*Pending.*

## Risks

*Pending.*

## Open questions

- Plugin/tooling has no in-depth design path yet: dkoenawan/compass-labs#51. Process/workflow has none either: dkoenawan/compass-labs#49. This design covers both in the all-kinds sections.
