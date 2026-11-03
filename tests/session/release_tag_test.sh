#!/usr/bin/env bash
# release_tag_test.sh
# Component tests for the starter script
# skills/deploy/templates/github/release-tag.sh (#30 DES-008, REQ-019 to
# REQ-022, REQ-028), on a copy filled in with compass-labs' values, against
# a bare local repo as origin and a stub gh: version changed, unchanged,
# tag exists (the tag doesn't move), --check creates nothing, and a
# plain-text VERSION file. Also: an unfilled copy refuses to run, and the
# template names neither compass-labs' repo nor CLAUDE_PLUGIN_ROOT.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

TEMPLATE="$REPO_ROOT/skills/deploy/templates/github/release-tag.sh"
[[ -f "$TEMPLATE" ]] || fail "release-tag.sh template not found"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# --- The template is generic --------------------------------------------
tpl="$(cat "$TEMPLATE")"
assert_not_contains "$tpl" "dkoenawan/compass-labs" "the starter script should not name compass-labs' repo"
assert_not_contains "$tpl" "CLAUDE_PLUGIN_ROOT" "the starter script should not depend on the plugin"
assert_not_contains "$tpl" "compass-labs" "the starter script should not mention compass-labs"
for setting in VERSION_FILE VERSION_FIELD TAG_FORMAT; do
  grep -qE "^${setting}='__${setting}__'$" "$TEMPLATE" || fail "the settings block should hold $setting as a placeholder"
done

# fill <dest> <file> <field> <tag>: copy the template with its settings filled in.
fill() {
  local dest="$1" file="$2" field="$3" tag="$4"
  mkdir -p "$(dirname "$dest")"
  sed -e "s|^VERSION_FILE=.*|VERSION_FILE='$file'|" \
      -e "s|^VERSION_FIELD=.*|VERSION_FIELD='$field'|" \
      -e "s|^TAG_FORMAT=.*|TAG_FORMAT='$tag'|" "$TEMPLATE" >"$dest"
  chmod +x "$dest"
}

