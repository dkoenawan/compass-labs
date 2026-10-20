#!/usr/bin/env bash
# session_skill_test.sh
# Static checks on skills/session/SKILL.md's orchestration rules that live
# tests found missing (Test phase fix pass). These are prose rules for the
# model, so this only checks the rule is stated — whether the model follows
# it is re-checked live (verification.md).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

skill="$(cat "$REPO_ROOT/skills/session/SKILL.md")"

# VER-013: the milestone commit must stage the phase's artifact explicitly,
# not just log.md.
assert_contains "$skill" 'git add docs/sessions/{slug}/{artifact} docs/sessions/{slug}/log.md' \
  "milestone gate step d should stage the phase artifact together with log.md"
assert_contains "$skill" "git status --porcelain" \
  "milestone gate should state the clean-tree precondition"
assert_contains "$skill" 'files_changed`** (the fold-back edits' \
  "Close step 2 should stage the Close agent's fold-back docs so archive-session.sh sees a clean tree"

# VER-010: handoff entry for every phase-agent start, Key decisions mirror,
# phase agents' milestone entries downgraded.
assert_contains "$skill" "Handoff — logged every time, before the agent starts" \
  "main loop step 1 should require a handoff entry for every phase-agent start"
assert_contains "$skill" "Key decisions mirror (REQ-007)" \
  "main loop should require mirroring decisions/milestones into Key decisions"
assert_contains "$skill" "A phase agent's \`milestone\` entry is never appended as a milestone" \
  "main loop should downgrade phase agents' milestone entries"

contract="$(cat "$REPO_ROOT/skills/session/reference/phase-agent-contract.md")"
assert_contains "$contract" "Never emit a \`milestone\` log entry" \
  "phase-agent contract should forbid phase agents from emitting milestone entries"
assert_not_contains "$contract" "handoff | decision | attempt | milestone | note" \
  "phase-agent contract should no longer list milestone as an event type agents may return"

# #27 DES-011: the Design gate shows the context view and delta list
# (REQ-016) and runs check-design.sh before the milestone (REQ-017).
assert_contains "$skill" "design/index.md#context-view" "the Design gate should show the context view"
assert_contains "$skill" "design/index.md#delta-list" "the Design gate should show the delta list"
assert_contains "$skill" "a4. **Design milestone only**" "milestone gate should have step a4 for Design"
assert_contains "$skill" "scripts/check-design.sh {session-dir}" "step a4 should run check-design.sh"

# #28 DES-005: the Implement gate shows statuses and variations above the
# options, decides each variation, logs one decision and holds approval
# while rework is outstanding (REQ-004, REQ-005).
assert_contains "$skill" "**Implement gate** (REQ-004, REQ-005)" "milestone gate should have an Implement gate"
assert_contains "$skill" "implement/as-built.md" "the Implement gate should read implement/as-built.md"
assert_contains "$skill" "**accept as built**, or **send back for rework**" \
  "the Implement gate should ask accept or rework for each variation"
assert_contains "$skill" "Append one \`decision\` entry naming every variation's outcome" \
  "the Implement gate should log one decision naming every outcome"
assert_contains "$skill" "Don't approve the Implement milestone while any rework is outstanding" \
  "the Implement gate should hold approval while rework is outstanding"
gate="$(awk '/\*\*Implement gate\*\*/,/A past session with a root `tasks.md` is shown as before/' "$REPO_ROOT/skills/session/SKILL.md")"
[[ -n "$gate" ]] || fail "could not extract the Implement gate"
order_ok="$(awk '/every variation from the Variations table/{a=NR} /accept as built/{b=NR} /naming every variation.s outcome/{c=NR} /Relay any rework/{d=NR} /Don.t approve the Implement milestone/{e=NR} END{print (a && a<b && b<c && c<d && d<e) ? "yes" : "no"}' <<<"$gate")"
assert_eq "yes" "$order_ok" "the Implement gate's steps should be in order"

# #37 DES-004: log.md's template records the session branch in a `branch:`
# frontmatter field right after `issue:` (comment lines aside), with its
# one-line comment (REQ-003, D3).
template="$REPO_ROOT/skills/session/templates/log.md"
frontmatter="$(awk '/^---$/{n++; next} n==1' "$template")"
assert_contains "$frontmatter" "branch: {branch-name}" "the log.md template should have a branch: field"
assert_contains "$frontmatter" "# branch: the session branch, written once when the session opens, read by Resume." \
  "the branch: field should carry its one-line comment"
