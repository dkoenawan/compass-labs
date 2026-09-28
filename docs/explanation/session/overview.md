---
domain: session
last_updated: 2026-09-28
source_path: skills/session
---

# Session (L3)

> → [System overview](../solution-design.md) | → Reference: [hooks and scripts](../../reference/session/hooks-and-scripts.md) · [workflow and artifacts](../../reference/session/workflow-and-artifacts.md) | → Framing: [overview](../framing/overview.md) | → Usage: [README, "Using Sessions in a Repo"](../../../README.md#using-sessions-in-a-repo)
> Origin: #22 · #23

## What Is a Session?

A session is one tracked unit of work that moves through a fixed workflow, from understanding the problem to shipping it and folding it back into these docs. The primary object is the **session folder**, `docs/sessions/{date}-{slug}/`. It is paired with exactly one GitHub issue, holds one artifact per phase plus a `log.md` of state and history, and is the only place session state lives. Feature is the only session type today: **Define → Design → Implement → Test → Deploy → Close**.

The `session` skill is the orchestrator. It runs in the main conversation, hands each phase to a dedicated phase agent, and gates every phase transition on the user's approval. Plugin hooks enforce the folder's shape, who can write what, and when commits happen, so the lifecycle holds even when a prompt is ignored.

## How It Works

A session starts through one of three entry points (repo-default agent, `claude --agent compass-labs:orchestrator`, or `/compass-labs:session`; see the README). All three load the same `session` skill. When Claude starts as the orchestrator agent, a `SessionStart` hook lists active and paused sessions so the first reply can offer "resume or start new". The first time the skill is used in a repo, it creates the `phase:*` and `type:*` GitHub labels and copies a commit-point rule into `.claude/rules/compass-sessions.md` if that file isn't already there.

A new session gets an issue (existing or newly created) and a folder. `log.md` is created first, then a thin `define/index.md`. The opening commit is pushed, and only then is GitHub updated (label `phase:define`, an opening comment). This order (commit, push, then `gh`) applies at every milestone so that comment links always resolve.

**Define** runs the shared [framing](../framing/overview.md) step before anything else: it proposes a depth tier (full, short or skip) for the user to confirm, runs that tier's checks, and checks the work against the project anchor in the README. It then writes the problem statement and requirements to the tier's depth. Its output is the `define/` folder: a main doc, `define/index.md`, linking to sub-docs that exist only when the tier needs them. When framing agrees an anchor change with the user, Define only records the agreed text; the orchestrator writes it into the README, and the Define gate refuses the milestone until the README contains it.

Each phase runs the same loop. The orchestrator logs a `handoff` entry, then starts `compass-labs:{phase}` with the session path, the phase and a task. The phase agent writes only its own artifact and returns `done`, `needs_input` or `blocked`, plus log entries. For `needs_input`, the orchestrator asks the user, since subagents can't, and relays the answers to the same agent with `SendMessage`. The orchestrator is the only writer of `log.md`. It appends the returned entries, mirrors every decision into the log's **Key decisions** list, and downgrades any `milestone` entry an agent returns to a `note`, because milestones belong to the user.

At the **milestone gate** the user approves, adjusts or rethinks the phase's artifact. Three gates check more than approval. Define can't complete while an agreed anchor change is missing from the README. Test can't complete unless every `REQ-*` has a passing `VER-*` (`check-traceability.sh`). Deploy can't complete unless `release.md`'s *Completeness* section shows that the release manifest lists only complete components and leaves none out. On approval, the orchestrator sets `milestone` to the finished phase's key and `phase` to the next one. That freezes the artifact. It then commits the artifact and log explicitly, pushes, and runs `gh-milestone.sh` to move the issue's label and post the milestone comment. If GitHub is unreachable, the script reports `SYNC_PENDING` and exits cleanly. The session continues locally and the next gate replays the sync.

A session can pause at any point (`status: paused`, `next_step` set, committed). Resuming, in any later conversation, reads only `log.md`'s frontmatter, Open items, Key decisions and the latest entry. Nothing depends on conversation memory.

**Close** has no artifact. The Close agent folds whatever is still true once the feature has shipped into the as-built docs: needs, outcomes, context diagrams and still-true assumptions become explanation under `docs/explanation/<domain>/`, and live requirements and NFR measures become current-fact reference under `docs/reference/<domain>/`, plus any registry changes. Framing records, evidence, struck and deferred requirements, and anything about how the work got there stay in the archive. As-built docs never cite a session's `REQ-*`, `DES-*` or `VER-*` IDs; each doc Close touches gets one `Origin: #{issue}` line instead. The orchestrator then logs the final milestone and sets `status: archived` in the same commit as the fold-back. After that, `archive-session.sh` does a `git mv` of the folder to `docs/sessions/archive/{slug}/` as a separate commit. The orchestrator pushes, syncs GitHub and closes the issue. From then on the archived folder is read-only.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| Session folder | `docs/sessions/{date}-{slug}/`. Holds a fixed file set: five phase artifacts (one of them the `define/` folder), `log.md`, and an optional non-Markdown `assets/`. Nothing else can be created in it. |
| `log.md` | Session state (YAML frontmatter: `phase`, `status`, `milestone`, `active_agent`, `next_step`, `issue`), then Open items, Key decisions (newest first), then append-only entries grouped by `## Phase:`. Written only by the orchestrator. |
| Phase artifact | One per phase (`define/`, `design.md`, `tasks.md`, `verification.md`, `release.md`), each owned by one phase agent. It is frozen once its milestone is approved. |
| Folder artifact | A phase artifact that is a folder with a fixed file set, owned and frozen as a unit. `define/` holds `index.md` (the main doc) plus `requirements.md`, `framing.md`, `problem.md`, `quality.md` and `diagrams.md` by depth tier. Sessions from before it keep a root `requirements.md` instead; each session uses one layout, and past sessions are never migrated. |
| Workflow definition | `skills/session/workflows/feature.json`. Lists phases in order, with each phase's owner agent, artifact (and, for a folder, its file set and legacy root path), milestone label and GitHub label, plus the `framing` block that plugs the type into framing. The orchestrator and the guard hook both read it. |
| Phase agent | `agents/{define,design,implement,test,deploy,close}.md`. A thin wrapper around the shared phase agent contract. Define and Design are conversational (through the orchestrator). The others execute. |
| Log entry | `### {date} — {actor} — {event type}: {title}`, where the type is one of `handoff`, `decision`, `attempt`, `milestone`, `note`. |
| ID chain | `REQ-*` → `DES-*` → task → `VER-*` → release. Artifacts reference upstream IDs instead of repeating their content. The Test gate checks the REQ → VER link mechanically. Inside `define/`, `NEED-nn` and `OUT-nn` add an upward trace (each REQ names what it serves) that never leaves the folder. |
| Milestone | A user-approved phase transition. It freezes the phase's artifact, gets one commit, and is mirrored to the issue as one `phase:*` label and one comment. |

## Code Map — Which Code Touches This

- **Orchestration logic**: `skills/session/SKILL.md` covers mode dispatch (default / `new` / `resume` / `status`), one-time setup, the main loop, the milestone gate and the Close ordering. `skills/session/reference/phase-agent-contract.md` is the shared agent contract. `skills/session/reference/close-foldback.md` is the Close procedure.
- **Data shape**: `skills/session/workflows/feature.json` defines the workflow. `skills/session/templates/*.md` holds thin starting versions of every artifact and the log, with the six Define templates in `templates/define/`. `skills/session/templates/rules/compass-sessions.md` is the commit-point rule copied into consuming repos.
- **Interface**: `agents/orchestrator.md` (main-session agent) and the `/compass-labs:session` skill invocation. Phase agents live in `agents/*.md`. The Define agent preloads `framing`, `problem-statement` and `requirements` (see [framing](../framing/overview.md)); the Test agent preloads `skills/verification/SKILL.md` (VER table column order).
- **Enforcement**: `hooks/hooks.json` wires `hooks/session-start.sh` (SessionStart), `hooks/session-guard.sh` (PreToolUse) and `hooks/session-commit-guard.sh` (Stop). `hooks/lib/session-log.sh` holds the shared "uncommitted log heading" check.
- **GitHub and lifecycle scripts**: `skills/session/scripts/gh-setup.sh`, `gh-milestone.sh`, `check-traceability.sh`, `archive-session.sh`.
- **Tests**: `tests/run.sh` (bash + jq) runs `tests/hooks/*_test.sh` and `tests/session/*_test.sh`. The tests are repo-only and don't ship as runtime surface.

## Internal Architecture

**Workflow as data.** The phase order, ownership and labels live in `feature.json`, not in the skill's prose. Adding a session type means adding a workflow file, not changing the orchestrator or the hooks.

**Only the main session talks to the user.** Subagents can't use `AskUserQuestion`, so the orchestrator runs in the main session and relays questions. A phase agent never holds state between invocations. It rereads the session folder every time.

**Mechanical enforcement over prompt instructions.** The guard hook works out ownership from the hook input's `agent_type` and freezing from `log.md`'s `milestone` key compared with each phase's `order`. A folder artifact resolves by its folder prefix, so every file in `define/` has the same owner and freeze point, and only its fixed files, one level deep, can be written. A frozen artifact can be amended only by the main session, and only alongside a fresh, uncommitted `decision` entry in `log.md`. The Stop guard makes Claude commit each `decision` or `milestone` entry with the changes it describes. See [patterns](../../registry/patterns.md).

**Plugin paths vs. repo paths.** Scripts and templates resolve through `${CLAUDE_PLUGIN_ROOT}`. `docs/sessions/` always resolves against the consuming project's git root, never the plugin root, because the plugin ships its own `docs/sessions/`.

## Dependencies

- **Internal**: `doc-maintainer` (preloaded by the Close agent), `framing`, `problem-statement` and `requirements` (Define), `verification` (Test), and the `task-executor` tasks format (Implement).
- **External**: `git`; `gh`, authenticated, for GitHub sync (optional: sessions keep going offline); `jq` for every hook and script (all fail open without it); Claude Code plugin hooks and subagents.

## Gotchas

- **`skills:` preload doesn't apply to a main-session agent.** When the orchestrator runs as `--agent` or as the repo default, the `session` skill isn't injected, so `agents/orchestrator.md` tells it to read `SKILL.md` itself. Preload does work for phase agents started as subagents.
- **Don't add `commands/session.md`.** A command with the same name shadows the `session` skill, both for the Skill tool and for the orchestrator's preload. The skill is the slash command.
- **The command prefix is `/compass-labs:session`**, not `/compass:session`, because the plugin is named `compass-labs`. The rename is tracked in #34.
- **The VER table's column order is load-bearing.** `check-traceability.sh` parses it by position, and any Result containing "pass" counts as passing.
- **Stage milestone artifacts by name.** A new artifact is untracked until it's added, and `git commit -a` would freeze an artifact that was never pushed.
- **The Stop guard allows the stop after 2 consecutive blocks** in one turn, with a warning. The entry is still uncommitted and must be committed next turn.
- **A new session can't create a root `requirements.md`, and an old one can't create `define/`.** The guard enforces one layout per session. Tools read `define/requirements.md` first and fall back to the root file for sessions from before the folder.
- **Close's mapping lives in `close-foldback.md`.** `doc-maintainer`'s own session fold-back step still expects the older `plan`-format `overview.md` (#41), so for lifecycle sessions the Close procedure's mapping is what applies.
- **Order matters at Close.** Set `status: archived` and commit it before the `git mv`. Once the folder is under `archive/`, the guard blocks every write there, the orchestrator's included.
- **Hooks in `hooks.json` use an unquoted `$CLAUDE_PLUGIN_ROOT`**, so an install path containing a space breaks them. This is tracked in #35.
- **Testing needs `claude --plugin-dir .`.** A conversation running the installed plugin from the cache doesn't pick up the repo's working-tree hooks.

## Changelog

- 2026-09-25: Initial documentation.
- 2026-09-28: Define's output is the `define/` folder; framing, the anchor write and the Define gate check; the Close fold-back mapping.
