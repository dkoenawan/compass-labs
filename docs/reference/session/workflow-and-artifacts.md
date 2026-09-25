# Session workflow and artifacts

> → Concepts: [Session overview](../../explanation/session/overview.md) · → [Hooks and scripts](hooks-and-scripts.md)
> Origin: #22

## Feature workflow (`skills/session/workflows/feature.json`)

| Order | `phase` | `owner_agent` | `artifact` | `milestone` (display label) | `gh_label` | Conversational |
|---|---|---|---|---|---|---|
| 1 | `define` | `compass-labs:define` | `requirements.md` | Define complete | `phase:define` | yes |
| 2 | `design` | `compass-labs:design` | `design.md` | Design complete | `phase:design` | yes |
| 3 | `implement` | `compass-labs:implement` | `tasks.md` | Implement complete | `phase:implement` | no |
| 4 | `test` | `compass-labs:test` | `verification.md` | Test complete | `phase:test` | no |
| 5 | `deploy` | `compass-labs:deploy` | `release.md` | Deploy complete | `phase:deploy` | no |
| 6 | `close` | `compass-labs:close` | `null` | Closed | `phase:close` | no |

Top-level keys: `workflow`, `session_level.file_allowlist` (the five artifacts, `log.md`, `assets/`), `session_level.log_file`, `session_level.log_owner` (`orchestrator`), `github.type_label` (`type:feature`) and `github.type_color`. A new session type is a new `workflows/{type}.json` with the same shape. The guard hook picks the file from `log.md`'s `type`.

## Artifacts

| File | Written by | Standard | Frozen when |
|---|---|---|---|
| `requirements.md` | `compass-labs:define` | `requirements` skill: `REQ-nnn` in EARS syntax, one Given/When/Then acceptance criterion each, ISO/IEC/IEEE 29148 quality checks | `milestone` ≥ `define` |
| `design.md` | `compass-labs:design` | `DES-*` items, each naming the `REQ-*` it covers; ADRs in `docs/registry/decisions/` | `milestone` ≥ `design` |
| `tasks.md` | `compass-labs:implement` | `task-executor` tasks format; each task names the `DES-*` it implements; a Deviations section | `milestone` ≥ `implement` |
| `verification.md` | `compass-labs:test` | `verification` skill: `\| ID \| Covers REQ \| Method \| Result \| Evidence \|`, in that exact column order | `milestone` ≥ `test` |
| `release.md` | `compass-labs:deploy` | Version/target, what changed (by `REQ-*`), Completeness, deploy steps, confirmation, rollback | `milestone` ≥ `deploy` |
| `log.md` | orchestrator (main session) only | Log format below | Never frozen; read-only once archived |
| `assets/` | any | Non-Markdown files only | — |

IDs are sequential and never reused. Dropped items are struck through, not deleted. Templates for every file are in `skills/session/templates/`. An artifact can later grow into a folder of native artifacts (e.g. a test report) next to its Markdown file, with the Markdown file staying as the entry point that links to them.

## `log.md` format

Frontmatter:

| Key | Values |
|---|---|
| `session` | `{date}-{slug}` |
| `type` | `feature` |
| `issue` | GitHub issue number |
| `phase` | Current phase key |
| `status` | `active` · `paused` · `archived` |
| `milestone` | **Phase key** of the last approved milestone: `none` · `define` · `design` · `implement` · `test` · `deploy` · `close`. The guard hook computes freezing from this key. |
| `active_agent` | Agent currently working, or `main` |
| `next_step` | One line |

Body: `## Open items`, `## Key decisions` (`- **{date}**: …`, newest first; milestones prefixed with ✅), then `## Phase: {Name}` sections of append-only entries:

```
### {date} — {actor} — {handoff|decision|attempt|milestone|note}: {title}
```

Every `decision` and `milestone` entry is also mirrored into Key decisions in the same edit.

## Phase agent contract

Every phase agent follows [`skills/session/reference/phase-agent-contract.md`](../../../skills/session/reference/phase-agent-contract.md). The input is the session path, the phase, the task and any relayed answers. The output is `status` (`done` · `needs_input` · `blocked`), `questions` (with `needs_input` only), `log_entries` (never `milestone`) and `files_changed`. Close follows [`close-foldback.md`](../../../skills/session/reference/close-foldback.md).

## Commit points

The rule template `skills/session/templates/rules/compass-sessions.md` is copied to a consuming repo's `.claude/rules/compass-sessions.md` (scoped to `docs/sessions/**`) on first use. It is never overwritten. See [Atomic commit points](../../registry/patterns.md#atomic-commit-points).
