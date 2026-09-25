# Requirements: Define phase depth — problem framing, per-type standards, project anchoring

> Phase: Define | Started: 2026-09-25 | Status: Approved (Define complete 2026-09-25)
> Relates to: Issue #23 (absorbs #26 and #32)

## Problem statement

When a session starts, its problem is framed from the issue's wording taken at face value. Nothing checks whether the stated problem is a symptom, a solution chosen too early, or already covered by existing work, so the requirements can be precise about the wrong thing. The guidance that does exist covers only the requirements table and only Feature sessions, even though sessions are expanding to bug fixes and research, which frame problems differently. A project's vision and mission aren't written down anywhere agreed, so there's nothing to check new work against: its purpose either gets restated every session or goes unchecked, and features can drift from it or quietly widen it without anyone deciding that they should.

## Scope

This session covers:

1. **A problem-framing step shared by every session type.** It's defined once, independent of what a workflow calls its phases. Each session type decides what its framing produces.
2. **Framing effort that scales with the size of the work.** There are three depth tiers: full, short and skip. The framing step proposes one, the user confirms it, and the confirmed tier decides which checks run.
3. **Concrete framing for Feature and Bugfix sessions.** For each type: what makes a good problem statement, what makes good requirements (or the Bugfix equivalent), and which standards apply.
4. **An extension point for Research sessions.** It states what a Research type has to supply to plug into the shared framing step. Research framing itself is out of scope (#25).
5. **A standard for each of the two artifact sections: the problem statement, and requirements.** Each standard picks the methods that apply by session type. This takes over #26 (Define phase standard).
6. **Anchoring to the project.**
   - **The anchor contract.** A project anchor is one authoritative, clearly labelled statement of the project's **vision**, **mission** and **scope**, plus its **non-goals** once it has any.
     - Scope is required because the aligns/extends verdict is judged against it.
     - Non-goals are optional because a new project often has none yet. When they exist, they're checked.
     - The anchor lives in the project's persistent docs, where someone new to the project would look first. Any other doc that restates it must agree with it.
     - The anchor is a defined, labelled section, no longer the README and `solution-design.md` read as a whole. The exact file and layout are left to Design.
   - **Create or complete if missing.** When framing finds no anchor, or one that doesn't meet the contract, it drafts the missing parts with the user and, once the user approves them, writes them to the project's persistent docs. This happens once: later sessions reuse the anchor, and the user never has to restate it.
   - **The aligns/extends verdict.** Framing checks new work against the anchor and records whether it **aligns** with it or **extends** it. An "extends" verdict is settled during framing: the anchor update is agreed with the user and applied before the framing milestone is approved.
   - **The registry and ADRs** are checked only for overlap with existing work and conflict with past decisions, not for fit.
7. **The requirements-methodology research from #32, with a fixed boundary:**
   - **Candidates.** Problem-statement methods: the XY problem, SCQ/Minto, the symptom-vs-cause split (Genchi Genbutsu/RCA), 5 Whys, JTBD and PR-FAQ. Requirements methods: EARS, Given/When/Then and the ISO/IEC/IEEE 29148 quality checks. Either artifact section can add at most three more methods, each only when it fills a gap that the named list leaves.
   - **Deliverable.** For every candidate, one recorded verdict for each of Feature and Bugfix: adopt, adapt or reject. Each verdict comes with a one-to-two-sentence rationale and, for adopt and adapt, the condition under which the method applies.
   - **Stopping point.** The research is done when every candidate has a verdict. Anything beyond that becomes a follow-up issue, not more research in this session.
8. **Compass-labs' own anchor, written first.** compass-labs becomes the first project with an anchor written to the contract in item 6. `README.md` and `docs/explanation/solution-design.md` are fully refreshed around it, reflecting the plugin as it currently is: its name, its vision and mission, and every skill and agent it ships. This work is done in Implement.

### Non-goals

- **Reworking or retiring the `plan` skill.** Its discovery half overlaps with Define and its layer design overlaps with Design. Splitting it up is tracked in #27.
- **Setting up the anchor when `init` creates or migrates a project,** for both new and existing projects. That's tracked in #38 (related: #19). This session only covers creating the anchor during framing.
- **Building the Bugfix and Research workflows.** That means their phases, workflow files, agents and GitHub labels. They're tracked in #24 and #25. This session only defines what their framing needs.
- **Framing for any session type other than Feature, Bugfix and Research.**
- **Standards for later phases' artifacts** (Design, Implement, Test, Deploy). They're tracked in #27–#30.
- **Changing Close's fold-back.** Anchor updates happen at framing time, so Close's handling of the README is unchanged.
- **Methods research beyond the boundary in Scope item 7.**
- **Renaming the command prefix.** That's tracked in #34. The README refresh documents the prefix as it currently is.

## Constraints

- **It must work in any consuming repo, not only compass-labs.** The plugin is publicly distributed, so a repo may start with no README, `docs/explanation/`, registry or ADRs, and framing must still work there.
- **The anchor contract can't assume a tech stack, a kind of work, or a particular docs layout.** Compass is a general workflow, not only a tool for full-stack development.
- **The phase-agent contract stays as it is,** including when an anchor is created, completed or updated during framing. A phase agent can't talk to the user directly: questions go through the orchestrator via `needs_input`, it writes only its own artifact, and it never writes `log.md`.
- **The ID and traceability conventions (D1) stay as they are.** Downstream `DES-*`/`VER-*` linking and `check-traceability.sh` must keep working on requirements produced under the new standards.
- **Sessions that already exist, archived or frozen, stay valid.** New standards can't invalidate their artifacts.
- **Each skill has one clear purpose** (CLAUDE.md): one skill per artifact section, not one per method.
- **The #32 research has a fixed limit.** Its candidate list, deliverable and stopping point are fixed as described in Scope item 7.

## Requirements

EARS syntax. Each requirement has one acceptance criterion in Given/When/Then form. IDs are never reused; a dropped requirement is struck through, not deleted.

- **"Framing step"** means the shared problem-framing step from Scope item 1.
- **"Anchor"** means a project's vision, mission, scope and (optional) non-goals, stated once in its persistent docs to the contract in REQ-018.
- **"Session artifact"** means the file the framing step owns in the session folder (for Feature sessions, `requirements.md`).

| ID | Requirement | Acceptance criterion |
|---|---|---|
| REQ-001 | The framing step shall be defined once and name no specific phase, so that any session type's workflow can run it. | Given the framing step's definition, when it's inspected, then no phase name appears in it as a precondition, and the Feature and Bugfix framing guidance both point to this one definition rather than restating it. |
| REQ-002 | The framing step's definition shall list everything a session type must supply to use it: what its framing produces, which standards apply, and which depth tiers it allows. | Given the framing step's definition, when a reviewer tries to set up Research using only that list, then every item Research needs is named, and no part of the framing step's own definition has to change. |
| REQ-003 | When framing starts, the framing step shall propose a depth tier (full, short or skip) with a one-line reason, and use the tier the user confirms. | Given a session whose issue describes a one-line typo fix, when framing starts, then a tier and reason are proposed to the user, and the session artifact records the tier the user confirmed and the reason for it. |
| REQ-004 | The framing standard shall define, for each depth tier, which framing checks run and which artifact sections are required. | Given the framing standard, when it's inspected, then each of full, short and skip lists the checks that run at that tier and the artifact sections that are required, and no check or section is left without a stated tier. |
| REQ-005 | While the confirmed tier is full or short, the framing step shall check whether the stated problem is a solution the user chose in advance rather than the need behind it, and record the outcome. | Given an issue that asks for a specific fix (for example "add a retry flag") without stating the need, when framing runs at full or short tier, then the problem statement names the underlying need, and the requested fix is either confirmed by the user as the need or recorded outside the problem statement as a candidate solution. |
| REQ-006 | While the confirmed tier is full or short, the framing step shall check whether the stated problem is a symptom rather than its cause, and record the outcome. | Given an issue that reports a symptom (for example "the build fails on Mondays"), when framing runs at full or short tier, then the artifact keeps the observed symptom separate from the cause, and either names the cause or records that it's still unknown. |
| REQ-007 | The problem-statement standard shall define, separately for Feature and Bugfix sessions, what a problem statement must contain and which methods apply. | Given the problem-statement standard, when it's inspected, then Feature and Bugfix each have their own required content and their own list of applicable methods, and every listed method has an adopt or adapt verdict under REQ-014 for that session type. |
| REQ-008 | The requirements standard shall define, separately for Feature and Bugfix sessions, what the requirements (or their Bugfix equivalent) must contain and which methods apply. | Given the requirements standard, when it's inspected, then Feature and Bugfix each have their own required content and their own list of applicable methods, and every listed method has an adopt or adapt verdict under REQ-014 for that session type. |
| REQ-009 | The requirements standard shall keep the `REQ-*` ID and table conventions that downstream traceability relies on. | Given a `requirements.md` written under the new standard and a matching `verification.md`, when `check-traceability.sh` runs on the session, then it parses every `REQ-*` and reports the same result it would for a pre-change session with equivalent content. |
| REQ-010 | While the confirmed tier is full or short, the framing step shall record an "aligns" or "extends" verdict against the anchor, citing the anchor's scope (and non-goals, where present) that the verdict rests on. | Given a project whose anchor meets the contract, when framing runs at full or short tier, then the session artifact records exactly one verdict ("aligns" or "extends") and cites the anchor scope or non-goal statements it rests on. |
| REQ-011 | When the framing step records an "extends" verdict, the framing step shall get the anchor update agreed with the user, and the update shall be applied to the anchor before the framing milestone is approved. | Given work judged to extend the project, when the framing milestone gate is reached, then the anchor already contains the update the user agreed, and the milestone can't be approved while the update is missing. |
| ~~REQ-012~~ | ~~If neither anchor file exists, then the framing step shall ask the user for a one-to-two-sentence project purpose, record it in the session's own artifact, and use it in place of the anchor, without creating any project docs.~~ **Dropped 2026-09-25:** replaced by REQ-020 and REQ-021. The user wants the anchor created once, as persistent project docs, rather than a purpose recorded in each session. | — |
| REQ-013 | Where a construct registry or ADRs exist and the confirmed tier is full or short, the framing step shall check them for overlap with existing work and conflict with recorded decisions, and record each overlap or conflict it finds, or that it found none. | Given a repo whose registry lists a construct that does what the new work proposes, when framing runs at full or short tier, then the artifact names that construct as an overlap, and the aligns/extends verdict cites only the anchor, not the registry. |
| REQ-014 | The methods research shall record a verdict (adopt, adapt or reject) for every candidate method in Scope item 7, once for Feature and once for Bugfix, each with a one-to-two-sentence rationale and, for adopt and adapt, the condition under which it applies. | Given the research record, when it's inspected against Scope item 7's candidate list, then every candidate has one verdict each for Feature and Bugfix, every verdict has a rationale, and every adopt or adapt verdict states when it applies. |
| REQ-015 | If a method beyond Scope item 7's named candidates is proposed, then the research shall add it only when it fills a named gap and its artifact section has fewer than three additions, and shall otherwise record it for a follow-up issue. | Given the research record, when it's inspected, then each artifact section has at most three added methods, each naming the gap it fills, and every other method proposed is listed with a follow-up issue number. |
| REQ-016 | The compass-labs `README.md` shall contain, or link to, an anchor for compass-labs that meets the contract in REQ-018, with vision and mission the user has approved, and shall otherwise describe the plugin as it currently is: its current name and every skill and agent it ships. | Given the repo at the end of Implement, when the README is compared with REQ-018, `.claude-plugin/plugin.json`, `skills/*/SKILL.md` and `agents/*.md`, then the anchor it contains or links to passes every REQ-018 check, its vision and mission are the ones the user approved, it uses the plugin's current name and never "Systematic Dev Kit", and every shipped skill and agent has an entry, with none listed that doesn't exist. |
| REQ-017 | The compass-labs `docs/explanation/solution-design.md` shall agree with the compass-labs anchor and describe the system as it currently is, with a domain map covering every skill directory. | Given the repo at the end of Implement, when `solution-design.md` is compared with the anchor and `skills/`, then any vision, mission or scope it states matches the anchor or links to it, it never uses "Systematic Dev Kit", and every `skills/*` directory appears in its domain map. |
| REQ-018 | The anchor contract shall require a project anchor to state, each under its own label and in exactly one authoritative place in the project's persistent docs, the project's vision, mission and scope, plus its non-goals where the project has any. | Given the anchor contract and a project's docs, when a reviewer checks the project against it, then the reviewer can find the single authoritative anchor, and can mark each of vision, mission and scope as present or missing, and non-goals as present or not applicable, without judgement calls about where the anchor is or which statement counts. |
| REQ-019 | Where a project's docs restate any anchor element outside the authoritative anchor, the anchor contract shall require the restatement to match the anchor or link to it. | Given a project whose README restates its mission differently from its anchor, when the project is checked against the anchor contract, then the check fails and names the conflicting restatement. |
| REQ-020 | If framing at full or short tier finds no anchor in the project, then the framing step shall draft a vision, mission, scope and (where the user states any) non-goals with the user, and, once the user approves them, have them written to the project's persistent docs as an anchor that meets the contract, before the framing milestone is approved. | Given a repo with no anchor, when framing runs at full or short tier and the user approves the drafted anchor, then by the framing milestone the project's docs contain an anchor that passes every REQ-018 check, with the user's approved wording. |
| REQ-021 | If framing at full or short tier finds an anchor that doesn't meet the contract, then the framing step shall draft only the missing or failing elements with the user, and, once the user approves them, have them added to the existing anchor before the framing milestone is approved. | Given a repo whose anchor states a vision and mission but no scope, when framing runs at full or short tier and the user approves a drafted scope, then by the framing milestone the anchor passes every REQ-018 check, and its existing vision and mission wording is unchanged. |
| REQ-022 | While a project's anchor meets the contract, the framing step shall use it as it stands and shall not ask the user to restate any anchor element. | Given a repo whose anchor passes every REQ-018 check, when a new session's framing runs, then no question to the user asks for the project's vision, mission, scope or non-goals, and the verdict cites the existing anchor. |

## Open questions

1. **At skip tier, is every framing check skipped, including the anchor checks?** **Resolved 2026-09-25: yes, the user chose to skip everything.** At skip tier, framing skips every check, including the aligns/extends verdict and creating or completing the anchor. A missing anchor is created at the next full- or short-tier session. REQ-005, 006, 010, 013, 020 and 021 already say this, so they're unchanged.

All questions resolved.
