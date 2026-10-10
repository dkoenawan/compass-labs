#!/usr/bin/env bash
# design_notations_test.sh
# Checks skills/design/reference/notations.md (DES-008): the catalogue, the
# delta classDefs, the caption rule and the non-Mermaid route are present, and
# every Mermaid block in the Design standard's example files renders.
#
# Rendering uses mermaid-cli only when it is already available (`mmdc` on PATH,
# or a cached `npx --no-install @mermaid-js/mermaid-cli`). Otherwise the render
# step is skipped with a message, so the harness stays plain bash + jq.
# Rendered output goes only to a temp directory, never into the repo.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

NOTATIONS="$REPO_ROOT/skills/design/reference/notations.md"
[[ -f "$NOTATIONS" ]] || fail "skills/design/reference/notations.md not found"
content="$(cat "$NOTATIONS")"

# --- Static content ------------------------------------------------------

for row in "Three-tier application" "Database layer" "Frontend layer" \
  "Backend layer" "Process/workflow" "Infrastructure" "Plugin/tooling" "Other"; do
  assert_contains "$content" "| $row |" "notation catalogue should have a row for '$row'"
done

for def in \
  "classDef new fill:#DCFCE7,stroke:#166534" \
  "classDef changed fill:#FEF3C7,stroke:#92400E" \
  "classDef deprecated fill:#FEE2E2,stroke:#991B1B,stroke-dasharray:4 3" \
  "classDef unchanged fill:#F1F5F9,stroke:#475569"; do
  assert_contains "$content" "$def" "notations.md should define '$def'"
done

assert_contains "$content" "[status]" "notations.md should describe the [status] label suffix"
assert_contains "$content" "source of truth" "notations.md should make the delta list the source of truth"
assert_contains "$content" "## Captions" "notations.md should have the caption rule"
assert_contains "$content" "requirements/reference/diagrams.md" "notations.md should link Define's rendering rules"
assert_contains "$content" "bpmn-to-image" "notations.md should name the BPMN render tool"
assert_contains "$content" "Export SVG" "notations.md should give the manual BPMN fallback"
assert_contains "$content" "assets/ui-design.zip" "notations.md should document the Claude Design zip"
assert_contains "$content" "--screenshot" "notations.md should document the headless screenshot command"

# Follow-up issues must resolve in a consuming repo: full owner/repo#nn only.
if grep -nE '(^|[^/a-z])#(4[6-9]|5[01])\b' "$NOTATIONS" | grep -v 'compass-labs#' | grep -q .; then
  fail "notations.md should cite follow-up issues as dkoenawan/compass-labs#nn"
fi

# --- Rendering -----------------------------------------------------------

render_files=("$NOTATIONS")
for extra in skills/design/kinds/three-tier.md \
  skills/session/templates/design/index.md skills/session/templates/design/solution.md; do
  [[ -f "$REPO_ROOT/$extra" ]] && render_files+=("$REPO_ROOT/$extra")
done

mmdc_cmd=()
if command -v mmdc >/dev/null 2>&1; then
  mmdc_cmd=(mmdc)
elif command -v npx >/dev/null 2>&1 \
  && npx --no-install @mermaid-js/mermaid-cli --version >/dev/null 2>&1; then
  mmdc_cmd=(npx --no-install @mermaid-js/mermaid-cli)
fi

if [[ ${#mmdc_cmd[@]} -eq 0 ]]; then
  echo "SKIP: mermaid-cli not available; Mermaid blocks not rendered"
  exit 0
fi

# Prefer an installed browser over Puppeteer's own download (see notations.md).
if [[ -z "${PUPPETEER_EXECUTABLE_PATH:-}" ]]; then
  for browser in google-chrome chromium chromium-browser; do
    if command -v "$browser" >/dev/null 2>&1; then
      export PUPPETEER_EXECUTABLE_PATH="$(command -v "$browser")"
      break
    fi
  done
fi

out_dir="$(mktemp -d)"
trap 'rm -rf "$out_dir"' EXIT

for file in "${render_files[@]}"; do
  rel="${file#"$REPO_ROOT"/}"
  if ! log="$("${mmdc_cmd[@]}" -q -i "$file" -o "$out_dir/$(basename "$file")" 2>&1)"; then
    echo "$log" >&2
    fail "Mermaid blocks in $rel do not render with mermaid-cli"
  fi
done

exit 0
