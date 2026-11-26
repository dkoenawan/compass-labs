#!/usr/bin/env bash
# models_template_test.sh
# Checks the subscription-safe pstack model roles template (ADR-011, #98):
# every role pstack's setup-pstack writes is present, every model is a
# Claude subscription model (opus, sonnet, haiku, or the inherit-parent/auto
# aliases), never fable or another vendor, and no effort is above high.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

TEMPLATE="$REPO_ROOT/docs/reference/pstack/pstack-models.md"
[[ -f "$TEMPLATE" ]] || fail "docs/reference/pstack/pstack-models.md not found"

content="$(cat "$TEMPLATE")"

# No frontmatter: Claude Code loads ~/.claude/rules/*.md as-is, and
# pstack's Claude Code adapter says to write the file without it.
first_line="$(head -n1 "$TEMPLATE")"
[[ "$first_line" != "---" ]] || fail "template must not start with frontmatter"

assert_contains "$content" "# defaults: 3" "template must carry pstack's '# defaults: 3' line"
assert_contains "$content" "# budget: medium (high)" "template must record the medium budget"

# Every role setup-pstack writes (pstack 0.15.48, step 5).
roles=(
  "feature, refactoring"
  "bug-fix"
  "perf-issue"
  "hillclimb"
  "judgment and prose"
  "arena runners"
  "arena cross-judge pool"
  "swarm workers"
  "interrogate reviewers"
)
for role in "${roles[@]}"; do
  grep -q "^${role}: " "$TEMPLATE" || fail "role line missing: '$role'"
done

# Check every value on every role line.
role_lines=0
while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  role_lines=$((role_lines + 1))
  value="${line#*: }"
  IFS=',' read -r -a entries <<<"$value"
  for entry in "${entries[@]}"; do
    entry="$(echo "$entry" | xargs)"
    case "$entry" in
      inherit-parent|auto) continue ;;
    esac
    model="${entry%% *}"
    effort="${entry##* }"
    case "$model" in
      opus|sonnet|haiku) ;;
      *) fail "role '${line%%:*}' uses '$model': only opus, sonnet, haiku, inherit-parent or auto are subscription-safe" ;;
    esac
    case "$effort" in
      low|medium|high) ;;
      *) fail "role '${line%%:*}' entry '$entry' has effort '$effort': nothing above high" ;;
    esac
  done
done <"$TEMPLATE"

assert_eq "${#roles[@]}" "$role_lines" "template should hold exactly one line per pstack role"

# Belt and braces: the unsafe families never appear in a role value.
if grep -v '^#' "$TEMPLATE" | grep -Eqi 'fable|gemini|gpt|grok|claude-'; then
  fail "a role line names fable, another vendor, or a raw Cursor slug"
fi

echo "models_template_test: ok"
