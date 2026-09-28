---
id: "003"
date: 2026-09-27
status: Accepted
deciders: [Daniel Koenawan]
affects: [framing, problem-statement, requirements, session, verification, doc-maintainer]
issue: https://github.com/dkoenawan/compass-labs/issues/23
---

# ADR-003: A shared framing step, per-type standards, a README project anchor, and Define's output as a folder

> Origin: #23

## Context

Sessions were framed from the issue's wording taken at face value. Nothing checked whether the stated problem was a fix chosen too early, a symptom rather than its cause, or work that already existed, so requirements could be precise about the wrong thing. The only standard covered the requirements table, and only for Feature sessions, while Bugfix and Research sessions are coming (#24, #25) and frame problems differently. No project had its vision and mission written down in an agreed place, so new work couldn't be checked against it. And a Feature definition deep enough to fix all this would crowd a single `requirements.md`.

Constraints: the plugin is publicly distributed, so framing must work in a repo with no README, no `docs/`, no registry and no ADRs; the anchor can't assume a tech stack or docs layout; the phase-agent contract (a phase agent asks the user only through the orchestrator, writes only its own artifact, never writes `log.md`) stays as it is; `check-traceability.sh` and the REQ → DES → VER chain keep working; and existing sessions stay valid.

## Decision

We will make **framing its own skill** (`framing`), which names no phase. Each session type plugs into it through a `framing` block in its workflow JSON, and reads **one standards skill per artifact section** (`problem-statement`, `requirements`), each with `types/{type}.md` files. The project anchor is a **marked `## Project anchor` section in the root README**, whose contract framing defines. **Define's output becomes a `define/` folder**, one artifact with a fixed file set, owned and frozen as a unit. The decisions, as agreed in #23's design:

| # | Decision |
|---|---|
| D1 | The orchestrator applies every anchor write. Define only drafts it, and a Define-gate check (a3) refuses the milestone until the README contains the agreed text. |
| D2 | The anchor is a `## Project anchor` section in the root README, between `<!-- compass:anchor -->` markers. |
| D3 | Framing is its own skill. Session types plug in through a `framing` block in `workflows/<type>.json`, which is the only place the phase is named. |
| D4 | One standards skill per artifact section (`problem-statement`, `requirements`), each with `types/{feature,bugfix}.md`, read on demand. `requirements` keeps its name. |
| D5 | Each section's method verdicts live beside its standard, in `reference/methods.md`. |
| D6 | No bulk migration. The new standard applies to new sessions. Past sessions keep the root `requirements.md`, the guard and `check-traceability.sh` still read it, and each session uses one layout. |
| D7 | Outcomes and needs get IDs local to the Define output (`OUT-nn`, `NEED-nn`). Priority and Serves are columns 3 and 4 of the REQ table; `ID` stays first. |
| D8 | A Won't is never a live row. A "never" Won't is struck through with its reason; a "later" Won't moves to a `## Deferred` table whose first column is its required follow-up issue. |
| D9 | One diagram catalogue, at `requirements/reference/diagrams.md`, with each diagram owned by the type file of the section it illustrates. |
| D10 | The traceability diagram's form (`requirementDiagram` or `flowchart LR`) is chosen per case for reviewability. A trace too big to review prompts asking whether the feature should be split. |
| D11 | The worked example is self-service password reset for a team wiki. |
| D12 | Don't overcrowd the Define document: one main doc linking to focused sub-docs, each created only when the confirmed tier needs it. |
| D13 | Everything Define writes goes in `define/`: `index.md` (the main doc), `requirements.md`, `framing.md`, `problem.md`, `quality.md`, `diagrams.md`. The workflow declares it as a folder artifact, and the guard owns and freezes it as a unit. |
| D14 | At Close, each section of `define/` still true after shipping is rewritten as current fact in the Diátaxis docs; the rest stays in the archive. Session IDs never appear in as-built docs. |

**This refines [ADR-002](002-session-lifecycle.md).** Each phase still owns exactly one artifact, but that artifact may now be a folder with a fixed file set (`artifact_files`, one level deep). The session folder stays bounded, so ADR-002's "bounded folder" NFR still holds.

## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Framing skill + per-type standards + README anchor written by the orchestrator + `define/` folder (chosen)** | Phase-agnostic; a new session type adds a workflow block and type files only; the phase-agent contract is unchanged; the anchor is where newcomers look | Define preloads three skills; the guard gains a folder rule | — chosen |
| Define writes the README itself, under a Close-style exception | Fewer steps | A second unenforced exception to "write only your own artifact" | Keeps anchor writes out of phase agents (D1) |
| A dedicated anchor agent | Clear ownership | A new agent for one write; still outside the session folder | Heavier than the orchestrator writing it |
| `docs/anchor.md`, or a configurable anchor location | Separate file | Assumes a `docs/` layout; configuration makes detection a judgement call | Must work in any repo (D2) |
| Framing as a `session/reference` doc, or folded into the problem-statement skill | Fewer skills | Ties framing to one section or to the session skill | Framing is shared by every type and section (D3) |
| Per-type sections inside each SKILL.md | One file per skill | Every session loads every type's rules | Type files are read on demand (D4) |
| Root `requirements.md` as the main doc, with `define/` beside it | Parser and allowlist unchanged | Define's output split across two places; a file named "requirements" holding framing and scope | Rejected for D13 |
| Flat sibling files at the session root | No guard subdirectory rule | Up to six Define files beside five other phases' artifacts, each with its own allowlist and ownership entry | Rejected for D13 |

## NFR Captured

- Compatible: `check-traceability.sh` gives the same result for equivalent content in either layout; extra REQ columns, struck rows and Deferred rows never change it.
- Bounded: `define/` holds at most six named files, one level deep; the guard blocks anything else.
- Portable: framing runs in a repo with no README, registry or ADRs; the anchor contract assumes no stack or docs layout.
- Renderable: every diagram the standards require or offer is a Mermaid type GitHub renders.

## Consequences

**Now easier**: Checking new work against the project's stated scope; adding a session type's framing (a workflow block plus type files); reading one concern of a definition without the rest; seeing which requirements serve which outcome.
**Now harder**: A full-tier Define takes longer; the guard has a folder rule to maintain; two layouts exist side by side across old and new sessions.
**New constraints**: Anchor writes go through the orchestrator. The `REQ-*` table's first column stays `ID`, and the Deferred table's first column stays the follow-up issue. A session never holds both `define/` and a root `requirements.md`. As-built docs never cite a session's `REQ-*`, `DES-*` or `VER-*` IDs.

## Revisit Conditions

If Research (#25) or Bugfix (#24) can't plug into framing without changing the `framing` skill, or if the anchor markers prove too fragile under hand edits and tooling, re-evaluate this decision.
