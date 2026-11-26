#!/usr/bin/env bash
# release_workflow_test.sh
# The starter workflow, skills/deploy/templates/github/release.yml (#30
# DES-009, REQ-019 to REQ-022, REQ-024, REQ-028): no reference to
# dkoenawan/compass-labs or CLAUDE_PLUGIN_ROOT; both triggers; the pull-
# request job runs --check with contents: read, the push job runs the
# script with contents: write on the default branch only, both with
# fetch-depth 2; no secret beyond GITHUB_TOKEN; no push to a branch; the
# only action used is actions/checkout.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

WF="$REPO_ROOT/skills/deploy/templates/github/release.yml"
[[ -f "$WF" ]] || fail "release.yml template not found"
w="$(cat "$WF")"

assert_not_contains "$w" "dkoenawan/compass-labs" "the starter workflow should not name compass-labs' repo"
assert_not_contains "$w" "CLAUDE_PLUGIN_ROOT" "the starter workflow should not depend on the plugin"

# Both triggers.
grep -qE '^  push:' "$WF" || fail "the workflow should trigger on push"
grep -qE '^  pull_request:' "$WF" || fail "the workflow should trigger on pull_request"

# job_block <name>: the lines of one job.
job_block() { awk -v j="  $1:" '$0==j{on=1; print; next} on && /^  [a-z_-]+:$/{exit} on' "$WF"; }

check="$(job_block check)"
assert_contains "$check" "if: github.event_name == 'pull_request'" "the check job should run on pull requests"
assert_contains "$check" "contents: read" "the check job should only read"
assert_not_contains "$check" "contents: write" "the check job should not write"
assert_contains "$check" "run: bash .github/scripts/release-tag.sh --check" "the check job should run --check"
assert_contains "$check" "fetch-depth: 2" "the check job should fetch HEAD^1"

release="$(job_block release)"
assert_contains "$release" "github.event_name == 'push'" "the release job should run on push"
assert_contains "$release" "github.ref_name == github.event.repository.default_branch" "the release job should run on the default branch only"
assert_contains "$release" "contents: write" "the release job should be able to create the tag and release"
assert_contains "$release" "run: bash .github/scripts/release-tag.sh"$'\n' "the release job should run the script with no argument"
assert_contains "$release" "fetch-depth: 2" "the release job should fetch HEAD^1"

# Workflow-level permissions are empty; each job asks for its own.
grep -qE '^permissions: \{\}$' "$WF" || fail "the workflow should grant no permissions by default"

# No secret beyond GITHUB_TOKEN, no push, only actions/checkout.
if grep -oE 'secrets\.[A-Za-z_]+' "$WF" | grep -v '^secrets\.GITHUB_TOKEN$' | grep -q .; then
  fail "the workflow should use no secret beyond GITHUB_TOKEN"
fi
grep -qE 'git push' "$WF" && fail "the workflow should push to no branch"
uses="$(grep -oE 'uses: [^ ]+' "$WF" | sed 's/uses: //; s/@.*//' | sort -u)"
assert_eq "actions/checkout" "$uses" "the only action used should be actions/checkout"

# It parses as YAML, where a parser is available.
if python3 -c 'import yaml' 2>/dev/null; then
  python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))' "$WF" || fail "release.yml should be valid YAML"
fi

echo "ok: starter release.yml checked"
exit 0
