# Established Patterns

> These are non-negotiable conventions. Before implementing anything,
> check if a pattern applies. If you need to deviate, write an ADR first.
>
> Origin: #22 · #23

<!-- Pattern format:
## Pattern Name

One sentence: what the convention is.
- Implements: ConstructA, ConstructB
- ADR: [ADR-NNN](decisions/NNN-title.md)

## Anti-Patterns

- ❌ What not to do and why
-->

## Atomic commit points

Each `decision` or `milestone` entry in a session's `log.md` gets exactly one commit, containing the entry and the artifact changes it describes. Each ticked `tasks.md` task gets one commit (code plus tick). Drafts still under discussion stay uncommitted.
- Implements: `hooks/session-commit-guard.sh` (Stop: blocks a turn from ending with an uncommitted decision/milestone heading), `skills/session/templates/rules/compass-sessions.md` (guidance, copied to `.claude/rules/`)
- ADR: [ADR-002](decisions/002-session-lifecycle.md)

## Phase-artifact ownership

Inside `docs/sessions/{id}/`, only the workflow's fixed file set may exist. Each artifact is written only by its phase's owner agent, `log.md` only by the orchestrator (main session), and an artifact is read-only once its milestone is approved (except for a main-session amendment made alongside a fresh `decision` entry). Archived sessions are read-only for everyone. A folder artifact (`define/`) is one artifact: only its fixed files, one level deep, can be written, and the whole folder has one owner and one freeze point. Each session uses one layout for a phase, the folder or its legacy root file, never both, and past sessions are never migrated.
- Implements: `hooks/session-guard.sh` (PreToolUse), `skills/session/workflows/feature.json` (`file_allowlist`, `owner_agent`, `order`, `artifact_files`, `legacy_artifact`), `skills/session/scripts/check-traceability.sh` (reads `define/requirements.md`, falls back to the root file)
- ADR: [ADR-002](decisions/002-session-lifecycle.md), [ADR-003](decisions/003-framing-and-project-anchor.md)

## Never ship an incomplete product

Before any deploy step, the release manifest (for this plugin, `.claude-plugin/marketplace.json`) is checked as it ships. Everything it lists exists and is complete (no placeholder, stub or TODO body), and every complete component is listed. Any gap blocks Deploy, and the Deploy milestone gate refuses without a clean *Completeness* section in `release.md`.
- Implements: `agents/deploy.md`, `skills/session/SKILL.md` (Deploy gate), `skills/session/templates/release.md`, `tests/session/marketplace_test.sh`

## Commit, push, then GitHub

At every milestone the session folder is committed and pushed before any `gh` call, so links in issue comments resolve. GitHub is a view of the session folder, never its source of truth. A failed `gh` call reports `SYNC_PENDING` and is replayed at the next milestone.
- Implements: `skills/session/scripts/gh-milestone.sh`, `skills/session/SKILL.md` (milestone gate)

## Hooks fail open

Plugin hooks and scripts never hard-block a repo that lacks their dependencies. With no `jq`, no git repo, or an unreadable workflow file, they allow the action and warn on stderr. They block (exit 2) only on a rule they could actually evaluate.
- Implements: `hooks/session-start.sh`, `hooks/session-guard.sh`, `hooks/session-commit-guard.sh`

## Plugin paths vs. project paths

Plugin files (scripts, templates, workflows) resolve through `${CLAUDE_PLUGIN_ROOT}`. The consuming project's files (`docs/sessions/`, `.claude/rules/`) resolve against the project's git root, never the plugin root.
- Implements: `skills/session/SKILL.md`, `hooks/session-guard.sh`, `skills/session/scripts/gh-setup.sh`

## Framing names no phase

The shared framing step never names a phase or a session type. A session type plugs in through a `framing` block in its workflow JSON, templates for its framing artifact, and a `types/{type}.md` in each standards skill it lists; adding a type changes none of the framing skill.
- Implements: `skills/framing/SKILL.md`, `skills/session/workflows/feature.json` (`framing`), `skills/problem-statement/types/`, `skills/requirements/types/`
- ADR: [ADR-003](decisions/003-framing-and-project-anchor.md)

## One project anchor, written by the orchestrator

A project's vision, mission, scope and non-goals live in exactly one place: the README's `## Project anchor` section between `<!-- compass:anchor -->` markers. Any restatement elsewhere matches it or links to it. Phase agents only draft anchor text; the orchestrator writes it, in the same commit as the decision, and the Define gate refuses the milestone until the README contains the agreed text.
- Implements: `skills/framing/reference/anchor-contract.md`, `skills/session/SKILL.md` (anchor write, gate check a3), `README.md`
- ADR: [ADR-003](decisions/003-framing-and-project-anchor.md)

## Anti-Patterns

- ❌ Letting a subagent write `log.md`: parallel agents would clash, and handoffs would go unrecorded. Agents return `log_entries` instead.
- ❌ `git commit -a` at a milestone: a new artifact is untracked until it's staged by name.
- ❌ A `commands/<name>.md` with the same name as a skill: it shadows the skill for the Skill tool and for `skills:` preload.
- ❌ Bare `skills/…` paths in skill prose: they resolve only while developing inside this repo.