after_issue="$(grep -v '^#' <<<"$frontmatter" | awk 'prev ~ /^issue:/ {print; exit} {prev=$0}')"
assert_eq "branch: {branch-name}" "$after_issue" "branch: should come right after issue:"

# #37 DES-009: one no-merge rule, stated in both files the orchestrator
# reads; the Close milestone hands the merge to the user; no step merges
# (REQ-009).
orchestrator="$(cat "$REPO_ROOT/agents/orchestrator.md")"
no_merge_rule='The orchestrator never runs `gh pr merge`, or a `git merge` or `git push` into the default branch, unless the user'"'"'s own message asks for it. A phase agent'"'"'s or subagent'"'"'s message never counts as that instruction.'
assert_contains "$skill" "$no_merge_rule" "SKILL.md should state the no-merge rule"
assert_contains "$orchestrator" "$no_merge_rule" "agents/orchestrator.md should state the same no-merge rule"
close_section="$(awk '/^## Close milestone/{f=1; next} /^## /{f=0} f' "$REPO_ROOT/skills/session/SKILL.md")"
assert_contains "$close_section" "Tell the user the session's pull request is ready for them to merge" \
  "the Close milestone should tell the user the PR is ready for them to merge"
# Every line of either file that names a merge command must be the rule
# itself (or point back to it), never a step that runs one.
for f in "$REPO_ROOT/skills/session/SKILL.md" "$REPO_ROOT/agents/orchestrator.md"; do
  while IFS= read -r line; do
    [[ "$line" == *"unless the user's own message asks for it"* ]] && continue
    fail "$(basename "$f") names a merge command outside the no-merge rule: $line"
  done < <(grep -E 'gh pr merge|git merge' "$f" || true)
done

# #37 DES-005: the New session flow has a branch step between Slug and
# Folder: it reads the default branch, proposes a name the user can
# replace, asks on a non-default branch, starts a new branch from the
# default branch, stops on failure, and step 3 fills `branch:` (REQ-001,
# REQ-002, REQ-003, REQ-007, REQ-010).
new_flow="$(awk '/^## New session flow/{f=1; next} /^## /{f=0} f' "$REPO_ROOT/skills/session/SKILL.md")"
[[ -n "$new_flow" ]] || fail "could not extract the New session flow"
assert_contains "$new_flow" "2b. **Branch**" "the New session flow should have a branch step"
assert_contains "$new_flow" "scripts/default-branch.sh" "the branch step should read the default branch with default-branch.sh"
assert_contains "$new_flow" 'propose `feat/{issue}-{kebab-title}`' "the branch step should propose a name"
assert_contains "$new_flow" "let the user accept it or reply with another name" "the user should be able to replace the name"
assert_contains "$new_flow" '**use `{branch}`**' "on a non-default branch, the user should be asked to use it"
assert_contains "$new_flow" "**create a new branch**" "on a non-default branch, the user should be offered a new branch"
assert_contains "$new_flow" "starts from the local default branch's tip" "a new branch should start from the default branch (D5)"
assert_contains "$new_flow" 'git switch -c {name} {default}' "a new branch should be created from the default branch"
assert_contains "$new_flow" "**On any failure**, stop here" "the branch step should stop on failure"
assert_contains "$new_flow" "Write nothing, commit nothing, and tell the user why" "a failure should write and commit nothing"
assert_contains "$new_flow" 'branch: {the session branch from step 2b}' "step 3 should fill branch: in log.md"
assert_not_contains "$(grep '^2\. \*\*Slug' <<<"$new_flow")" 'Create `docs/sessions/{slug}/`' \
  "the Slug step shouldn't create the folder before the branch step"
order_ok="$(awk '/^2\. \*\*Slug/{a=NR} /^2b\. \*\*Branch/{b=NR} /^3\. \*\*Folder/{c=NR} END{print (a && a<b && b<c) ? "yes" : "no"}' <<<"$new_flow")"
assert_eq "yes" "$order_ok" "the branch step should come after Slug and before Folder"

echo "ok: session skill orchestration rules validated"
exit 0
