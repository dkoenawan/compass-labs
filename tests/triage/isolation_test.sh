#!/usr/bin/env bash
# isolation_test.sh
# DES-008: no triage test can reach the real GitHub, crontab or claude.
# Every test that runs a triage script calls triage_setup first (stubs first
# on PATH, TRIAGE_*_BIN at the stubs, the run log under TMPDIR), and no test
# names a real binary's path.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

dir="$REPO_ROOT/tests/triage"
count=0
for f in "$dir"/*_test.sh; do
  name="$(basename "$f")"
  [[ "$name" == isolation_test.sh ]] && continue
  grep -q 'source "$(cd "$(dirname "${BASH_SOURCE\[0\]}")" && pwd)/lib.sh"' "$f" \
    || fail "$name should source tests/triage/lib.sh"
  if grep -qE '\$(TRIAGE_SCRIPTS|RUN|INSTALL|UNINSTALL|PUBLISH|GATHER|ENSURE)\b' "$f" \
     && grep -qE '^(bash|.*\bbash "\$)' "$f"; then
    first_setup="$(grep -n '^triage_setup$' "$f" | head -1 | cut -d: -f1)"
    first_run="$(grep -nE 'bash "\$(TRIAGE_SCRIPTS|RUN|INSTALL|UNINSTALL|PUBLISH|GATHER|ENSURE)' "$f" | head -1 | cut -d: -f1)"
    [[ -n "$first_setup" ]] || fail "$name runs a triage script without triage_setup"
    [[ -z "$first_run" || "$first_setup" -lt "$first_run" ]] || fail "$name runs a script before triage_setup"
    count=$((count + 1))
  fi
  for real in /.local/bin/claude /usr/bin/gh /usr/local/bin/gh /usr/bin/crontab "crontab -r"; do
    grep -qF -- "$real" "$f" && fail "$name names a real binary or a destructive call: $real"
  done
done
[[ $count -ge 5 ]] || fail "expected the five script tests to be checked, found $count"

# triage_setup points everything at the stubs and TMPDIR.
triage_setup
assert_eq "$TRIAGE_STUBS/gh" "$TRIAGE_GH_BIN" "TRIAGE_GH_BIN is the stub"
assert_eq "$TRIAGE_STUBS/claude" "$TRIAGE_CLAUDE_BIN" "TRIAGE_CLAUDE_BIN is the stub"
assert_eq "$TRIAGE_STUBS" "${PATH%%:*}" "the stubs are first on PATH"
case "$CRONTAB_STUB_FILE:$XDG_STATE_HOME" in
  "$TMPDIR"/*:"$TMPDIR"/*) ;;
  *) fail "the stub crontab file and the run log must be under TMPDIR" ;;
esac

exit 0
