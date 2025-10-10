#!/usr/bin/env bash

set -euo pipefail

FLAKE_SOURCE="$1"
PLAN_DERIVATION_PATH="$2"

echo "Running build for derived LLM task flake: ${FLAKE_SOURCE}"
chmod +x "${PLAN_DERIVATION_PATH}"/build-command.sh
"${PLAN_DERIVATION_PATH}"/build-command.sh > "$out" 2>&1
