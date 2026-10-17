#!/usr/bin/env bash
# implement_standard_test.sh
# Content assertions for the Implement phase (#28 DES-010): the Implement
# standard and its layer plug-in contract, the backend layer home, the
# implement/ templates, task-executor's design resolution and registry
# read-only rule, the single construct registrar, the Test-owned
# verification boundary, and marketplace.json.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

cleanup_dirs=()
trap 'for d in "${cleanup_dirs[@]:-}"; do rm -rf "$d"; done' EXIT

STANDARD="$REPO_ROOT/skills/implement/SKILL.md"
[[ -f "$STANDARD" ]] || fail "skills/implement/SKILL.md not found"
std="$(cat "$STANDARD")"

# --- 1. The Implement standard (DES-001) ----------------------------------
assert_contains "$std" $'name: implement\n' "the standard should declare name: implement"
for part in "## 1. Tasks" "## 2. Testing boundary" "## 3. As-built record" \
  "## 4. Layer plug-in contract" "## 5. When a layer has no guidance" "## 6. Past sessions"; do
  assert_contains "$std" "$part" "the standard should have part '$part'"
done
assert_contains "$std" "Implement never writes integration, UI or Playwright tests" \
  "the standard should keep integration, UI and Playwright tests out of Implement"
assert_contains "$std" "exactly one status" "every DES item should get exactly one as-built status"
assert_contains "$std" "no Implement guidance for {layer}" "the fallback should record the missing guidance"

# The lookup is the skills/{layer}/ path convention, and the standard lists
# no layers (REQ-014).
assert_contains "$std" '${CLAUDE_PLUGIN_ROOT}/skills/{layer}/reference/implement.md' \
  "the standard should look up skills/{layer}/reference/implement.md"
while IFS= read -r path; do
  [[ "$path" == "skills/session/" ]] || fail "the standard names a specific skill folder: $path"
done < <(grep -oE 'skills/[a-z-]+/' "$STANDARD" | sort -u)
# ("database" is allowed: the test definitions mention a real or shared one.)
for layer in backend frontend infrastructure "AI-agent" "#57" "#58" "#59"; do
  grep -qi -- "$layer" "$STANDARD" && fail "the standard should list no layers (found '$layer')"
done

# A fixture layer is found by the path convention alone, in a temp copy of
# the plugin, with no other file changed.
copy="$(mktemp -d)"
cleanup_dirs+=("$copy")
cp -R "$REPO_ROOT/skills" "$copy/skills"
before="$(cd "$copy" && find skills -type f -exec md5sum {} + | sort)"
mkdir -p "$copy/skills/demo/reference"
echo "# Demo: Implement guidance" >"$copy/skills/demo/reference/implement.md"
template="$(grep -oE '\$\{CLAUDE_PLUGIN_ROOT\}/skills/\{layer\}/reference/implement\.md' "$copy/skills/implement/SKILL.md" | head -1)"
resolved="${template//\$\{CLAUDE_PLUGIN_ROOT\}/$copy}"
resolved="${resolved//\{layer\}/demo}"
[[ -f "$resolved" ]] || fail "the fixture layer's guidance should resolve by the path convention ($resolved)"
after="$(cd "$copy" && find skills -type f ! -path 'skills/demo/*' -exec md5sum {} + | sort)"
assert_eq "$before" "$after" "adding a layer should change no other file"

# --- 2. The backend layer home (DES-004) ----------------------------------
[[ -f "$REPO_ROOT/skills/backend/SKILL.md" ]] || fail "skills/backend/SKILL.md not found"
BACKEND="$REPO_ROOT/skills/backend/reference/implement.md"
[[ -f "$BACKEND" ]] || fail "skills/backend/reference/implement.md not found"
be="$(cat "$BACKEND")"
for section in "## (a) Stack" "## (b) Tests" "## (c) OpenAPI document as built" "## (d) API check against the design"; do
  assert_contains "$be" "$section" "backend guidance should have '$section'"
done
assert_contains "$be" "stack-defaults.md" "backend guidance should link stack-defaults.md"
assert_contains "$be" "Scalar" "backend guidance should render the OpenAPI document with Scalar"
assert_contains "$be" "one row per endpoint" "the API check should have one row per design endpoint"
assert_contains "$be" "dkoenawan/compass-labs#60" "a non-OpenAPI API should cite #60"
assert_contains "$(cat "$REPO_ROOT/skills/backend/SKILL.md")" "reference/implement.md" \
  "skills/backend/SKILL.md should index reference/implement.md"
for layer in frontend database ai-agent infrastructure; do
  [[ -e "$REPO_ROOT/skills/$layer" ]] && fail "skills/$layer/ should not exist yet (no stub folders, ADR-004 D7)"
done

# --- 3. The implement/ templates (DES-002) --------------------------------
TPL="$REPO_ROOT/skills/session/templates/implement"
asbuilt="$(cat "$TPL/as-built.md")"
tasks_tpl="$(cat "$TPL/tasks.md")"
for heading in "## As-built" "## Variations" "## Layer artifacts" "## Handed to Test"; do
  assert_contains "$asbuilt" "$heading" "as-built.md should have '$heading'"
  assert_not_contains "$tasks_tpl" "$heading" "implement/tasks.md should not have '$heading'"
