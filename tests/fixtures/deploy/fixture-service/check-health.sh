#!/usr/bin/env bash
# Fixture confirmation check. Prints the state in ./health-state (healthy
# or unhealthy) and exits 0 only when it's healthy. Switch it by writing
# "unhealthy" into health-state in a temp copy of the fixture.
state="$(tr -d '[:space:]' <"$(dirname "$0")/health-state" 2>/dev/null || echo healthy)"
echo "${state:-healthy}"
[[ "${state:-healthy}" == "healthy" ]]
