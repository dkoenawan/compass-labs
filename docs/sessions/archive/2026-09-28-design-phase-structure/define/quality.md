<!-- tier: full -->
# Quality: Design phase structure, with layered design skills and visual deltas

> Part of [index](index.md) · Define

## Quality coverage (ISO/IEC 25010:2023)

| Characteristic | Covered by | Not applicable because |
|---|---|---|
| Functional suitability | REQ-001, REQ-004, REQ-007, REQ-011, REQ-012, REQ-018, REQ-019, REQ-032, REQ-035, REQ-038 | |
| Performance efficiency | | The Design path adds no runtime component. It is guidance an agent follows, plus orchestrator checks that read one Markdown file, so no response time or resource budget is at stake. |
| Compatibility | REQ-006, REQ-009, REQ-014, REQ-024, REQ-033 | |
| Interaction capability | REQ-014, REQ-016 | |
| Reliability | REQ-017, REQ-035 | |
| Security | | The work adds no credentials, no network access and no data handling. It changes Markdown guidance and a gate check inside the user's own repository. |
| Maintainability | REQ-003, REQ-005, REQ-010, REQ-021, REQ-022, REQ-023, REQ-037, REQ-038 | |
| Flexibility | REQ-002, REQ-003, REQ-005, REQ-008, REQ-009, REQ-032, REQ-036 | |
| Safety | | Designing software in a session can't cause physical, health or environmental harm. |

## NFR measures

| Requirement | Scale | Tolerable | Goal |
|---|---|---|---|
| REQ-014 | Visuals in a design artifact that display as source text instead of a diagram when the file is opened on github.com, counted by hand at the Design gate | 0 | 0 |

The other requirements are functional: each acceptance criterion states its result directly, with no scale.

## Assumptions and dependencies

**Assumptions:**
- A repository's established stack can be recognised from its files (manifests, lockfiles, schema files) without running it. A repo with an unusual layout may need the user to name its stack.
- GitHub keeps rendering Mermaid in Markdown and SVG images linked from Markdown, as it does today.
- The session's user approves the Design phase in one sitting per gate, as with Define. No partial-approval flow is needed.
- One primary solution kind chooses the depth path. The scope checklist (REQ-001) catches the other areas a solution touches, for example a three-tier app with an infrastructure change, so no second kind is needed (user decision).
- Three-tier designs need no non-Mermaid visual, because C4 views render as Mermaid. A render route for non-Mermaid sources only has to be documented this session (REQ-015); it doesn't have to run.
- Claude Design can take a written handoff and return a visual design the session can reference, such as a link or an exported file. No API integration is assumed.
- Terraform is a sensible infrastructure default for a repo with no established infrastructure stack, consistent with #20.
- What Close folds into the project documentation is the still-true part of a session. Anything Design needs from an earlier session, and that is still true, is in the docs or in the code (ADR-003 D14).
- The Design agent's tool calls can be inspected after the phase, from the session transcript or hook logs, so OUT-05 and REQ-035's criterion can be checked.
- KISS, YAGNI and SOLID are applied as named, established principles, not new methods. KISS and YAGNI apply to every solution kind; SOLID applies only to software elements, where its terms mean something.

**Dependencies:**
- A documented route from a non-Mermaid visual source (for example BPMN XML) to an SVG: relied on by REQ-015. The Design agent's tools today are Read, Glob, Grep, Write and Edit, with no Bash (see [Open questions](index.md#open-questions)).
- Claude Design (claude.ai), an external service: relied on by REQ-033.
- #20 (cloud-agnostic Terraform scaffolding) agreeing with the Terraform default: relied on by REQ-008 and REQ-010.
- The Close phase folding sessions back into the Diátaxis docs: relied on by REQ-035, since the docs are Design's only source of prior knowledge. #45 (Close doesn't fold back when those trees are missing) leaves such repos with nothing to read, which is why REQ-036's fallback exists.
- #28 (Implement-phase layer skills) agreeing to the per-layer home: relied on by REQ-006.
- The frontend, backend and database sub-issues (Deferred REQ-025 to REQ-027) for the layers' in-depth designs: they rely on REQ-004 and REQ-005's contracts, not the other way round.
- The guard hook (`hooks/session-guard.sh`) allowing non-Markdown files in `assets/`, as it does today: relied on by REQ-015.
- The orchestrator's milestone gate (`skills/session/SKILL.md`): relied on by REQ-016 and REQ-017.
- `check-traceability.sh` and the guard's current behaviour on past sessions: relied on by REQ-024.
