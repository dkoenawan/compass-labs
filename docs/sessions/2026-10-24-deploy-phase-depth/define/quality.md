<!-- tier: full -->
# Quality: Deploy phase depth

> Part of [index](index.md) · Define

## Quality coverage (ISO/IEC 25010:2023)

| Characteristic | Covered by | Not applicable because |
|---|---|---|
| Functional suitability | REQ-001, REQ-002, REQ-005, REQ-007, REQ-009, REQ-010, REQ-014, REQ-018, REQ-020 | |
| Performance efficiency | REQ-024 | |
| Compatibility | REQ-001, REQ-012, REQ-013 | |
| Interaction capability | REQ-003, REQ-004, REQ-011, REQ-023 | |
| Reliability | REQ-008, REQ-017, REQ-021, REQ-022 | |
| Security | REQ-006, REQ-022 | |
| Maintainability | REQ-014, REQ-016, REQ-019 | |
| Flexibility | REQ-001, REQ-012, REQ-013 | |
| Safety | | A Deploy run changes software artefacts and hosted services. It can't cause physical, health or environmental harm. The risk of harming a production service is a security and reliability concern, covered above (REQ-006, REQ-008). |

Notes on the coverage:
- Compatibility and Flexibility rest on the declaration being independent of tech stack. That's the anchor scope line "Works in any repository": REQ-001 places no stack in the declaration, and REQ-012 and REQ-013 cover repos whose release runs as its own session or that have nothing to deploy.
- Security here means integrity and accountability. No merge or production-affecting step runs without the user's own instruction (REQ-006), and a published tag is never overwritten (REQ-022).

## NFR measures

| Requirement | Scale | Tolerable | Goal |
|---|---|---|---|
| REQ-024 | minutes from the merge commit landing on compass-labs' default branch to the release tag resolving through `git ls-remote --tags origin` | 30 | 10 |

## Assumptions and dependencies

**Assumptions:**
- The Deploy agent may choose a version bump without asking, by the repo's declared versioning rule (for compass-labs, `CLAUDE.md`'s semver rules), because the user sees the bump and its reason at the Deploy gate and can refuse it there.
- A release record's required depth follows the session's framing tier (REQ-015), so Deploy has no tier proposal of its own.
- compass-labs' release tag follows `claude plugin tag`'s form, `compass-labs--v{version}` (used in the criteria for REQ-019 to REQ-022), as v2.0.0 and v2.2.0 did. v2.1.0's `v2.1.0` is the one exception.
- The repository host can run automation when a pull request is merged into the default branch, and can list published releases.
- Refreshing a local plugin install runs on the user's own machine, out of reach of a remote pipeline. Design confirms this; REQ-023 holds either way.
- Fixture repos stand in for a consuming repo with a real deployment, because none has run Deploy yet (the user, 2026-10-24).

**Dependencies:**
- The GitHub repository `dkoenawan/compass-labs` and its automation for merge events: relied on by REQ-019, REQ-020, REQ-021, REQ-022 and REQ-024.
- `gh`, to mark a PR ready: relied on by REQ-005.
- The session's frozen `design/` artifact, which records deployable parts: relied on by REQ-009 and REQ-010.
- The existing release-completeness check and the Deploy gate in `skills/session/SKILL.md`: relied on by REQ-015 and REQ-017.
- The no-merge rule and ADR-006 (the session branch guard): relied on by REQ-005 and REQ-006.
