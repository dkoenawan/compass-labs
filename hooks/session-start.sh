#!/usr/bin/env bash
# session-start.sh
# SessionStart hook (ADR-011, #98). In every session, prints one line of
# context when pstack's model settings are missing or unsafe on a Claude
# subscription, or when a second pstack plugin is installed, so Claude can
# point the user at /trellis:setup. Silent when all is well.
#
# SessionStart can't meaningfully block startup, so this hook ALWAYS
# exits 0, and prints nothing extra on any problem of its own.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PSTACK_MODELS_SCRIPT="$SCRIPT_DIR/../skills/setup/scripts/pstack-models.sh"

cat >/dev/null  # the hook input isn't needed

[[ -f "$PSTACK_MODELS_SCRIPT" ]] || exit 0

if ! pstack_reasons="$(bash "$PSTACK_MODELS_SCRIPT" check 2>/dev/null)"; then
  echo "[trellis] pstack's model settings aren't subscription-safe yet (${pstack_reasons%%$'\n'*}). Tell the user to run /trellis:setup."
fi

pstack_others="$(bash "$PSTACK_MODELS_SCRIPT" conflicts 2>/dev/null | paste -sd, -)"
if [[ -n "$pstack_others" ]]; then
  echo "[trellis] Another pstack plugin is installed ($pstack_others) next to pstack@cursor-plugins; both register /pstack: commands. Tell the user to run /trellis:setup."
fi

exit 0
