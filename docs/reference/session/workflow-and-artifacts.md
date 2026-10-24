# Session workflow and artifacts

> → Concepts: [Session overview](../../explanation/session/overview.md) · → [Hooks and scripts](hooks-and-scripts.md) · → [Framing reference](../framing/tiers-and-anchor.md) · → [Design standard](../design/standard.md) · → [Implement standard](../implement/standard.md)
> Origin: #22 · #23 · #27 · #28 · #37

## Feature workflow (`skills/session/workflows/feature.json`)

| Order | `phase` | `owner_agent` | `artifact` | `milestone` (display label) | `gh_label` | Conversational |
|---|---|---|---|---|---|---|
| 1 | `define` | `compass-labs:define` | `define/` (folder) | Define complete | `phase:define` | yes |
| 2 | `design` | `compass-labs:design` | `design/` (folder) | Design complete | `phase:design` | yes |
| 3 | `implement` | `compass-labs:implement` | `implement/` (folder) | Implement complete | `phase:implement` | no |
| 4 | `test` | `compass-labs:test` | `verification.md` | Test complete | `phase:test` | no |
| 5 | `deploy` | `compass-labs:deploy` | `release.md` | Deploy complete | `phase:deploy` | no |
| 6 | `close` | `compass-labs:close` | `null` | Closed | `phase:close` | no |