done
grep -qE '^\s*- \[[ x!]\]' "$TPL/as-built.md" && fail "as-built.md should have no checklist lines"
assert_not_contains "$asbuilt" "Deviations from design" "as-built.md should have no Deviations section"
assert_not_contains "$tasks_tpl" "Deviations from design" "implement/tasks.md should have no Deviations section"
assert_contains "$(cat "$REPO_ROOT/skills/session/templates/tasks.md")" "## Deviations from design" \
  "the root tasks.md template stays, unchanged, for past sessions"

# select-next-task.sh on a filled-in implement/tasks.md returns only checklist tasks.
plan="$(mktemp -d)"
cleanup_dirs+=("$plan")
sed -e 's/{first task — no dependencies}/build the store/' \
    -e 's/{second task, last for its item}/build the API/' "$TPL/tasks.md" >"$plan/tasks.md"
next="$(bash "$REPO_ROOT/skills/task-executor/scripts/select-next-task.sh" "$plan/tasks.md")"
assert_eq "1" "$(jq -r '.index' <<<"$next")" "the first checklist task should be selected"
assert_contains "$(jq -r '.text' <<<"$next")" "build the store [DES-" "the selected task should be a checklist line"

# --- 4. task-executor (DES-007) -------------------------------------------
TE="$REPO_ROOT/skills/task-executor/SKILL.md"
te="$(cat "$TE")"
assert_not_contains "$te" "overview.md" "task-executor should not resolve the retired overview.md"
assert_contains "$te" '`$SESSION_DIR/design/index.md`' "task-executor should resolve design/index.md"
assert_contains "$te" '`$SESSION_DIR/design.md`' "task-executor should resolve a past session's root design.md"
assert_contains "$te" "skills/implement/SKILL.md" "task-executor should link the Implement standard's task rule"
assert_contains "$te" '$SESSION_DIR/implement/tasks.md' "task-executor's plan file should be implement/tasks.md"
assert_not_contains "$te" "Post-Task Registry Write" "task-executor should not write the registry after a task"
assert_not_contains "$te" "update registry after task" "task-executor should not commit registry updates"
assert_not_contains "$te" "Write integration test" "task-executor's example should not plan an integration test"
[[ -e "$REPO_ROOT/skills/task-executor/examples/sample-feature/overview.md" ]] \
  && fail "task-executor's example should not use the retired overview.md"

# --- 5. One construct registrar: Close (DES-008, REQ-018) ------------------
foldback="$(cat "$REPO_ROOT/skills/session/reference/close-foldback.md")"
assert_contains "$foldback" "Close is the only phase that registers a session's constructs" \
  "Close's fold-back should own construct registration"
assert_not_contains "$foldback" "the same way \`task-executor\` does" \
  "Close's registry bullet should stand alone"
assert_contains "$foldback" 'run `/compass-labs:post-hook-validator {Name}`' \
  "Close's done note should name each construct to validate"
if hits="$(grep -rnE 'Post-Task Registry Write|update registry after task|registry write step' \
  "$REPO_ROOT/skills" "$REPO_ROOT/agents")"; then
  echo "$hits" >&2
  fail "no skill or agent other than Close should register a session's constructs"
fi
phv="$(cat "$REPO_ROOT/skills/post-hook-validator/SKILL.md")"
assert_contains "$phv" "read \`docs/reference/constructs/<construct-name>.md\` directly" \
  "a named post-hook-validator run should read the construct directly"
assert_contains "$phv" "git log -1 --format=%H -- docs/reference/constructs/" \
  "an unnamed run should use the latest commit that touched a construct"
assert_not_contains "$phv" "No construct files were updated in the last commit" \
  "post-hook-validator should not depend on the last commit"
assert_contains "$phv" "never under \`docs/sessions/archive/\`" \
  "the lockfile should only be written into a live session folder"

# --- 6. Test-owned verification (DES-009) ---------------------------------
ver="$(cat "$REPO_ROOT/skills/verification/SKILL.md")"
for method in '`integration`' '`ui`' '`playwright`' '`inspection`'; do
  assert_contains "$ver" "$method" "the verification skill should name the Test-owned method $method"
done
assert_contains "$ver" "At least one Test-owned row per requirement" "each REQ should need a Test-owned row"
assert_contains "$ver" 'prefixed `Supporting:`' "Implement's tests should be supporting evidence only"
assert_contains "$(cat "$REPO_ROOT/agents/test.md")" "Handed to Test" \
  "the Test agent should read implement/as-built.md's Handed to Test"

# --- 7. Marketplace (DES-001, DES-004) ------------------------------------
listed="$(jq -r '.plugins[] | select(.name=="compass-labs") | .skills[]' "$REPO_ROOT/.claude-plugin/marketplace.json")"
grep -qxF "./skills/implement" <<<"$listed" || fail "marketplace.json should list ./skills/implement"
grep -qxF "./skills/backend" <<<"$listed" || fail "marketplace.json should list ./skills/backend"

echo "ok: Implement phase standard, layer home, templates and boundaries validated"
exit 0
