#!/usr/bin/env bash
# install_starter_test.sh
# Component tests for skills/deploy/scripts/install-starter.sh (#30
# DES-015, REQ-028), on temp copies of tests/fixtures/deploy/
# fixture-service: a GitHub origin writes both files with fixture-
# service's values and no dkoenawan/compass-labs in either; a non-GitHub
# origin writes nothing; an existing workflow file is left byte for byte
# unchanged; a missing versioning.tag is named; no declaration writes
# nothing; the declaration itself is never changed.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/deploy/scripts/install-starter.sh"
FIX="$REPO_ROOT/tests/fixtures/deploy"
TPL="$REPO_ROOT/skills/deploy/templates/github"
[[ -x "$SCRIPT" ]] || fail "install-starter.sh not found or not executable"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# repo_copy <fixture> <origin-url or "">: a temp git repo copy; prints its path.
repo_copy() {
  local dir="$work/$1-$RANDOM$RANDOM"
  cp -R "$FIX/$1" "$dir"
  git -C "$dir" init -q
  [[ -n "$2" ]] && git -C "$dir" remote add origin "$2"
  echo "$dir"
}
run_install() { OUT="$(bash "$SCRIPT" "$1" 2>&1)"; STATUS=$?; }
assert_no_github_dir() { [[ ! -e "$1/.github" ]] || fail "$2: nothing should be written (.github exists)"; }

# 1. GitHub origin: both files, filled in with fixture-service's values.
for url in https://github.com/example/fixture-service.git git@github.com:example/fixture-service.git; do
  d="$(repo_copy fixture-service "$url")"
  decl_before="$(cat "$d/.claude/deploy.json")"
  run_install "$d"
  assert_eq 0 "$STATUS" "a GitHub origin ($url) should install the starter ($OUT)"
  assert_contains "$OUT" ".github/workflows/release.yml" "the workflow path should be printed"
  assert_contains "$OUT" ".github/scripts/release-tag.sh" "the script path should be printed"
  [[ -f "$d/.github/workflows/release.yml" ]] || fail "release.yml should be written"
  [[ -x "$d/.github/scripts/release-tag.sh" ]] || fail "release-tag.sh should be written and executable"
  grep -qxF "VERSION_FILE='package.json'" "$d/.github/scripts/release-tag.sh" || fail "VERSION_FILE should come from the declaration"
  grep -qxF "VERSION_FIELD='.version'" "$d/.github/scripts/release-tag.sh" || fail "VERSION_FIELD should come from the declaration"
  grep -qxF "TAG_FORMAT='v{version}'" "$d/.github/scripts/release-tag.sh" || fail "TAG_FORMAT should come from the declaration"
  for f in "$d/.github/workflows/release.yml" "$d/.github/scripts/release-tag.sh"; do
    assert_not_contains "$(cat "$f")" "dkoenawan/compass-labs" "${f#"$d"/} should not name compass-labs' repo"
    assert_not_contains "$(cat "$f")" "CLAUDE_PLUGIN_ROOT" "${f#"$d"/} should not depend on the plugin"
  done
  cmp -s "$TPL/release.yml" "$d/.github/workflows/release.yml" || fail "release.yml should be the template as is"
  diff <(grep -vE '^(VERSION_FILE|VERSION_FIELD|TAG_FORMAT)=' "$TPL/release-tag.sh") \
       <(grep -vE '^(VERSION_FILE|VERSION_FIELD|TAG_FORMAT)=' "$d/.github/scripts/release-tag.sh") >/dev/null \
    || fail "release-tag.sh should differ from the template only in its settings"
  assert_eq "$decl_before" "$(cat "$d/.claude/deploy.json")" "the installer should not change the declaration"
done

