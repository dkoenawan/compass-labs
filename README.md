# compass-labs

A Claude Code plugin of opinionated skills, agents and hooks for systematic, framework-based work. Its vision, mission and scope are stated once, in the [Project anchor](#project-anchor) below; the rest of this README describes what the plugin ships today.

## Overview

compass-labs gives Claude Code structured, repeatable workflows instead of ad-hoc generation: a session lifecycle that takes a piece of work from framing to as-built docs, standards for the artifacts each phase writes, and skills for scaffolding, planning, exploring a codebase, maintaining docs, recording decisions and running tasks unattended (see the [Project anchor](#project-anchor)).

Every skill and agent is namespaced by the plugin's name: skills are invoked as `/compass-labs:<skill>` and agents as `compass-labs:<agent>`. Renaming the prefix to `/compass:` is tracked in #34.

<!-- compass:anchor -->
## Project anchor

### Vision

AI-assisted delivery work, covering software development, research and consulting, based on common established frameworks used by enterprise teams.

### Mission

compass-labs is a Claude Code plugin that structures each piece of work as a session, from problem framing to a documented outcome. Each stage uses a common framework:

- SCQ for problem framing
- MoSCoW for prioritisation
- EARS and Given/When/Then for requirements
- ISO/IEC 25010 for quality
- MADR for decisions
- C4 for architecture
- Diátaxis for documentation

### Scope

- Session types: Feature (available); Bugfix, Research and Consulting (planned).
- Standards for each session artifact, by session type and depth tier.
- Hooks and scripts that enforce session structure and traceability.
- Supporting skills: scaffolding, planning, codebase exploration, documentation, architecture decisions, task execution, brand design.
- Works in any repository, independent of tech stack.

### Non-goals

- A runtime, framework or hosted service.
- Replacing user approval at milestones.
- Creating new methods where an established one exists.
- Applying a framework where it doesn't fit.
<!-- /compass:anchor -->

## Installation

### Option 1: Permanent (Recommended)

Installs the plugin so it loads automatically on every `claude` session — no flags needed.

**Step 1 — Clone the repo**

```bash
git clone https://github.com/dkoenawan/compass-labs.git
```

**Step 2 — Register as a local marketplace**

```bash
claude plugin marketplace add /path/to/compass-labs
```

**Step 3 — Install the plugin**

```bash
claude plugin install compass-labs@compass-labs
```

**Step 4 — Verify**

```bash
claude plugin list
# compass-labs@compass-labs should show Status: ✔ enabled
```

All skills are now available in every `claude` session. To update later:

```bash
claude plugin update compass-labs@compass-labs
```

---

### Option 2: Session-only (quick test)

Loads the plugin for the current session only. Nothing is written to your user config.

```bash
claude --plugin-dir /path/to/compass-labs
```

---

### Option 3: Clone and load session-only

```bash
git clone https://github.com/dkoenawan/compass-labs.git
cd compass-labs
claude --plugin-dir .
```

## Plugin Structure

This plugin follows the Claude Code plugin architecture:

```
compass-labs/
├── .claude-plugin/
│   ├── plugin.json                    # Plugin manifest
│   └── marketplace.json               # Local marketplace entry (lists every shipped skill)
├── agents/                            # Subagents: the session orchestrator + one agent per Feature phase
│   ├── orchestrator.md                # Session orchestrator entry point
│   ├── define.md                      # Define: frames the problem, writes define/
│   ├── design.md                      # Design: writes design/ (context view, delta list, DES items)
│   ├── implement.md                   # Implement: writes tasks.md and the code
│   ├── test.md                        # Test: writes verification.md
│   ├── deploy.md                      # Deploy: writes release.md
│   └── close.md                       # Close: folds the session into as-built docs
├── skills/                            # Agent-based skills, one folder each
│   ├── session/                       # Session lifecycle orchestrator (Define→Design→Implement→Test→Deploy→Close)
│   │   ├── SKILL.md
│   │   ├── templates/                 # Per-phase artifact templates (define/ and design/ folder templates included) + commit-rule template
│   │   ├── workflows/                 # feature.json: phases, owners, artifacts, milestones, framing block
│   │   ├── scripts/                   # gh-setup.sh, gh-milestone.sh, check-traceability.sh, check-design.sh, archive-session.sh
│   │   └── reference/                 # Shared phase-agent contract, Close fold-back procedure
│   ├── framing/                       # Shared problem-framing step + the project anchor contract
│   ├── problem-statement/             # Problem-statement standard, per session type (types/) + methods record
│   ├── requirements/                  # Requirements standard: EARS + Given/When/Then + ISO 29148, per type, diagrams, worked example
│   ├── verification/                  # VER-* verification table standard
│   ├── design/                        # Design standard: solution kinds, notation catalogue, stack defaults
│   ├── init/                          # Project initialization (recommended)
│   ├── explore/                       # Token-efficient codebase investigation
│   ├── doc-maintainer/                # C4-layered docs tree, maintained incrementally
│   ├── adr/                           # Architecture decision records
│   ├── task-executor/                 # Autonomous, scheduled task execution for large issues
│   ├── post-hook-validator/           # Post-commit functional-requirement validation
│   ├── brand-designer/                # Brand identity design through discovery
│   └── bootstrap-new-project/         # Direct-generation project bootstrap (deprecated)
├── commands/                          # Slash commands (e.g. /compass-labs:hello); skills are slash commands too
├── hooks/                             # PreToolUse/SessionStart/Stop hooks (session guard, commit guard, session start)
├── tests/                             # bash + jq test harness for hooks and scripts (tests/run.sh)
├── docs/                              # The plugin's own Diátaxis docs, registry and session folders
├── README.md                          # This file
└── CLAUDE.md                          # Guidance for Claude Code instances
```

## Skills Included

### Project Initialization

#### `/compass-labs:init` (Recommended)

Initialize a new full-stack project from a template repository with opt-out component selection.

**What the template contains:** React + Vite + TypeScript (frontend), Node.js + TypeScript + Prisma (backend), PostgreSQL (database), and Docker with docker-compose for local development. These follow the plugin's stack defaults, stated once in [`skills/design/reference/stack-defaults.md`](skills/design/reference/stack-defaults.md). The Design phase proposes those defaults only where a repository has no established stack.

**Usage:**
```bash
/compass-labs:init
```

**How it works:**
1. Clones the [compass-scaffolding](https://github.com/dkoenawan/compass-scaffolding) template
2. Asks which components to EXCLUDE (opt-out approach)
3. Removes unwanted components and updates configs
4. Optionally initializes git and installs dependencies

**Interactive prompts:**
- Project name (default: "my-project")
- Target directory (default: ./{project-name})
- Components to exclude (multi-select, default: none)
- Initialize git? (default: yes)
- Install dependencies? (default: no)

**After init:**
- Frontend: http://localhost:3000
- Backend: http://localhost:4000
- Database: PostgreSQL on localhost:5432

---

### Brand Design

#### `/compass-labs:brand-designer`

Design a distinctive brand identity through systematic emotional discovery — generates brand guidelines, CSS custom properties, and optional Tailwind config.

**What it produces:**

| File | Description |
|------|-------------|
| `brand/brand-guideline.md` | Comprehensive brand identity doc (colors, typography, spacing, component tokens, voice & tone) |
| `brand/brand-theme.css` | CSS custom properties in HSL format with intentionally designed dark mode |
| `brand/tailwind.brand.js` | Tailwind theme config (only if selected) |

**Usage:**
```bash
/compass-labs:brand-designer
```

**How it works (6 phases):**

1. **Brand Soul Discovery** — Understand the brand's story, future vision, and personality archetype
2. **Emotional Mapping** — Define the three core emotions, sensory environment, and anti-inspiration
3. **Visual Direction** — Gather references, assess existing assets, confirm technical context
4. **Creative Direction Synthesis** — AI presents a narrative creative brief for approval before generating anything
5. **File Generation** — Produces brand guidelines, CSS theme, and optional Tailwind config
6. **Handoff Summary** — Google Fonts snippet, import instructions, and next steps

**Key principle:** Colors are derived from emotions, not picked from palettes. The skill spends most of its time understanding the brand through discovery before generating any design artifacts.

---

### Codebase Investigation

#### `/compass-labs:explore`

Token-efficient codebase investigation — reads docs before code, stops when context is sufficient.

**What it produces:**

A structured Investigation Report covering tech stack, data models, backend structure, frontend structure, key architectural patterns, and relevance to the investigation focus.

**Usage:**
```bash
/compass-labs:explore
```

**How it works (3 tiers, stops early):**

1. **Tier 1 — Docs First** (always): README → docs/ → CLAUDE.md. Stops here if tech stack, structure, and focus context are clear.
2. **Tier 2 — Structure** (only if needed): package.json → Prisma schema → directory listings. Stops here if focus is answered.
3. **Tier 3 — Targeted Code** (only if needed): ≤5 files, no import chain following, no broad scanning.

**Key principle:** Thoroughness is not a virtue; precision is. The skill gathers exactly enough context to answer the investigation focus, then stops. Runs on Haiku to minimize token cost.

**Invocation modes:**
- **Standalone**: Invoke directly and provide an investigation focus (e.g., "auth system", "order management", "overall architecture")
- **From another skill**: `doc-maintainer` passes the focus directly — no manual invocation needed

---

### Feature Planning (retired)

The `plan` skill has been retired into the Design phase of a Feature session. Run `/compass-labs:session` to design a feature: its Design phase follows the [`design` standard](#compass-labsdesign). `/compass-labs:plan` no longer exists. Its registry read, trade-off surfacing, approval gate and stack handling are part of Design now. Its layer-by-layer depth (entities, API shapes, routes) moves to the per-layer design standards, which are tracked as follow-up issues.

---

### Documentation Maintenance

#### `/compass-labs:doc-maintainer`

Builds and maintains a **C4-layered documentation tree** that grows incrementally — one file per run. Designed so both humans and agents can navigate to exactly the information they need without reading everything.

**The C4 navigation model:**

| Level | File | What it answers | When to read |
|-------|------|-----------------|--------------|
| L1 | `docs/explanation/solution-design.md` | What is this system, who uses it, what external systems does it touch? | Always — it's the entry point |
| L2 | `docs/explanation/containers.md` | What services run, how do they communicate, how is it deployed? | When you need infrastructure context |
| L3 | `docs/explanation/<domain>/overview.md` | What is this domain, how does it work end-to-end, which files touch it? | When working in a specific domain |

**Key principle:** `init` generates L1 only. Each subsequent `maintain` run adds or improves exactly one file — L2 first, then one L3 domain per run, then session fold-back, then accuracy patches, then daily clarity reviews. Token cost scales with task scope.

The C4 tree lives under `docs/explanation/` as part of the plugin's [Diataxis](https://diataxis.fr/) documentation structure — see [ADR-001](docs/registry/decisions/001-diataxis-docs-restructure.md). Sibling top-level folders: `docs/tutorials/`, `docs/how-to/`, `docs/reference/` (registry constructs + API specs), and `docs/sessions/` (session-scoped specs, folded back by `doc-maintainer` on completion).

**What it produces:**

| File | Description |
|------|-------------|
| `docs/explanation/solution-design.md` | L1 system context: purpose, users, external systems, domain map with drill-down links |
| `docs/explanation/containers.md` | L2 container architecture: deployable units, data flows, deployment model |
| `docs/explanation/<domain>/overview.md` | L3 per-domain: object lifecycle, core entities, code map, gotchas |
| `docs/explanation/clarity-log.md` | Running log of daily clarity reviews — one entry per run |
| `docs/how-to/*.md`, `docs/reference/*.md` | Task guides and reference material folded back from completed `docs/sessions/` |

**Usage:**
```bash
/compass-labs:doc-maintainer          # auto-detect: init if docs/ absent, else maintain
/compass-labs:doc-maintainer init     # generate L1 (solution-design.md) only
/compass-labs:doc-maintainer maintain # one unit of work: next missing doc, stale patch, or clarity review
/compass-labs:doc-maintainer refresh  # full rewrite of all docs
/compass-labs:doc-maintainer refresh <domain>  # full rewrite of one named domain
```

**How maintain mode prioritises work (one per run):**

1. Generate `docs/explanation/containers.md` (L2) if missing
2. Generate the next missing `docs/explanation/<domain>/overview.md` (L3), oldest-discovered domain first
3. Fold back the oldest unfolded `docs/sessions/<session>/` into `docs/how-to/`, `docs/reference/`, and `docs/explanation/`
4. Accuracy-patch the most stale existing doc (>30 days old)
5. Clarity review — improve prose quality of the oldest-reviewed doc

**Scheduling (unattended daily runs):**
```bash
# Install a daily cron job for a target repo
bash skills/doc-maintainer/scripts/install-schedule.sh /path/to/repo --time 13:15

# Run Monday–Friday only
bash skills/doc-maintainer/scripts/install-schedule.sh /path/to/repo --time 09:00 --days mon-fri

# Uninstall
bash skills/doc-maintainer/scripts/uninstall-schedule.sh /path/to/repo

# Check installed jobs
crontab -l | grep doc-maintainer
```

**File size discipline:** Any doc that grows beyond 500 lines is automatically split into a subfolder (`docs/explanation/<domain>/index.md` + sub-files) so no single file ever needs to be read in full to get oriented.

**Feature tracing:** `docs/explanation/features/<feature-name>.md` traces a named feature end-to-end — FR/NFR → Pages → API specs → Technical architecture — generated on-demand during session fold-back rather than scheduled. See [ADR-001](docs/registry/decisions/001-diataxis-docs-restructure.md).


---

### Autonomous Task Execution

#### `/compass-labs:task-executor`

Runs large GitHub issues autonomously via cron over multiple days. An interactive planning conversation decomposes an issue into hour-sized tasks, then executes up to 3 per scheduled run — rebasing, implementing, testing, committing, and opening a PR on completion.

**Why 6-hour cadence:** Aligns with the ~5h Claude quota window so runs don't exhaust quota mid-task.

**What it produces:**

| Artifact | Description |
|----------|-------------|
| `docs/sessions/<date>-<feature-name>/tasks.md` | Plan file with frontmatter (issue, branch, test command, retry counts) + dependency-annotated checklist |
| `feat/<feature-name>` branch | One commit per completed task, conventional-commit format |
| GitHub PR | Opened automatically on completion, linked to the issue |

**Usage:**
```bash
/compass-labs:task-executor                    # auto: show status or start planning
/compass-labs:task-executor plan <issue-number> # interactive planning conversation
/compass-labs:task-executor status             # show active plan summary
/compass-labs:task-executor stop               # pause (preserves branch + plan)
/compass-labs:task-executor resume             # resume a paused plan
```

**Typical workflow:**
1. Open a GitHub issue describing the feature
2. Run `plan <issue-number>` — 9-phase conversation produces tasks.md, creates branch, installs cron
3. Come back in a day or two — skill has been committing completed tasks every 6h
4. Review the auto-opened PR

**Task checklist states:**
- `- [ ]` pending
- `- [x]` complete
- `- [!] <desc> (failed YYYY-MM-DD: <reason>)` failed/skipped

**Failure recovery:** Failed tasks are marked `- [!]` after two consecutive failures. Dependent tasks are skipped. If all remaining tasks are blocked, a draft PR is opened with the completed work.

#### `/compass-labs:post-hook-validator`

The quality gate after a `task-executor` commit that updated a construct file. It reads that construct's functional requirements, walks the developer through a pass/fail checklist, moves the construct to `verified` or `diverged`, and on divergence triggers `/compass-labs:adr` and blocks the next `task-executor` run until the ADR is written.

```bash
/compass-labs:post-hook-validator [construct-name]
```

---

### Using Sessions in a Repo

#### `/compass-labs:session`

Runs a **Feature session** end-to-end — Define → Design → Implement → Test → Deploy → Close — as one tracked unit: one session folder, one GitHub issue, one artifact per phase, and a milestone gate the user approves before each phase transition. See [`docs/explanation/session/overview.md`](docs/explanation/session/overview.md) for how it works and [ADR-002](docs/registry/decisions/002-session-lifecycle.md) for the decision.

**What a session is:**

| | |
|---|---|
| **Folder** | `docs/sessions/{date}-{slug}/` — one artifact per phase (`define/`, `design/`, `tasks.md`, `verification.md`, `release.md`), `log.md` (state + append-only history), and an optional non-Markdown `assets/`. `define/` is a folder: a main doc, `index.md`, plus sub-docs by depth tier. `design/` is a folder too: `index.md` plus the files the solution kind needs. Sessions from before them keep a root `requirements.md` or `design.md` instead. |
| **GitHub** | One issue per session, one `phase:*` label at a time, a milestone comment per phase transition, a branch + PR from Implement onward |
| **Enforcement** | A `PreToolUse` guard hook restricts every write under a session folder to that file set, by ownership, and blocks writes to an already-approved ("frozen") artifact unless a decision is logged first |

**Three entry points, all loading the same `session` skill (nothing duplicated between them):**

1. **Repo default** — add to `.claude/settings.json`:
   ```json
   { "agent": "compass-labs:orchestrator" }
   ```
   Plain `claude` then starts as the orchestrator every time — the recommended setup for a repo that runs everything through sessions.
2. **Explicit agent**: `claude --agent compass-labs:orchestrator`
3. **From any conversation**: `/compass-labs:session` (also `/compass-labs:session new`, `resume [slug]`, `status [--all]`)

**Requirements:** `gh` authenticated (`gh auth status`) for GitHub sync — if it isn't, the session keeps going locally and syncs at the next milestone; `jq` on PATH for every session hook/script (each fails open, never blocking, if `jq` is missing).

**What the hooks enforce:**

| Hook | Event | What it does |
|---|---|---|
| `hooks/session-guard.sh` | `PreToolUse` (`Write\|Edit\|MultiEdit`) | Blocks writes outside a session's file set (including files outside `define/`'s or `design/`'s fixed set), writes to another phase's artifact, writes to a frozen artifact without a freshly logged decision, and anything under `docs/sessions/archive/` |
| `hooks/session-start.sh` | `SessionStart` | Lists active/paused sessions as context when starting as the orchestrator |
| `hooks/session-commit-guard.sh` | `Stop` | Blocks ending a turn with an uncommitted `decision`/`milestone` log entry — one commit per entry, code and log together |

**Usage:**
```bash
/compass-labs:session                 # list active/paused sessions, then ask new vs. resume
/compass-labs:session new             # start a new Feature session
/compass-labs:session resume [slug]   # pick up where a session left off
/compass-labs:session status [--all]  # --all also lists archived sessions
```

**When a session closes:** the Close phase folds whatever is still true from the session's `define/` output, design and decisions into the repo's as-built docs (`docs/reference/`, `docs/explanation/`, `docs/registry/`) with no session narrative — just the current truth, plus one `Origin: #<issue>` line per doc it touched — then the orchestrator moves the folder to `docs/sessions/archive/` and closes the issue.

**The agents:**

| Agent | Phase | Writes |
|---|---|---|
| `compass-labs:orchestrator` | All (main session) | `log.md`, milestone commits, GitHub sync, and the README's project anchor |
| `compass-labs:define` | Define | `define/` (framing, problem statement, requirements) |
| `compass-labs:design` | Design | `design/` (and rendered visuals in `assets/`) |
| `compass-labs:implement` | Implement | `tasks.md` and the code |
| `compass-labs:test` | Test | `verification.md` |
| `compass-labs:deploy` | Deploy | `release.md` |
| `compass-labs:close` | Close | As-built docs only; never the session folder |

The phase agents are started by the orchestrator, never directly.

---

### Framing and Artifact Standards

These skills are the standards the phase agents follow. They're preloaded by the agents that need them, and can be read on their own.

#### `/compass-labs:framing`

The shared problem-framing step every session type runs before writing its problem statement and requirements. It proposes a depth tier (full, short or skip) for the user to confirm, then runs that tier's checks: whether the issue names a fix rather than the need behind it, whether it reports a symptom rather than a cause, how the work fits the project anchor (aligns or extends), and whether the registry or ADRs already cover it. Its [anchor contract](skills/framing/reference/anchor-contract.md) defines the marked `## Project anchor` section a project's README holds. Framing names no phase: each session type plugs in through a `framing` block in its workflow file.

#### `/compass-labs:problem-statement`

The problem-statement standard, per session type (`types/feature.md`, `types/bugfix.md`) and depth tier: the need and who has it, evidence tagged observed or assumed, and at deeper tiers context, impact and why now, measurable success outcomes and appetite. Frameworks such as SCQ, job stories and Shape Up are offered as templates, never mandated. Each method's verdict is in its `reference/methods.md`.

#### `/compass-labs:requirements`

The requirements standard: EARS sentences, one Given/When/Then each, and the ISO/IEC/IEEE 29148 checks. Per type and tier it adds MoSCoW priority, a trace from each requirement to the outcome it serves, a table for requirements deferred to later work, ISO/IEC 25010:2023 quality coverage, measurable non-functional requirements, and criteria built from concrete examples. It includes a Mermaid [diagram catalogue](skills/requirements/reference/diagrams.md) and a [worked full-tier example](skills/requirements/examples/feature-full/index.md).

#### `/compass-labs:design`

The Design standard the Design agent preloads. It is the plugin's only path to a solution design, and it replaces the retired `plan` skill. Design reads prior knowledge from the project's docs and code only, never from past session folders. It names the solution's primary kind and a scope checklist for you to confirm, then follows the kind's in-depth path. A three-tier application gets a whole-system design, approved before any layer design. Other kinds use the shared sections and cite their follow-up issue. The output is a `design/` folder:

- **What it holds:** a context view and a delta list, with every touched element marked new, changed, deprecated or unchanged in both the visuals and the list. Then `DES-*` items, each with the requirements it covers, its result, its check and its dependencies, which Implement orders its tasks from. Then the options for every significant choice, which you decide, and a KISS/YAGNI/SOLID principles check.
- **Visuals:** they use established notations from its [notation catalogue](skills/design/reference/notations.md) (C4 by default) and render on GitHub. A non-Mermaid source such as BPMN is committed with a rendered SVG beside it.
- **Visual UI design:** it is handed to Claude Design through `design/ui-handoff.md`, never specified directly.
- **Stack defaults:** the plugin's defaults are stated once, in [`stack-defaults.md`](skills/design/reference/stack-defaults.md). Design proposes them only where the repository has no established stack.
- **The Design gate:** it shows the context view and the delta list, and `check-design.sh` refuses the milestone if either is missing, or if the classification or scope checklist is.

#### `/compass-labs:verification`

The `VER-*` table standard the Test agent follows, in the fixed column order `check-traceability.sh` depends on.


---

### Architecture Decisions

#### `/compass-labs:adr`

Captures a significant architecture decision as a MADR-format ADR. A six-phase conversation draws out the decision's context, options, NFRs and revisit conditions, then writes `docs/registry/decisions/<NNN>-<title>.md`, updates the decisions index, cross-links affected construct files, and appends to `patterns.md` when a cross-cutting convention is set. Also triggered by `post-hook-validator` when an implementation diverges from its construct.

---

### Deprecated

#### `/compass-labs:bootstrap-new-project` (Deprecated)

> **Deprecated**: Use `/compass-labs:init` instead. This skill generates files directly which is less token-efficient. It predates the [stack defaults](skills/design/reference/stack-defaults.md): it generates Swagger UI rather than Scalar, and no infrastructure-as-code.

Bootstrap a complete full-stack project with systematic structure and best practices.

**What it creates:**

- **Infrastructure**: Docker setup with docker-compose.yml orchestration
- **Backend**: Node.js + TypeScript with Clean Architecture
  - Domain, Usecases, Interface, Infrastructure layers
  - CQRS pattern (commands and queries separated)
  - Express.js server with health endpoint
  - Swagger API documentation
  - OpenAPI specification
- **Frontend**: React + TypeScript + Vite + Material-UI
  - Atomic design structure (atoms, molecules, organisms, templates, pages)
  - MUI theme configuration
  - Landing page component
  - Routing setup
- **Database**: Placeholder directory for future implementation
- **Agent**: Placeholder directory for agentic AI workflows

**Usage:**
```bash
/compass-labs:bootstrap-new-project
```

**Interactive prompts:**
- Project name
- Target directory
- Initialize git repository?
- Install dependencies?

**After bootstrap:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:4000
- API Docs: http://localhost:4000/api-docs
- Health Check: http://localhost:4000/health

## Development

To develop this plugin locally:

1. Clone the repository
2. Make changes to skills, agents, commands, or hooks
3. Run the test harness: `bash tests/run.sh`
4. Test live using `claude --plugin-dir .`
5. Submit pull requests for improvements

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for:

- New skills for systematic development workflows
- Improvements to existing skills
- Documentation enhancements
- Bug fixes

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Daniel Koenawan

## Resources

- [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference)