# A stub gh: logs every call, and `release create TAG --target SHA` creates
# TAG at SHA in the bare origin, as the real one does.
bin="$work/bin"
mkdir -p "$bin"
cat >"$bin/gh" <<'STUB'
#!/usr/bin/env bash
echo "$*" >>"$GH_STUB_LOG"
if [[ "$1 $2" == "release create" ]]; then
  tag="$3"; sha=""
  shift 3
  while [[ $# -gt 0 ]]; do [[ "$1" == --target ]] && sha="$2"; shift; done
  git --git-dir="$GH_STUB_ORIGIN" tag "$tag" "$sha" || exit 1
fi
exit 0
STUB
chmod +x "$bin/gh"
export PATH="$bin:$PATH"

# new_repo <name>: a work repo with a bare origin. Sets REPO, ORIGIN, GH_STUB_*.
new_repo() {
  ORIGIN="$work/$1-origin.git"
  git init -q --bare "$ORIGIN"
  REPO="$(make_temp_git_repo)"
  git -C "$REPO" remote add origin "$ORIGIN"
  export GH_STUB_ORIGIN="$ORIGIN" GH_STUB_LOG="$work/$1-gh.log"
  : >"$GH_STUB_LOG"
}

# set_json_version <version> [message]: commit plugin.json at <version>, push.
set_json_version() {
  mkdir -p "$REPO/.claude-plugin"
  printf '{\n  "name": "demo",\n  "version": "%s"\n}\n' "$1" >"$REPO/.claude-plugin/plugin.json"
  git -C "$REPO" add .claude-plugin/plugin.json
  git -C "$REPO" commit -q -m "${2:-version $1}"
  git -C "$REPO" push -q origin HEAD:refs/heads/main 2>/dev/null
}

# run_script [args]: sets OUT (stdout+stderr) and STATUS.
run_script() {
  OUT="$(cd "$REPO" && bash .github/scripts/release-tag.sh "$@" 2>&1)"
  STATUS=$?
}

tag_sha() { git --git-dir="$ORIGIN" rev-parse -q --verify "refs/tags/$1^{commit}" 2>/dev/null; }

# --- 1. compass-labs' values: changed, unchanged, tag exists, --check ----
new_repo compass
fill "$REPO/.github/scripts/release-tag.sh" ".claude-plugin/plugin.json" ".version" "compass-labs--v{version}"
git -C "$REPO" add .github && git -C "$REPO" commit -q -m "add script"
set_json_version 2.2.1

# --check before the bump: reports the tag for HEAD's version, creates nothing.
set_json_version 2.3.0 "bump to 2.3.0"
bump_sha="$(git -C "$REPO" rev-parse HEAD)"
run_script --check
assert_eq 0 "$STATUS" "--check should exit 0 ($OUT)"
assert_contains "$OUT" "would create compass-labs--v2.3.0" "--check should report the tag it would create"
[[ -z "$(tag_sha compass-labs--v2.3.0)" ]] || fail "--check should create no tag"
[[ ! -s "$GH_STUB_LOG" ]] || fail "--check should make no gh call (got: $(cat "$GH_STUB_LOG"))"

# Version changed, tag free: one gh release create, tag on HEAD.
run_script
assert_eq 0 "$STATUS" "a changed version should release ($OUT)"
assert_contains "$(cat "$GH_STUB_LOG")" "release create compass-labs--v2.3.0 --target $bump_sha" \
  "the release should be created on HEAD in one gh call"
assert_contains "$(cat "$GH_STUB_LOG")" "--generate-notes" "the release should generate its notes"
assert_eq "$bump_sha" "$(tag_sha compass-labs--v2.3.0)" "the tag should point at the merge commit"

# --check now warns that the tag exists, and still creates nothing.
: >"$GH_STUB_LOG"
run_script --check
assert_eq 0 "$STATUS" "--check should exit 0 even when the tag exists"
assert_contains "$OUT" "already exists" "--check should warn that the tag exists"
[[ ! -s "$GH_STUB_LOG" ]] || fail "--check should make no gh call"

# Version unchanged: logs no version change, no tag, no release.
echo "docs" >"$REPO/README.md"
git -C "$REPO" add README.md && git -C "$REPO" commit -q -m "docs only"
git -C "$REPO" push -q origin HEAD:refs/heads/main 2>/dev/null
tags_before="$(git --git-dir="$ORIGIN" tag | sort)"
run_script
assert_eq 0 "$STATUS" "an unchanged version should exit 0"
assert_contains "$OUT" "no version change" "an unchanged version should be logged"
[[ ! -s "$GH_STUB_LOG" ]] || fail "an unchanged version should make no gh call"
assert_eq "$tags_before" "$(git --git-dir="$ORIGIN" tag | sort)" "an unchanged version should add no tag"

# Tag exists: a second change to 2.3.0 fails, naming the tag, which stays put.
set_json_version 2.2.1 "revert to 2.2.1"
set_json_version 2.3.0 "second 2.3.0"
run_script
assert_eq 1 "$STATUS" "an existing tag should fail the run"
assert_contains "$OUT" "compass-labs--v2.3.0 already exists" "the failure should name the existing tag"
assert_eq "$bump_sha" "$(tag_sha compass-labs--v2.3.0)" "the existing tag should not move"
[[ ! -s "$GH_STUB_LOG" ]] || fail "an existing tag should make no gh call"

# --- 2. A plain-text VERSION file --------------------------------------
new_repo plain
fill "$REPO/.github/scripts/release-tag.sh" "VERSION" "" "v{version}"
echo "1.0.0" >"$REPO/VERSION"
git -C "$REPO" add -A && git -C "$REPO" commit -q -m "1.0.0"
echo "1.1.0" >"$REPO/VERSION"
git -C "$REPO" add VERSION && git -C "$REPO" commit -q -m "1.1.0"
git -C "$REPO" push -q origin HEAD:refs/heads/main 2>/dev/null
run_script
assert_eq 0 "$STATUS" "a plain-text version change should release ($OUT)"
assert_eq "$(git -C "$REPO" rev-parse HEAD)" "$(tag_sha v1.1.0)" "the plain-text version should be tagged v1.1.0"

# --- 3. An unfilled copy refuses to run ---------------------------------
new_repo unfilled
mkdir -p "$REPO/.github/scripts"
cp "$TEMPLATE" "$REPO/.github/scripts/release-tag.sh"
set_json_version 1.0.0
run_script --check
assert_eq 1 "$STATUS" "an unfilled settings block should refuse to run"
assert_contains "$OUT" "settings block" "the refusal should name the settings block"

echo "ok: starter release-tag.sh checked"
exit 0
