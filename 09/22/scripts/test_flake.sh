#!/usr/bin/env bash

# This script provides a generic way to test a Nix flake by entering its
# development shell and attempting to build its default package.

set -euo pipefail

FLAKE_PATH="$1"
LOG_FILE="flake_test_$(basename "${FLAKE_PATH}")_$(date +%Y%m%d_%H%M%S).log"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

if [[ -z "${FLAKE_PATH}" ]]; then
  echo "Usage: $0 <FLAKE_PATH>"
  exit 1
fi

log "Starting flake test for: ${FLAKE_PATH}"
log "Logging output to: ${LOG_FILE}"

# Ensure the flake path exists
if [[ ! -d "${FLAKE_PATH}" ]]; then
  log "Error: Flake path '${FLAKE_PATH}' does not exist."
  exit 1
fi

# Change to the flake directory
log "Changing directory to: ${FLAKE_PATH}"
cd "${FLAKE_PATH}"

# Test nix develop
log "Attempting to enter nix develop shell..."
if nix develop --command true 2>&1 | tee -a "${LOG_FILE}"; then
  log "Successfully entered nix develop shell."
else
  log "Error: Failed to enter nix develop shell. Check ${LOG_FILE} for details."
  exit 1
fi

# Test nix build (default package)
log "Attempting to build default package..."
if nix build 2>&1 | tee -a "${LOG_FILE}"; then
  log "Successfully built default package."
else
  log "Error: Failed to build default package. Check ${LOG_FILE} for details."
  exit 1
fi

log "Flake test completed successfully for: ${FLAKE_PATH}"
