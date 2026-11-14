---
name: DeployStandard
type: Component
layer: Shared
file: skills/deploy/SKILL.md
status: built
planned_in: null
last_verified: null
---

# DeployStandard

> Origin: #30

## Does

Defines what a repo's deploy declaration (`.claude/deploy.json`) states, which declared steps the Deploy phase may run and in what order, when L1 deployment setup is needed, the Deploy tiers and the release record's sections, and the frameworks behind each section. Holds the declaration offer used at project initiation and the `starter` mode. It does NOT validate a declaration (DeclarationCheck does), check a release record at the gate (ReleaseRecordCheck does), copy the starter (StarterInstaller does), or supply any repo's deploy commands.

## Functional Requirements

- [ ] Given the standard alone, a reviewer can write a declaration for a service with a staging and a production target, with a named place for each of the seven items (L1 setup per part, L2 steps, routine steps, production-affecting steps, confirmation, rollback, release mode).
- [ ] With no declaration, Deploy runs no command from the repo, changes no file outside the session folder, and returns `blocked` naming the declaration and where the standard describes it.
- [ ] A declaration missing a required item stops Deploy before any step, naming the item.
- [ ] Routine steps run without a question, the version bump chosen by the declared rule with its reason recorded; a production-affecting step doesn't run and is recorded as waiting for the user's instruction.
- [ ] The declared confirmation check runs after the steps and is recorded with its output; a failed check records the failure and the declared rollback, and Deploy returns `blocked`.
- [ ] A new or changed deployable part the declaration covers has its setup run before L2 and is recorded as L1; a session that changes no deployable part records "L1: not needed" and runs only L2.
- [ ] A deployable part the declaration doesn't cover triggers one offer with the drafted entry; a yes adds it and runs its setup, a no runs nothing, leaves the declaration unchanged and names the part.
- [ ] With `own_session`, no release step runs and the record says the change waits for a release session; with `none`, nothing runs and the record says "nothing to deploy, per the declaration".
- [ ] The release-completeness check runs before any L1 or L2 step.
- [ ] The tier table gives each tier's risk and, for each of the seven sections, whether it's required at that tier; each section names a framework with an adopt, adapt or reject verdict.
- [ ] Deploy proposes the tier from the release's risk, independent of the framing tier, and records it with a one-line reason.
- [ ] The declaration offer is skipped when a declaration exists; "later" writes nothing; "nothing to deploy" writes `{"deployment": "none"}`; the starter is offered only after "declare now" on a GitHub `origin` and installed only on a yes.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/session/deploy_standard_test.sh

## Interface

```text
Preloaded by:  agents/deploy.md   (skills: compass-labs:deploy)
Invoked as:    /compass-labs:deploy starter   (or a request in words for the starter)
Sections:      1 lifecycles · 2 declaration · 3 execution rules · 4 L1 rule · 5 tiers
               6 release session · 7 frameworks · 8 declaration offer · 9 starter mode
Reference:     skills/deploy/reference/declaration.md (fields, placeholders, examples)
               skills/deploy/reference/frameworks.md  (verdict per section)
Reads:         {repo}/.claude/deploy.json, the session's design/index.md delta list
Record:        skills/session/templates/release.md
```

## Dependencies

- Calls: DeclarationCheck, StarterInstaller (offer and starter mode, on a yes)
- Called by: `agents/deploy.md`; `skills/init/SKILL.md` (Steps 6b, 8b); `skills/session/SKILL.md` (one-time setup step 3)
- Reads: the repo's `.claude/deploy.json`; the session's frozen design
- Writes: `.claude/deploy.json` (offer, on the user's answer); the session's `release.md` (through the Deploy agent)

## Patterns Applied

- [Deploy runs what the repo declares, and nothing else](../../registry/patterns.md#deploy-runs-what-the-repo-declares-and-nothing-else)
- [Never ship an incomplete product](../../registry/patterns.md#never-ship-an-incomplete-product)
- [Session work reaches the default branch only through a pull request](../../registry/patterns.md#session-work-reaches-the-default-branch-only-through-a-pull-request)
- [Hooks fail open](../../registry/patterns.md#hooks-fail-open)

## Key Decisions

- [ADR-007](../../registry/decisions/007-deploy-declaration.md): the declaration and when it's offered.
- [ADR-008](../../registry/decisions/008-deploy-runs-declared-steps.md): Deploy runs declared steps; scripts for what's mechanical; risk-based tiers; the starter.
