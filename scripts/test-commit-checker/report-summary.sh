#!/usr/bin/env bash

# Reports the summary of passed and failed commit message checks.
# Usage: report-summary.sh <PASSED_COUNT> <FAILED_COUNT>

set -euo pipefail

PASSED_COUNT="$1"
FAILED_COUNT="$2"

printf "\n--- Test Summary ---\nPassed: %s\nFailed: %s\n" "${PASSED_COUNT}" "${FAILED_COUNT}"

if [[ ${FAILED_COUNT} -gt 0 ]]; then
  echo "Some commit messages failed the check."
  exit 1
else
  echo "All commit messages passed the check."
  exit 0
fi
