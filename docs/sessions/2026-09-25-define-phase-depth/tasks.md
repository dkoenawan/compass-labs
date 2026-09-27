---
issue: 23
branch: feat/23-define-phase-depth
status: in-progress
test_command: bash tests/run.sh
last_skill_commit: null
retry_counts:
schedule: null
budget:
  max_tasks_per_run: 3
  max_wall_clock_minutes: 90
  stop_on_first_failure: true
---

Each task names the `DES-*` item it implements ([design.md](design.md)). One commit per ticked task (D8). `bash tests/run.sh` stays green after every task. This session keeps its own root `requirements.md` layout (D6).

- [x] `check-traceability.sh` reads `define/requirements.md`, falls back to the root `requirements.md`, and exits 1 naming both paths when neither exists; fixture cases (a), (b), (d) and (e) test-first in `tests/session/check_traceability_test.sh` [DES-019]
- [x] `skills/session/templates/define/`: the six templates (`index.md`, `requirements.md`, `framing.md`, `problem.md`, `quality.md`, `diagrams.md`), each opening with a `<!-- tier: … -->` comment, with the sections and links in DES-008 detail [DES-008]
- [x] `feature.json`: the `framing` block and `$comment` [DES-007] (depends on: 2)
- [x] Folder artifacts: `feature.json` declares `define/` with `artifact_files` and `legacy_artifact`; `hooks/session-guard.sh` resolves folder keys, prefix ownership and freezing, and the one-layout rule; the new and repointed cases in `tests/hooks/session_guard_test.sh` and checks 3 and 4 in `tests/session/workflow_test.sh`, test-first [DES-020] (depends on: 2, 3)
- [x] `skills/framing/SKILL.md`: the phase-agnostic procedure, "What a session type supplies", the check × tier table, the XY and symptom/cause checks, the anchor locate/assess/verdict checks and the registry/ADR overlap check [DES-001, DES-002, DES-003, DES-004, DES-005]
- [x] `skills/framing/reference/anchor-contract.md`: location, form, markers and checklist [DES-006]
- [x] `skills/problem-statement/reference/methods.md`: verdicts, rationale, applies-when, Serves and Bugfix columns, Additions and Deferred [DES-013] (depends on: 9)
- [x] `skills/requirements/reference/methods.md`: the same format for the requirements candidates [DES-013]
- [x] `skills/problem-statement/`: `SKILL.md`, `types/feature.md` (tier table, elements, optional templates, examples, owned diagrams), `types/bugfix.md` [DES-011]
- [x] `skills/requirements/reference/diagrams.md`: the catalogue of 4 required and 6 optional diagrams, the traceability-form guidance and the rendering rules, each with an example that renders [DES-017]
- [x] `skills/requirements/` restructured: `SKILL.md` keeps the shared rules and points at `templates/define/requirements.md` and `define/index.md`; `types/feature.md` and `types/bugfix.md` [DES-012] (depends on: 8, 10)
- [x] `skills/requirements/examples/feature-full/`: the worked full-tier password-reset example as a six-file `define/` folder, plus fixture case (c) in `tests/session/check_traceability_test.sh` using it [DES-018, DES-019] (depends on: 1, 9, 10, 11)
- [x] `agents/define.md`: preloads three skills, reads the `framing` block and type files, writes `define/` [DES-010] (depends on: 5, 9, 11)
- [x] `skills/session/SKILL.md`: anchor write in main-loop step 3, gate check a3, new-session step 3 creates `define/index.md`, step d reads the Define artifact as `define/` [DES-009, DES-021] (depends on: 4, 6)
- [x] Ripple: `agents/design.md`, `agents/test.md`, the design, verification, release and log templates, `skills/verification/SKILL.md`, and `close-foldback.md` step 1 point at `define/` with the root fallback; remove `skills/session/templates/requirements.md` [DES-021, DES-008] (depends on: 4, 14)
- [x] `skills/session/reference/close-foldback.md`: the step 2 section-by-section `define/` → Diátaxis mapping, past-session mapping, and the ban on session IDs in as-built docs [DES-023] (depends on: 15)
- [x] `docs/registry/decisions/003-framing-and-project-anchor.md` recording D1–D14, plus its index row [DES-016]
- [x] `docs/explanation/solution-design.md`: full refresh, links to the README anchor, domain map covers every `skills/*` directory [DES-015] (depends on: 5, 9)
- [x] compass-labs `README.md` refresh outside the anchor: plugin name, every skill and agent, the `define/` session row, command prefix as today [DES-014] (depends on: 5, 9)
- [ ] compass-labs `README.md` `## Project anchor` section between the markers, with the vision, mission, scope and non-goals the user approved (anchor writes go through the orchestrator, D1) [DES-014] (depends on: 6, 19)
- [ ] As-built session docs describe the `define/` folder — **deferred to Close** (Close's doc-maintainer pass, not Implement) [DES-022]

## Deviations from design

- **Task 5 (DES-001), `.claude-plugin/marketplace.json`.** The marketplace entry lists skills explicitly (`strict: true`), and `tests/session/marketplace_test.sh` requires the list to match `skills/*/SKILL.md` exactly. The design doesn't name this file, so each new skill (`framing`, later `problem-statement`) is added to the list in the task that creates it. Otherwise a marketplace install wouldn't ship the skill.
- **Order: task 9 before task 7.** The same test fails for a `skills/*/` folder with no `SKILL.md`, so the `problem-statement` skill (task 9) lands before its `reference/methods.md` (task 7). The dependency is swapped in the list above. No content changes.
