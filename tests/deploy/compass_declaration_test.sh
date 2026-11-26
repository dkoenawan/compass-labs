#!/usr/bin/env bash
# compass_declaration_test.sh
# compass-labs' own deploy declaration, .claude/deploy.json (#30 DES-011,
# REQ-002, REQ-005, REQ-018, REQ-023): check-declaration.sh reports it
# valid; the four L2 steps (bump, commit, push, PR ready) are routine and
# may run; the merge is production-affecting and waits; the merge-
# triggered pipeline is an L1 part, so no REQ-027 offer fires for it; the
# versioning fields are the ones the starter reads; the proposed tier is
# short; the user's steps after the merge are listed with commands.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

DECL="$REPO_ROOT/.claude/deploy.json"
CHECK="$REPO_ROOT/skills/deploy/scripts/check-declaration.sh"
[[ -f "$DECL" ]] || fail ".claude/deploy.json not found"

out="$(bash "$CHECK" "$REPO_ROOT" --plan 2>&1)"
assert_eq 0 $? "check-declaration.sh should report compass-labs' declaration valid ($out)"
assert_contains "$out" "check-declaration: valid"

# The four L2 steps, in order, routine, and allowed to run.
assert_eq "bump the version|commit the version bump|push the session branch|mark the PR ready" \
  "$(jq -r '[.l2.steps[] | select(.merge != true) | .name] | join("|")' "$DECL")" "the L2 steps should be the four, in order"
assert_eq "routine" "$(jq -r '[.l2.steps[] | select(.merge != true) | .kind] | unique | join(",")' "$DECL")" \
  "the four L2 steps should be routine"
for s in "bump the version" "commit the version bump" "push the session branch" "mark the PR ready"; do
  assert_contains "$(grep -F "'$s'" <<<"$out")" "may run" "'$s' should be allowed to run"
done
assert_contains "$(jq -r '.l2.steps[0].run' "$DECL")" ".github/scripts/bump-version.sh {level}" "the bump should use bump-version.sh"
assert_contains "$(jq -r '.l2.steps[1].run' "$DECL")" "git add .claude-plugin/plugin.json" "the commit should stage by name"
assert_contains "$(jq -r '.l2.steps[1].run' "$DECL")" "#{issue}" "the commit message should reference the issue"
assert_eq "git push -u origin {branch}" "$(jq -r '.l2.steps[2].run' "$DECL")" "the push should be to the session branch"
assert_contains "$(jq -r '.l2.steps[3].run' "$DECL")" "gh pr ready" "the last step should mark the PR ready"
assert_not_contains "$(jq -r '.l2.steps[].run // empty' "$DECL")" "task " "no step should use Taskfile targets"

# The merge is production-affecting and waits.
assert_eq "production_affecting" "$(jq -r '.l2.steps[] | select(.merge == true) | .kind' "$DECL")" \
  "the merge should be production-affecting"
assert_contains "$(grep -F "'merge the pull request'" <<<"$out")" "waits for the user" "the merge should wait"

# The pipeline is a declared L1 part, with a routine, read-only setup.
assert_eq "merge-triggered pipeline" "$(jq -r '.l1.parts[].name' "$DECL")" "the L1 part should be the merge-triggered pipeline"
assert_contains "$(jq -r '.l1.parts[0].setup[0].run' "$DECL")" "gh run list --workflow release.yml --branch {branch} --limit 1"
assert_eq "routine" "$(jq -r '.l1.parts[0].setup[0].kind' "$DECL")" "the pipeline's setup step should be routine"

# Versioning, confirmation, rollback, mode, after the merge.
assert_eq ".claude-plugin/plugin.json|.version|compass-labs--v{version}" \
  "$(jq -r '[.versioning.file, .versioning.field, .versioning.tag] | join("|")' "$DECL")" "versioning should be the starter's values"
assert_contains "$(jq -r '.versioning.rule' "$DECL")" "CLAUDE.md" "the versioning rule should point to CLAUDE.md"
assert_eq "bash .github/scripts/release-tag.sh --check" "$(jq -r '.confirmation.run' "$DECL")" "the confirmation should be release-tag.sh --check"
assert_contains "$(jq -r '.rollback | join(" ")' "$DECL")" "gh pr ready {pr} --undo" "the rollback should un-ready the PR before the merge"
assert_contains "$(jq -r '.rollback | join(" ")' "$DECL")" "never overwritten" "the rollback should say tags are never overwritten"
assert_eq "in_session" "$(jq -r '.release_mode' "$DECL")"
assert_contains "$(jq -r '.after_merge[].run' "$DECL")" "claude plugin update compass-labs@compass-labs" "the cache refresh should be the user's step"

# Tier: short, with L1 or without.
assert_contains "$out" "plan: tier: short"
assert_contains "$out" "plan: tier if L1 runs: short"

echo "ok: compass-labs' deploy declaration checked"
exit 0
