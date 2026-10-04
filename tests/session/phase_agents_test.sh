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

# phase -> should this agent's tools include Bash? Design is conversational
# but renders and checks its own visuals (#27 D6, DES-014), under a Bash
# rule checked below.
declare -A wants_bash=(
  [define]=no
  [design]=yes
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

# The Design agent (#27 DES-014): preloads the design skill, keeps the
# read-it-yourself fallback, writes design/, has its Bash rule, no TODO.
design_agent="$(cat "$REPO_ROOT/agents/design.md")"
design_frontmatter="$(awk 'NR==1{next} /^---$/{exit} {print}' "$REPO_ROOT/agents/design.md")"
assert_contains "$design_frontmatter" "  - compass-labs:design" \
  "agents/design.md should preload compass-labs:design"
assert_contains "$design_agent" "skills/design/SKILL.md" \
  "agents/design.md should keep the read-SKILL.md-yourself fallback"
assert_contains "$design_agent" "design/" "agents/design.md should write the design/ folder"
assert_contains "$design_agent" "Bash is for rendering and render checks only" \
  "agents/design.md should carry the Bash rule"
assert_contains "$design_agent" "Never run \`git\`" "the Bash rule should forbid git"
assert_contains "$design_agent" "assets/" "the Bash rule should limit outputs to assets/ or a temp directory"
assert_contains "$design_agent" "Never read a past session folder" \
  "agents/design.md should forbid reading past session folders"
assert_not_contains "$design_agent" "TODO" "agents/design.md should have no TODO left"

# Implement reads the new design/ folder, or a past session's design.md (#27 DES-012).
implement_agent="$(cat "$REPO_ROOT/agents/implement.md")"
assert_contains "$implement_agent" "design/index.md" "agents/implement.md should read design/index.md"
assert_contains "$implement_agent" "the root \`design.md\`" "agents/implement.md should still read a past session's design.md"

# Close reads design/ (or a past session's design.md) and folds flagged
# decisions into ADRs (#27 DES-017).
foldback="$(cat "$REPO_ROOT/skills/session/reference/close-foldback.md")"
assert_contains "$foldback" "the frozen \`design/\` folder (or the root \`design.md\` in a past session)" \
  "close-foldback.md step 1 should read design/ or a past session's design.md"
assert_contains "$foldback" "## Folding back \`design/\`" "close-foldback.md should map design/ sections"
assert_contains "$foldback" "Decisions flagged \"ADR\"" "close-foldback.md should turn flagged decisions into ADRs"

# Deploy must refuse to ship an incomplete product (release-completeness check),
# and the Deploy gate + release.md template must carry it through.
assert_contains "$(cat "$REPO_ROOT/agents/deploy.md")" "Never ship an incomplete product" \
  "agents/deploy.md should carry the release-completeness check"
assert_contains "$(cat "$REPO_ROOT/skills/session/templates/release.md")" "## Completeness" \
  "release.md template should have a Completeness section"
assert_contains "$(cat "$REPO_ROOT/skills/session/SKILL.md")" "Deploy milestone only" \
  "SKILL.md's milestone gate should check Completeness before the Deploy milestone"

echo "ok: phase agents validated against feature.json"
exit 0