# The installed script runs: --check reports fixture-service's tag.
git -C "$d" config user.email t@example.com && git -C "$d" config user.name T
git -C "$d" add -A && git -C "$d" commit -q -m fixture
bare="$work/bare.git" && git init -q --bare "$bare"
git -C "$d" remote set-url origin "$bare"
assert_contains "$(cd "$d" && bash .github/scripts/release-tag.sh --check 2>&1)" "would create v1.4.0" \
  "the installed script should report fixture-service's tag"

# 2. A non-GitHub origin, and no origin: nothing written.
for url in https://gitlab.com/example/fixture-service.git ""; do
  d="$(repo_copy fixture-service "$url")"
  run_install "$d"
  assert_eq 3 "$STATUS" "origin '${url:-none}' should be refused with exit 3"
  assert_contains "$OUT" "isn't a GitHub URL"
  assert_no_github_dir "$d" "origin '${url:-none}'"
done

# 2b. An SSH host alias counts only when ssh resolves it to github.com. A
# stub ssh stands in for the user's ~/.ssh/config (ssh -G connects to nothing).
sshbin="$work/sshbin"
mkdir -p "$sshbin"
cat >"$sshbin/ssh" <<'STUB'
#!/usr/bin/env bash
[[ "$1" == "-G" ]] || exit 1
case "$2" in
  gh-alias) echo "hostname github.com" ;;
  *) echo "hostname $2" ;;
esac
STUB
chmod +x "$sshbin/ssh"
d="$(repo_copy fixture-service git@gh-alias:example/fixture-service.git)"
OUT="$(PATH="$sshbin:$PATH" bash "$SCRIPT" "$d" 2>&1)"; STATUS=$?
assert_eq 0 "$STATUS" "an SSH alias that resolves to github.com should install ($OUT)"
d="$(repo_copy fixture-service git@other-alias:example/fixture-service.git)"
OUT="$(PATH="$sshbin:$PATH" bash "$SCRIPT" "$d" 2>&1)"; STATUS=$?
assert_eq 3 "$STATUS" "an SSH alias that doesn't resolve to github.com should be refused"
assert_no_github_dir "$d" "an SSH alias to another host"
d="$(repo_copy fixture-service https://github.com.evil.example/x.git)"
run_install "$d"
assert_eq 3 "$STATUS" "a host that only starts with github.com should be refused"

# 3. An existing workflow file is left byte for byte unchanged.
d="$(repo_copy fixture-service https://github.com/example/fixture-service.git)"
mkdir -p "$d/.github/workflows"
printf 'name: mine\non: push\n# the repo'"'"'s own, no newline at end' >"$d/.github/workflows/release.yml"
before="$(md5sum <"$d/.github/workflows/release.yml")"
run_install "$d"
assert_eq 5 "$STATUS" "an existing workflow should be refused with exit 5"
assert_contains "$OUT" ".github/workflows/release.yml already exists" "the existing file should be named"
assert_eq "$before" "$(md5sum <"$d/.github/workflows/release.yml")" "the existing workflow should be unchanged"
[[ ! -e "$d/.github/scripts/release-tag.sh" ]] || fail "nothing else should be written when a target exists"

# 4. A missing versioning.tag is named, and nothing is written.
d="$(repo_copy fixture-service https://github.com/example/fixture-service.git)"
jq 'del(.versioning.tag)' "$d/.claude/deploy.json" >"$d/x" && mv "$d/x" "$d/.claude/deploy.json"
run_install "$d"
assert_eq 4 "$STATUS" "a missing versioning field should be refused with exit 4"
assert_contains "$OUT" "versioning.tag missing" "the missing field should be named"
assert_no_github_dir "$d" "missing versioning.tag"

# 5. No declaration, or nothing to deploy: nothing written.
for fx in fixture-no-declaration fixture-docs-only; do
  d="$(repo_copy "$fx" https://github.com/example/x.git)"
  run_install "$d"
  assert_eq 1 "$STATUS" "$fx should be refused with exit 1"
  assert_no_github_dir "$d" "$fx"
done

echo "ok: install-starter.sh checked"
exit 0
