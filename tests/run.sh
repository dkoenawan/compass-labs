#!/usr/bin/env bash
# run.sh
# Test harness for the session-lifecycle plugin components. Discovers and
# runs every tests/**/*_test.sh, reports pass/fail per test, and exits
# non-zero if any test fails. Plain bash + jq only — no other dependencies.
#
# Usage: bash tests/run.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pass_count=0
fail_count=0
failed_tests=()

# Discover every *_test.sh under tests/, sorted for stable output.
mapfile -t test_files < <(find "$SCRIPT_DIR" -type f -name '*_test.sh' | sort)

if [[ ${#test_files[@]} -eq 0 ]]; then
  echo "run.sh: no *_test.sh files found under $SCRIPT_DIR"
  exit 1
fi

for test_file in "${test_files[@]}"; do
  rel_path="${test_file#"$SCRIPT_DIR"/}"
  output="$(bash "$test_file" 2>&1)"
  status=$?
  if [[ $status -eq 0 ]]; then
    echo "PASS  $rel_path"
    pass_count=$((pass_count + 1))
  else
    echo "FAIL  $rel_path"
    echo "$output" | sed 's/^/      /'
    fail_count=$((fail_count + 1))
    failed_tests+=("$rel_path")
  fi
done

echo ""
echo "$pass_count passed, $fail_count failed (of ${#test_files[@]})"

if [[ $fail_count -gt 0 ]]; then
  echo ""
  echo "Failed:"
  for t in "${failed_tests[@]}"; do
    echo "  - $t"
  done
  exit 1
fi

exit 0