Top-level keys: `workflow`, `framing` (what this session type plugs into the shared framing step; see the [framing reference](../framing/tiers-and-anchor.md#the-framing-block)), `session_level.file_allowlist` (`define/`, `design/` and `implement/`, their legacy root files `requirements.md`, `design.md` and `tasks.md`, the other two artifacts, `log.md`, `assets/`), `session_level.log_file`, `session_level.log_owner` (`orchestrator`), `github.type_label` (`type:feature`) and `github.type_color`. A new session type is a new `workflows/{type}.json` with the same shape. The guard hook picks the file from `log.md`'s `type`.

Phase keys for folder artifacts:

| Key | Meaning |
|---|---|
| `artifact` ending in `/` | A **folder artifact**: one artifact with one owner, frozen as a unit. Feature's Define phase declares `define/`, its Design phase `design/`, and its Implement phase `implement/`. |
| `artifact_files` | The folder's fixed file set, one level deep. For `define/`: `index.md`, `requirements.md`, `framing.md`, `problem.md`, `quality.md`, `diagrams.md`. For `design/`: `index.md`, `solution.md`, `frontend.md`, `backend.md`, `database.md`, `ui-handoff.md`. For `implement/`: `tasks.md`, `as-built.md`. |
| `legacy_artifact` | The root path sessions from before the folder use for the same phase (`requirements.md`, `design.md`, `tasks.md`). It stays in the allowlist because those sessions are never migrated. |

## Artifacts

| File | Written by | Standard | Frozen when |
|---|---|---|---|
| `define/` | `compass-labs:define` | `framing`, `problem-statement` and `requirements` skills, by depth tier (see [The `define/` folder](#the-define-folder)) | `milestone` ≥ `define` (the whole folder at once) |
| `requirements.md` (root, past sessions only) | `compass-labs:define` | `requirements` skill. Only a session that already has this file may write it, and such a session can't create `define/`. | `milestone` ≥ `define` |
| `design/` | `compass-labs:design` | The `design` skill (see [The `design/` folder](#the-design-folder)) | `milestone` ≥ `design` (the whole folder at once) |
| `design.md` (root, past sessions only) | `compass-labs:design` | The older template: `DES-*` items, each naming the `REQ-*` it covers. Only a session that already has this file may write it, and such a session can't create `design/`. | `milestone` ≥ `design` |
| `implement/` | `compass-labs:implement` | The `implement` skill (see [The `implement/` folder](#the-implement-folder)) | `milestone` ≥ `implement` (the whole folder at once) |
| `tasks.md` (root, past sessions only) | `compass-labs:implement` | `task-executor` tasks format; each task names the `DES-*` it implements; a "Deviations from design" section. Only a session that already has this file may write it, and such a session can't create `implement/`. | `milestone` ≥ `implement` |
| `verification.md` | `compass-labs:test` | `verification` skill: `\| ID \| Covers REQ \| Method \| Result \| Evidence \|`, in that exact column order. Method is one of the Test-owned methods `integration`, `ui`, `playwright` or `inspection`, and every live `REQ-*` has at least one such row. Implement's unit and component tests appear only in Evidence, prefixed `Supporting:` | `milestone` ≥ `test` |
| `release.md` | `compass-labs:deploy` | Version/target, what changed (by `REQ-*`), Completeness, deploy steps, confirmation, rollback | `milestone` ≥ `deploy` |
| `log.md` | orchestrator (main session) only | Log format below | Never frozen; read-only once archived |
| `assets/` | any | Non-Markdown files only | — |

IDs are sequential and never reused. Dropped items are struck through, not deleted. Templates for every file are in `skills/session/templates/` (the Define templates in `templates/define/`, the Design templates in `templates/design/`, the Implement templates in `templates/implement/`; layer design templates come from each layer's home, `skills/{layer}/`). An artifact that needs more than one file is a folder artifact: the folder is the artifact, its main doc (`index.md`) sits inside it and links to the other files, and its file set is fixed in the workflow. `define/`, `design/` and `implement/` are the folder artifacts today; the other phases' artifacts are flat files.

## The `define/` folder

Define's output is one main doc linking to focused sub-docs. A sub-doc exists only when the confirmed depth tier needs it, or when the user agrees to include a higher-tier element.

| File | Holds | Tiers |
|---|---|---|
| `index.md` | The **main doc**: title and status, a contents list linking each sub-doc that exists, the framing summary (tier and reason, verdict), the problem summary, Scope, Non-goals, Constraints and Open questions | all |
| `requirements.md` | The EARS preface, the glossary, the `REQ-*` table (`ID \| Requirement \| Priority \| Serves \| Acceptance criterion`, `ID` always first) and a `## Deferred` table | all |
| `framing.md` | The framing checks: solution-first (XY) outcome and candidate solutions, symptom and cause, anchor state, verdict and citations, the anchor-update block, and registry/ADR overlaps | short, full |
| `problem.md` | Need and stakeholders (`NEED-nn`), tagged evidence and success outcomes (`OUT-nn`); at full tier also context, impact and why now, and appetite and no-gos | short, full |
| `quality.md` | ISO/IEC 25010:2023 coverage, NFR measures (Tolerable and Goal), assumptions and dependencies | full |
| `diagrams.md` | The four required Mermaid diagrams (impact map, context, traceability, as-is/to-be when a process changes) | full, or at any tier when an optional diagram is chosen |

```text
skip                     short                    full
define/                  define/                  define/
├── index.md             ├── index.md             ├── index.md
└── requirements.md      ├── requirements.md      ├── requirements.md
                         ├── framing.md           ├── framing.md
                         └── problem.md           ├── problem.md
                                                  ├── quality.md
                                                  └── diagrams.md
```

- **`NEED-nn` and `OUT-nn`** are local to the `define/` folder. They never leave it, so the downstream ID chain (`REQ-*` → `DES-*` → task → `VER-*`) is unchanged.
- **The Deferred table** holds requirements moved to later work: `| Follow-up | Was | Requirement | Reason |`, with the follow-up issue link required and first. A requirement that will never be done is struck through in the `REQ-*` table instead. Neither form is a live row, so neither needs a `VER-*`.
- **One layout per session.** A new session writes `define/` and can't create a root `requirements.md`. A session from before the folder keeps its root `requirements.md` and can't create `define/`. Nothing converts one layout into the other, and past sessions are never migrated. Every tool that reads requirements reads `define/requirements.md` first and falls back to the root file.

## The `design/` folder

Design's output is one main doc plus files the solution kind and scope call for. The standard is the [`design` skill](../../../skills/design/SKILL.md).

| File | Holds | When |
|---|---|---|
| `index.md` | The **main doc**: Prior knowledge, Classification (primary kind), Scope checklist, Context view, Delta list, Components (`ID \| Component \| Covers \| Result \| Check \| Depends on`), Decisions, Principles check (with "Rejected under YAGNI"), Risks and Open questions | always |
| `solution.md` | The kind's in-depth design. For a three-tier application: each layer changing or unchanged, the contracts between changing layers, and C4 L1 and L2 views, approved before any layer file | when the kind has an in-depth path |
| `frontend.md`, `backend.md`, `database.md` | Layer designs, to the standard in the layer's home `skills/{layer}/` | when the layer changes and its standard exists |
| `ui-handoff.md` | The Claude Design handoff (screens, components, the `REQ-*` they serve, states, behaviour constraints, no visual values) and the returned design: `assets/ui-design.zip` kept as-is and one embedded `assets/ui-{screen}.png` per screen | when visual UI design is in scope |

Visuals follow the skill's [notation catalogue](../../../skills/design/reference/notations.md): C4 abstractions drawn as Mermaid `flowchart`s with four delta classDefs and a `[status]` label suffix, and a caption naming the notation and C4 level. A non-Mermaid source, such as BPMN, sits in `assets/` with a rendered SVG beside it.

**Design gate.** The gate message shows (or links) `design/index.md#context-view` and `#delta-list`. Before the milestone, `check-design.sh {session}` requires the Classification, Scope checklist, Context view and Delta list headings, and names any that are missing. A session with only a root `design.md` gets "legacy layout: no check".

## The `implement/` folder

Implement's output is the plan and the record of what was built, in two files. The standard is the [`implement` skill](../../../skills/implement/SKILL.md); its rules are listed in the [Implement reference](../implement/standard.md).

| File | Holds |
|---|---|
| `tasks.md` | The plan: a `task-executor`-format checklist, one task per `DES-*` Result, in the design's Depends-on order, each item's Check on its last task. Nothing else |
| `as-built.md` | The as-built record, as tables only: **As-built** (one status per `DES-*` item), **Variations** (each difference from the design), **Layer artifacts** (one subsection per layer, such as the backend's OpenAPI document and API check) and **Handed to Test** (Checks that need a Test-owned test) |

**Implement gate.** In a session with `implement/as-built.md`, the gate message lists every `DES-*` status and every variation above the options. The user accepts each variation as built or sends it back for rework, and one `decision` entry names every outcome. The milestone isn't approved while any rework is outstanding. A session with a root `tasks.md` is shown as before.

## Milestone gate checks

Approval alone completes most milestones. Four gates also check the session's content before the orchestrator records the milestone:

| Gate | Check | On failure |
|---|---|---|
| Define | **a3.** If `define/index.md` records a full or short tier and `define/framing.md`'s anchor-update action is anything but `none`, the README's marked anchor section must contain that agreed text and pass the [anchor checklist](../framing/tiers-and-anchor.md#anchor-contract). A session with no `define/` folder gets no a3 check. | Refuse, show the missing or differing element, apply the anchor write, ask again |
| Design | **a4.** `check-design.sh` exits 0: `design/index.md` has the Classification, Scope checklist, Context view and Delta list sections. A session with only a root `design.md` passes with no check. | Refuse, name the missing sections (e.g. "delta list missing"), stay in Design |
| Test | `check-traceability.sh` exits 0: every live `REQ-*` has a passing `VER-*` | Refuse, list the missing IDs, stay in Test |
| Deploy | `release.md`'s *Completeness* section shows the release manifest lists only complete components and leaves none out | Refuse, show the gaps, stay in Deploy |

**Anchor write.** When Define returns a `decision` entry for an anchor update, the orchestrator (never a phase agent) writes the agreed text from `define/framing.md`'s anchor-update block into the root `README.md` between the anchor markers. It creates the README, or appends the whole `## Project anchor` section, if either is missing. It writes only the elements the block names and never changes wording outside them. The decision entry, `define/framing.md` and `README.md` go in one commit.

## `log.md` format

Frontmatter:

| Key | Values |
|---|---|
| `session` | `{date}-{slug}` |
| `type` | `feature` |
| `issue` | GitHub issue number |
| `branch` | The session branch: written once when the session opens, never changed, and read by Resume. Sessions opened before the field have none; Resume then uses the branch the session was found on. |
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

## Close fold-back

Close has no session artifact. It writes what is still true once the feature has shipped into the Diátaxis docs tree, and leaves how the work got there in the archived session folder.

| Session content | Destination |
|---|---|
| `define/index.md` (framing summary, scope, non-goals, constraints, open questions) and `define/framing.md` | Stays in the archive. An anchor change is already in the README from Define. |
| `define/problem.md`: context, needs and stakeholders, success outcomes | "Why this exists and who it's for" in `docs/explanation/<domain>/overview.md` |
| `define/problem.md`: evidence, impact and why now, appetite | Stays in the archive (time-bound) |
| `define/requirements.md`: live rows | Behaviour as current fact in `docs/reference/<domain>/`; matching construct files get their functional requirements |
| `define/requirements.md`: struck rows and the Deferred table | Stay in the archive; each deferred row's follow-up issue carries it forward |
| `define/quality.md`: NFR measures | Limits and targets in `docs/reference/<domain>/` |
| `define/quality.md`: still-true assumptions | The domain overview's Dependencies or Gotchas |
| `define/diagrams.md`: context diagram, to-be process | The domain overview's architecture and How It Works sections |
| `define/diagrams.md`: as-is, impact map, traceability | Stay in the archive |
| `design/index.md`: decisions flagged "ADR" | One ADR each in `docs/registry/decisions/`, numbered at Close |
| `design/index.md`: context view; `design/solution.md` | The domain overview's architecture and How It Works sections, redrawn without delta styling |
| The rest of `design/` | Stays in the archive |
| `implement/as-built.md`: Variations (all accepted at the gate) | The built behaviour as current fact in `docs/reference/<domain>/`, replacing what the design said; the reason, where it matters, in the domain overview |
| `implement/as-built.md`: Layer artifacts | `docs/reference/<domain>/`, as a pointer to the artifact in the code (for the backend, the OpenAPI document and its Scalar render) |
| `implement/tasks.md`: a repeatable, non-obvious procedure | A guide in `docs/how-to/` |
| `implement/tasks.md` checklist; `as-built.md` As-built and Handed to Test | Stay in the archive |

A session with a root `requirements.md` is mapped by section: its problem statement like `problem.md`, its `REQ-*` table like `requirements.md`, the rest like `index.md`. A session with a root `tasks.md` folds its "Deviations from design" like accepted variations. How-to guides come from Implement's plan, never from Define.

**Construct registration.** Close is the only phase that registers a session's constructs, once the Implement gate has decided every variation: a new construct gets `docs/reference/constructs/{Name}.md` with `status: built` and a row in `docs/registry/index.md`, a planned one is flipped to `built`, and a changed one gets its Interface and Dependencies updated. Close's `done` note names each one with `/compass-labs:post-hook-validator {Name}`, which the developer runs to validate it against its functional requirements. `task-executor` reads the registry but never writes it.

As-built docs never cite a specific session's `REQ-*`, `DES-*` or `VER-*` IDs, or a variation's ID, because those IDs only mean something inside their session, and every session numbers its own from 1. Each doc Close touches carries one `Origin: #{issue}` line instead, which is the only way back to the session.

## Session branch and pull request

A session's commits never land on the repository's default branch. They are made on the **session branch**, and reach the default branch only when the user merges the session's pull request. The default branch is always read from the repository (`default-branch.sh`), never assumed to be `main`. [`session-branch-guard.sh`](hooks-and-scripts.md#session-branch-guardsh) blocks a session commit or push to it ([ADR-006](../../registry/decisions/006-session-branch-guard.md)); the rest is the `session` skill's procedure.

| When | What the orchestrator does |
|---|---|
| New session, after the slug and before anything is written | Reads the default branch and the current branch. **On the default branch:** proposes `feat/{issue}-{kebab-title}`, and the user accepts it or replies with another name, used exactly as given. **On any other branch:** asks once whether to use that branch as the session branch (no switch) or create a new one; a new one gets the same name proposal and starts from the local default branch's tip, not the current `HEAD`. Then `git switch {name}` if the branch exists, else `git switch -c {name} {default}`. |
| The branch step fails | `default-branch.sh` exits 1, or `git switch` fails (a dirty working tree, the branch checked out in another worktree): the orchestrator stops, writes and commits nothing, and relays git's reason. |
| New session folder | `log.md`'s `branch:` is set to the session branch. |
| Opening commit | Pushed with `git push -u origin {branch}`. Then, before the GitHub label and comment: if `gh pr list --head {branch} --state open` shows a pull request, it is logged and nothing is asked. Otherwise the user is asked **once** whether to open a draft pull request; if they agree, `gh pr create --draft --base {default} --head {branch}` with a title from the issue and `Refs #{issue}` in the body, and its URL is logged. If they decline, that is logged as a `decision` and never asked again in the session. A `gh` failure is logged as "GitHub sync pending". |
| Listing sessions | `list-sessions.sh`, which also finds sessions whose folder exists only on another local branch. |
| Resume, before the recap and before any commit | Switches to the session branch (its `branch:`, or the branch it was found on) if it isn't checked out. If the switch fails, stops and relays git's reason. |
| Close | Tells the user the pull request is ready for them to merge. |

**No-merge rule.** The orchestrator never runs `gh pr merge`, or a `git merge` or `git push` into the default branch, unless the user's own message asks for it. A phase agent's or subagent's message never counts as that instruction. Merging is the user's call in every phase and at every gate. The rule is stated in both `skills/session/SKILL.md` and `agents/orchestrator.md`; no hook enforces it, because a hard block would also stop the merge the user asks for.

## Commit points

The rule template `skills/session/templates/rules/compass-sessions.md` is copied to a consuming repo's `.claude/rules/compass-sessions.md` (scoped to `docs/sessions/**`) on first use. It is never overwritten. See [Atomic commit points](../../registry/patterns.md#atomic-commit-points).
