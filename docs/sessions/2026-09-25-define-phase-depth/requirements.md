# Requirements: Define phase depth — problem framing, per-type standards, project anchoring

> Phase: Define | Started: 2026-09-25 | Status: Draft (ready for Define milestone review)
> Relates to: Issue #23 (absorbs #26 and #32)

## Problem statement

When a session starts, its problem is framed from the issue's wording taken at face value. Nothing checks whether the stated problem is a symptom, a solution chosen too early, or already covered by existing work, so the requirements can be precise about the wrong thing. The guidance that does exist covers only the requirements table and only Feature sessions, even though sessions are expanding to bug fixes and research, which frame problems differently. Nothing checks new work against what the project says it is for either, so features can drift from the project's stated purpose, or quietly widen it, without anyone deciding that they should.

## Scope

This session covers:

1. **A problem-framing step shared by every session type.** It's defined once, independent of what a workflow calls its phases. Each session type decides what its framing produces.
2. **Framing effort that scales with the size of the work.** There are three depth tiers: full, short and skip. The framing step proposes one, the user confirms it, and the confirmed tier decides which checks run.
3. **Concrete framing for Feature and Bugfix sessions.** For each type: what makes a good problem statement, what makes good requirements (or the Bugfix equivalent), and which standards apply.
4. **An extension point for Research sessions.** It states what a Research type has to supply to plug into the shared framing step. Research framing itself is out of scope (#25).
5. **A standard for each of the two artifact sections: the problem statement, and requirements.** Each standard picks the methods that apply by session type. This takes over #26 (Define phase standard).
6. **Anchoring to the project.**
   - **The anchor** is the README plus `docs/explanation/solution-design.md`. Framing checks new work against it and records one of two verdicts: the work **aligns** with the anchor, or it **extends** it.
   - **An "extends" verdict is settled during framing, before anything is built.** The framing step gets the anchor update agreed with the user, and the update is applied before the framing milestone is approved.
   - **The registry and ADRs** are checked only for overlap with existing work and conflict with past decisions, not for fit.
   - **If a repo has no anchor,** the framing step asks the user for a one-to-two-sentence project purpose and records it in the session's own artifact. It never creates project docs.
7. **The requirements-methodology research from #32, with a fixed boundary:**
   - **Candidates.** Problem-statement methods: the XY problem, SCQ/Minto, the symptom-vs-cause split (Genchi Genbutsu/RCA), 5 Whys, JTBD and PR-FAQ. Requirements methods: EARS, Given/When/Then and the ISO/IEC/IEEE 29148 quality checks. Either artifact section can add at most three more methods, each only when it fills a gap that the named list leaves.
   - **Deliverable.** For every candidate, one recorded verdict for each of Feature and Bugfix: adopt, adapt or reject. Each verdict comes with a one-to-two-sentence rationale and, for adopt and adapt, the condition under which the method applies.
   - **Stopping point.** The research is done when every candidate has a verdict. Anything beyond that becomes a follow-up issue, not more research in this session.
8. **A full refresh of compass-labs' own anchor.** `README.md` and `docs/explanation/solution-design.md` are brought up to date with the plugin as it currently is: its name, its purpose, and every skill and agent it ships. The refresh is done in Implement.

### Non-goals

- **Reworking or retiring the `plan` skill.** Its discovery half overlaps with Define and its layer design overlaps with Design. Splitting it up is tracked in #27.
- **Building the Bugfix and Research workflows.** That means their phases, workflow files, agents and GitHub labels. They're tracked in #24 and #25. This session only defines what their framing needs.
- **Framing for any session type other than Feature, Bugfix and Research.**
- **Standards for later phases' artifacts** (Design, Implement, Test, Deploy). They're tracked in #27–#30.
- **Changing Close's fold-back.** Anchor updates happen at framing time, so Close's handling of the README is unchanged.
- **Methods research beyond the boundary in Scope item 7.**
- **Renaming the command prefix.** That's tracked in #34. The README refresh documents the prefix as it currently is.

## Constraints

- **It must work in any consuming repo, not only compass-labs.** The plugin is publicly distributed, so a repo may lack a README, `docs/explanation/`, the registry or ADRs, and the framing must still work there.
- **The phase-agent contract stays as it is,** including when an anchor update is made during framing. A phase agent can't talk to the user directly: questions go through the orchestrator via `needs_input`, it writes only its own artifact, and it never writes `log.md`.
- **The ID and traceability conventions (D1) stay as they are.** Downstream `DES-*`/`VER-*` linking and `check-traceability.sh` must keep working on requirements produced under the new standards.
- **Sessions that already exist, archived or frozen, stay valid.** New standards can't invalidate their artifacts.
- **Each skill has one clear purpose** (CLAUDE.md): one skill per artifact section, not one per method.
- **The #32 research has a fixed limit.** Its candidate list, deliverable and stopping point are fixed as described in Scope item 7.

## Requirements

EARS syntax. Each requirement has one acceptance criterion in Given/When/Then form. IDs are never reused; a dropped requirement is struck through, not deleted.

"Framing step" means the shared problem-framing step from Scope item 1. "Anchor" means the README plus `docs/explanation/solution-design.md` of the repo the session runs in, whichever of the two exist.

| ID | Requirement | Acceptance criterion |
|---|---|---|
| REQ-001 | The framing step shall be defined once and name no specific phase, so that any session type's workflow can run it. | Given the framing step's definition, when it's inspected, then no phase name appears in it as a precondition, and the Feature and Bugfix framing guidance both point to this one definition rather than restating it. |
| REQ-002 | The framing step's definition shall list everything a session type must supply to use it: what its framing produces, which standards apply, and which depth tiers it allows. | Given the framing step's definition, when a reviewer tries to set up Research using only that list, then every item Research needs is named, and no part of the framing step's own definition has to change. |
| REQ-003 | When framing starts, the framing step shall propose a depth tier (full, short or skip) with a one-line reason, and use the tier the user confirms. | Given a session whose issue describes a one-line typo fix, when framing starts, then a tier and reason are proposed to the user, and the session's artifact records the tier the user confirmed and the reason for it. |
| REQ-004 | The framing standard shall define, for each depth tier, which framing checks run and which artifact sections are required. | Given the framing standard, when it's inspected, then each of full, short and skip lists the checks that run at that tier and the artifact sections that are required, and no check or section is left without a stated tier. |
| REQ-005 | While the confirmed tier is full or short, the framing step shall check whether the stated problem is a solution the user chose in advance rather than the need behind it, and record the outcome. | Given an issue that asks for a specific fix (for example "add a retry flag") without stating the need, when framing runs at full or short tier, then the problem statement names the underlying need, and the requested fix is either confirmed by the user as the need or recorded outside the problem statement as a candidate solution. |
| REQ-006 | While the confirmed tier is full or short, the framing step shall check whether the stated problem is a symptom rather than its cause, and record the outcome. | Given an issue that reports a symptom (for example "the build fails on Mondays"), when framing runs at full or short tier, then the artifact keeps the observed symptom separate from the cause, and either names the cause or records that it's still unknown. |
| REQ-007 | The problem-statement standard shall define, separately for Feature and Bugfix sessions, what a problem statement must contain and which methods apply. | Given the problem-statement standard, when it's inspected, then Feature and Bugfix each have their own required content and their own list of applicable methods, and every listed method has an adopt or adapt verdict under REQ-014 for that session type. |
| REQ-008 | The requirements standard shall define, separately for Feature and Bugfix sessions, what the requirements (or their Bugfix equivalent) must contain and which methods apply. | Given the requirements standard, when it's inspected, then Feature and Bugfix each have their own required content and their own list of applicable methods, and every listed method has an adopt or adapt verdict under REQ-014 for that session type. |
| REQ-009 | The requirements standard shall keep the `REQ-*` ID and table conventions that downstream traceability relies on. | Given a `requirements.md` written under the new standard and a matching `verification.md`, when `check-traceability.sh` runs on the session, then it parses every `REQ-*` and reports the same result it would for a pre-change session with equivalent content. |
| REQ-010 | Where an anchor exists and the confirmed tier is full or short, the framing step shall record an "aligns" or "extends" verdict, citing the anchor passages the verdict rests on. | Given a repo with a README and `solution-design.md`, when framing runs at full or short tier, then the artifact records exactly one verdict ("aligns" or "extends") and quotes or links the anchor passages it rests on. |
| REQ-011 | When the framing step records an "extends" verdict, the framing step shall get the anchor update agreed with the user, and the update shall be applied to the anchor before the framing milestone is approved. | Given work judged to extend the project, when the framing milestone gate is reached, then the anchor already contains the update the user agreed, and the milestone can't be approved while the update is missing. |
| REQ-012 | If neither anchor file exists, then the framing step shall ask the user for a one-to-two-sentence project purpose, record it in the session's own artifact, and use it in place of the anchor, without creating any project docs. | Given a repo with no README and no `solution-design.md`, when framing runs at full or short tier, then the user is asked for a project purpose, the session artifact records the purpose and the verdict against it, and no file outside the session folder has been created. |
| REQ-013 | Where a construct registry or ADRs exist and the confirmed tier is full or short, the framing step shall check them for overlap with existing work and conflict with recorded decisions, and record each overlap or conflict it finds, or that it found none. | Given a repo whose registry lists a construct that does what the new work proposes, when framing runs at full or short tier, then the artifact names that construct as an overlap, and the aligns/extends verdict cites only anchor passages, not the registry. |
| REQ-014 | The methods research shall record a verdict (adopt, adapt or reject) for every candidate method in Scope item 7, once for Feature and once for Bugfix, each with a one-to-two-sentence rationale and, for adopt and adapt, the condition under which it applies. | Given the research record, when it's inspected against Scope item 7's candidate list, then every candidate has one verdict each for Feature and Bugfix, every verdict has a rationale, and every adopt or adapt verdict states when it applies. |
| REQ-015 | If a method beyond Scope item 7's named candidates is proposed, then the research shall add it only when it fills a named gap and its artifact section has fewer than three additions, and shall otherwise record it for a follow-up issue. | Given the research record, when it's inspected, then each artifact section has at most three added methods, each naming the gap it fills, and every other method proposed is listed with a follow-up issue number. |
| REQ-016 | The compass-labs `README.md` shall describe the plugin as it currently is: its current name, a purpose statement the user has approved, and every skill and agent the plugin ships. | Given the repo at the end of Implement, when the README is compared with `.claude-plugin/plugin.json`, `skills/*/SKILL.md` and `agents/*.md`, then it uses the plugin's current name and never "Systematic Dev Kit", its purpose statement is the one the user approved, and every shipped skill and agent has an entry, with none listed that doesn't exist. |
| REQ-017 | The compass-labs `docs/explanation/solution-design.md` shall describe the system as it currently is: the same approved purpose statement as the README, and a domain map covering every skill directory. | Given the repo at the end of Implement, when `solution-design.md` is compared with the README and `skills/`, then its purpose matches the README's approved statement, it never uses "Systematic Dev Kit", and every `skills/*` directory appears in its domain map. |

## Open questions

All questions resolved. The four framing questions from this phase are settled in Scope items 2, 6 and 8.
