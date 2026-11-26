#!/usr/bin/env bash
# close_scripts_test.sh
# skills/close scripts (ADR-012): findings-index.sh builds a newest-first
# index with type counts from frontmatter; pr-drilldown.sh appends, then
# replaces, a collapsed Drill down section linking only what the branch
# changed, leaving the rest of the PR body alone. gh is a stub.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"
S="$REPO_ROOT/skills/close/scripts"

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT

# --- findings-index.sh ---------------------------------------------------
repo="$work/repo"; mkdir -p "$repo/docs/findings"
mk() { printf -- '---\ndate: %s\ntype: %s\ntitle: %s\npr: %s\n---\n\n# %s\n' "$1" "$2" "$3" "$4" "$3" > "$repo/docs/findings/$1-$5.md"; }
mk 2026-11-20 risk "Offset off by one on page 1" "#5" paging
mk 2026-11-25 trellis "pstack panel needs a second vendor" "#7" panel
mk 2026-11-22 decision "Validate page and size at the boundary" "#6" validate
echo "no frontmatter" > "$repo/docs/findings/notes.md"
out="$(bash "$S/findings-index.sh" "$repo")"
assert_contains "$out" "3 findings" "three findings with frontmatter should be indexed"
idx="$(cat "$repo/docs/findings/index.md")"
assert_contains "$idx" "**1** decision · **1** risk · **0** learning · **1** trellis" "type counts"
first="$(grep -m1 '^| 2026' "$repo/docs/findings/index.md")"
assert_contains "$first" "2026-11-25 | trellis" "newest first"
assert_contains "$idx" "[Offset off by one on page 1](2026-11-20-paging.md) | #5" "rows link the finding and its PR"
bash "$S/findings-index.sh" "$repo" >/dev/null
assert_eq "$idx" "$(cat "$repo/docs/findings/index.md")" "re-running should be idempotent"

# --- pr-drilldown.sh -----------------------------------------------------
git init -q --bare -b main "$work/origin.git"
g="$work/g"; git init -q -b main "$g"; git -C "$g" config user.email t@e.com; git -C "$g" config user.name T
echo a > "$g/README"; git -C "$g" add . && git -C "$g" commit -qm seed
git -C "$g" remote add origin "$work/origin.git"; git -C "$g" push -q origin main
git -C "$g" switch -q -c feat/paging
mkdir -p "$g/docs/briefs" "$g/docs/findings" "$g/docs/trails" "$g/docs/reference"
touch "$g/docs/briefs/2026-11-26-paging.md" "$g/docs/findings/2026-11-26-paging.md" "$g/docs/findings/index.md" "$g/docs/trails/2026-11-26-paging.tsv" "$g/docs/reference/paging.md" "$g/paging.py"
git -C "$g" add . && git -C "$g" commit -qm work

stub="$work/gh"; body_file="$work/body"
printf 'Summary line\n\n## Why\nbecause' > "$body_file"
cat > "$stub" <<STUB
#!/usr/bin/env bash
if [[ "\$1 \$2" == "pr view" ]]; then
  case "\$*" in *baseRefName*) echo main ;; *body*) cat "$body_file" ;; esac
elif [[ "\$1 \$2" == "pr edit" ]]; then
  cat > "$body_file"
fi
STUB
chmod +x "$stub"
(cd "$g" && GH_BIN="$stub" bash "$S/pr-drilldown.sh" 9 "$g") >/dev/null || fail "pr-drilldown should succeed"
b="$(cat "$body_file")"
assert_contains "$b" "Summary line" "the existing summary should stay"
assert_contains "$b" "<details><summary>Drill down</summary>" "the section should be collapsed"
assert_contains "$b" "[\`docs/briefs/2026-11-26-paging.md\`]" "the brief should be linked"
assert_contains "$b" "[\`docs/trails/2026-11-26-paging.tsv\`]" "the trail should be linked"
assert_contains "$b" "[\`docs/reference/paging.md\`]" "touched docs should be linked"
assert_not_contains "$b" "findings/index.md" "the generated index shouldn't be listed"
assert_not_contains "$b" "paging.py" "code files aren't drill-down docs"
(cd "$g" && GH_BIN="$stub" bash "$S/pr-drilldown.sh" 9 "$g") >/dev/null
assert_eq "1" "$(grep -c '<!-- trellis:drilldown -->' "$body_file")" "a re-run should replace, not duplicate, the section"

echo "ok: close scripts validated"
