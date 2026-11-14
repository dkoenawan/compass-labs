---
name: DeclarationCheck
type: Utility
layer: Shared
file: skills/deploy/scripts/check-declaration.sh
status: built
planned_in: null
last_verified: null
---

# DeclarationCheck

> Origin: #30

## Does

Validates a repo's `.claude/deploy.json` against the Deploy standard and, with `--plan`, prints in declared order which steps may run and which wait for the user, the release mode and the proposed tier. Reads the file only. It does NOT run any command from the repo, choose the bump level, or decide whether L1 is needed (the Deploy agent does).

## Functional Requirements

- [ ] A repo with no `.claude/deploy.json` reports "no declaration" and exits 2, saying how to declare one.
- [ ] A declaration missing a required item names each one (for example "missing: rollback") and exits 1.
- [ ] A step with `merge: true` marked routine is reported as invalid, naming the step.
- [ ] When `versioning.file` is set, a missing file is named; a `versioning.tag` without `{version}` is named.
- [ ] `{"deployment": "none"}` exits 3, and `--plan` gives the skip tier.
- [ ] `--plan` never lists a production-affecting step as "may run", and every step after the first waiting one waits too, L1 before L2.
- [ ] `--plan` prints `tier:` and `tier if L1 runs:` matching the standard's tier table; `own_session` shows L2 as waiting for a release session.
- [ ] Without `jq` it warns, checks nothing and exits 4.
- [ ] No command from the repo runs in any mode.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/session/check_declaration_test.sh, tests/session/check_declaration_plan_test.sh

## Interface

```text
check-declaration.sh <repo-root> [--plan]
exit 0 valid · 1 invalid · 2 no declaration · 3 none · 4 no jq
jq rules: skills/deploy/scripts/lib/validate.jq, lib/plan.jq
```

## Dependencies

- Calls: `jq`
- Called by: `agents/deploy.md` (step 1, and after writing an offered entry); DeployStandard's declaration offer; StarterInstaller
- Reads: `{repo}/.claude/deploy.json`, the `versioning.file` it names (existence only)
- Writes: (none)

## Patterns Applied

- [Deploy runs what the repo declares, and nothing else](../../registry/patterns.md#deploy-runs-what-the-repo-declares-and-nothing-else)
- [Hooks fail open](../../registry/patterns.md#hooks-fail-open)

## Key Decisions

- [ADR-007](../../registry/decisions/007-deploy-declaration.md): the declaration's shape.
- [ADR-008](../../registry/decisions/008-deploy-runs-declared-steps.md): what may run is decided by a script, not only a prompt.
