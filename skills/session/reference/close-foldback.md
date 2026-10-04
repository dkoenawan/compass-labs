# Close fold-back procedure (D6)

This is what the Close phase agent actually does, kept out of `agents/close.md` itself so that file stays a thin D4 wrapper (C8).

Close produces **no session artifact** of its own (`artifact: null` in `feature.json`). Your job is to turn the finished session into as-built documentation, not to archive the folder yourself — the orchestrator does the archive move, after you're done, using its own script (see "What you don't do" below).

## Steps

1. **Read, don't write, the session's own record**: the frozen `define/` folder (or the root `requirements.md` in a past session), the frozen `design/` folder (or the root `design.md` in a past session), and `log.md`'s **Key decisions** section (never write `log.md` — you return `log_entries` like every other phase agent).
2. **Run a `doc-maintainer` pass** to update the repo's as-built docs:
   - `docs/reference/` and `docs/explanation/` — reflect what's now true about the system, not what happened to get there.
   - `docs/registry/index.md` and `docs/reference/constructs/*.md` — flip any construct this session built from `planned` to `built` (or add new ones the session introduced), the same way `task-executor` does per-task.
   - **No session narrative anywhere in as-built docs.** No "we discussed," no "first we tried X, then...". That story stays in the archived session folder, not in the flat docs.
   - Add exactly **one `Origin: #{issue}` line** to each doc file you touch — a stable pointer back to the session's GitHub issue (which persists after archive; the session path inside the archived folder is the fuller "why," reachable from the issue if anyone needs it).
   - **Map Define's and Design's output section by section**, using [Folding back `define/`](#folding-back-define) and [Folding back `design/`](#folding-back-design) below. A section that's still true once the feature has shipped is rewritten as current fact; anything about how we got there stays in the archive.
   - **No session IDs in as-built docs.** Never cite a specific session's `REQ-*`, `DES-*` or `VER-*` ID (like `REQ-004`) in `docs/`: those IDs only mean something inside their session, and every session has a `REQ-001`. The `Origin: #{issue}` line is the only way back. Naming the ID *scheme* (`REQ-*`, "REQ → DES → task → VER") is fine where it's current fact about the session system itself. Before returning `done`, grep every doc you touched for `(REQ|DES|VER)-[0-9]` and rewrite any hit.
3. **Return `done`** with `log_entries` including one `note` entry (e.g. `Fold-back ready — folded requirements/design into <list of doc files>`) summarizing what was folded back and where. Phase agents never emit `milestone` entries (contract rule 6): the orchestrator writes the `✅ Session closed` milestone itself at the gate, then does the archive move (see below) — that's what actually finishes the session.

## Folding back `define/`

The rule: a section that's still true once the feature has shipped goes into the Diátaxis docs tree, rewritten as current fact. Anything about how we got there stays in the archived session folder. Anything this table doesn't map stays archived too.

| Define doc and section | Destination | Diátaxis |
|---|---|---|
| `index.md` (the main doc): framing summary, scope, non-goals, constraints, open questions | Stays in the archive. The issue link and the `Origin` lines point back. | — |
| `framing.md`: tier, XY, anchor verdict, overlaps | Stays in the archive. Any anchor change is already in the README, written at Define. | — |
| `problem.md`: context, needs and stakeholders, success outcomes | Rewritten as "why this exists and who it's for" in the domain's `docs/explanation/<domain>/overview.md` | Explanation |
| `problem.md`: evidence, impact and why now, appetite | Stays in the archive, because it's time-bound | — |
| `requirements.md`: live `REQ-*` rows | The behaviour, stated as current fact, in `docs/reference/<domain>/*.md`. Matching construct files in `docs/reference/constructs/` get their functional requirements. | Reference |
| `requirements.md`: struck rows (dropped rows and "never" Won'ts) | Stay in the archive | — |
| `requirements.md`: the Deferred table | Stays in the archive. Each row's follow-up issue carries the requirement forward, and a later session writes it afresh. | — |
| `quality.md`: NFRs with their measures | `docs/reference/<domain>/`, as limits and targets | Reference |
| `quality.md`: 25010 N/A reasons, assumptions | Stay in the archive, except still-true assumptions, which go to the domain overview's Dependencies or Gotchas | Explanation |
| `diagrams.md`: context diagram, to-be process | The domain overview's architecture and "How it works" sections | Explanation |
| `diagrams.md`: as-is, impact map, traceability | Stay in the archive. The as-is is superseded, and the others are tied to session IDs. | — |

Tutorials and how-to guides don't come from Define. A how-to comes from Implement's `tasks.md`, when the session built a repeatable procedure.

**Past sessions.** A session from before the `define/` folder keeps its root `requirements.md`; it's never migrated. Map it by section: its problem statement like `problem.md`, its `REQ-*` table like `requirements.md`, and the rest like `index.md`.

**`doc-maintainer`'s session step.** `doc-maintainer`'s Step 2.S1 still expects the old plan-format `overview.md` (#41). For a session run through this lifecycle, the mapping above is what you follow.

## Folding back `design/`

The same rule applies: what's true of the shipped system goes into the docs tree as current fact, and the rest stays archived.

| Design doc and section | Destination | Diátaxis |
|---|---|---|
| `index.md`: Decisions flagged "ADR" | One ADR each in `docs/registry/decisions/`, numbered at Close (the next free `ADR-nnn`), with the options, the choice and the reason. A decision that refines an existing ADR says so and links it | Explanation |
| `index.md`: Decisions that link an existing ADR, or that aren't flagged | Stay in the archive. The linked ADR already holds the decision | — |
| `index.md`: Context view; `solution.md`: the in-depth design (for three-tier, the whole-system design and its C4 views) | The domain overview's architecture and "How it works" sections, redrawn without delta styling, as the system is now | Explanation |
| Everything else: Classification, Scope checklist, Delta list, Components (DES), Principles check, Risks, Open questions, the layer designs and `ui-handoff.md` | Stays in the archive. These describe the change, not the result, and they cite session IDs. The as-built behaviour reaches `docs/reference/` through the requirements mapping above | — |

**Past sessions.** A session from before the `design/` folder keeps its root `design.md`; it's never migrated. Map its Decisions like `index.md`'s Decisions (an ADR link stays a link), and its approach like the solution design. The rest stays in the archive.

## What you don't do

- You don't flip `log.md`'s `status` to `archived` — the orchestrator does, since it owns every write to `log.md`.
- You don't run `git mv` or `${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/archive-session.sh` — the script itself refuses to run until `status: archived` is already committed (so the guard hook's file set stays correct at every point: nothing should try to write under `docs/sessions/{id}/` *after* the move, since everything past that point is under `archive/`, which the guard always blocks). The **order** the orchestrator follows is spelled out in `skills/session/SKILL.md`'s Close-milestone section — you don't need to enforce it yourself, just don't try to do the move.

## If fold-back can't proceed

Return `blocked` (not `needs_input` — you can't ask the user mid-fold-back) if, for example, a `REQ-*` has no sensible home in the existing `docs/` structure and you can't reasonably invent one. Say what's missing; the orchestrator surfaces it to the user.
