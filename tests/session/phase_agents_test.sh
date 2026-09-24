#!/usr/bin/env bash
# phase_agents_test.sh
# Validates the six thin phase agents (D4): each exists, its `name:`
# produces an agent_type that matches feature.json's `owner_agent`
# exactly, it references the shared D4 contract instead of duplicating
# it, and its tools match the D4 judgment calls (Bash only where a
# phase actually executes; never Agent/AskUserQuestion, which
# subagents can't use anyway).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

WORKFLOW="$REPO_ROOT/skills/session/workflows/feature.json"
CONTRACT="$REPO_ROOT/skills/session/reference/phase-agent-contract.md"

[[ -f "$CONTRACT" ]] || fail "shared phase-agent-contract.md reference not found"

# phase -> should this agent's tools include Bash?
declare -A wants_bash=(
  [define]=no
  [design]=no
  [implement]=yes
  [test]=yes
  [deploy]=yes
  [close]=yes
)

while IFS=$'\t' read -r phase owner_agent; do
  agent_file="$REPO_ROOT/agents/${phase}.md"
  [[ -f "$agent_file" ]] || fail "agents/${phase}.md not found"

  content="$(cat "$agent_file")"

  # name: <phase> exactly (no colon — that's reserved for the plugin-scoped
  # invocation name, compass-labs:<phase>, which is what feature.json's
  # owner_agent expects to match).
  assert_contains "$content" $'name: '"$phase"$'\n' \
    "agents/${phase}.md should declare name: $phase"

  assert_eq "compass-labs:${phase}" "$owner_agent" \
    "feature.json owner_agent for $phase should be compass-labs:${phase}"

  # References the shared contract instead of duplicating it.
  assert_contains "$content" "phase-agent-contract.md" \
    "agents/${phase}.md should reference the shared D4 contract"

  # Never Agent or AskUserQuestion — subagents can't use AskUserQuestion,
  # and phase agents in this design don't fan out to further subagents.
  assert_not_contains "$content" "AskUserQuestion" \
    "agents/${phase}.md should not grant AskUserQuestion (subagents can't use it)"

  tools_line="$(echo "$content" | grep '^tools:' || true)"
  [[ -n "$tools_line" ]] || fail "agents/${phase}.md has no tools: line"

  if [[ "${wants_bash[$phase]}" == "yes" ]]; then
    assert_contains "$tools_line" "Bash" \
      "agents/${phase}.md should grant Bash (it executes, not just converses)"
  else
    assert_not_contains "$tools_line" "Bash" \
      "agents/${phase}.md (conversational phase) should not need Bash"
  fi
done < <(jq -r '.phases[] | [.phase, .owner_agent] | @tsv' "$WORKFLOW")

echo "ok: phase agents validated against feature.json"
exit 0
