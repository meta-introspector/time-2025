#!/usr/bin/env bash

# This script is for debugging the nix build command for a specific flake.
# It will cd into the flake directory and attempt to run nix build, capturing all output.

set -euo pipefail

FLAKE_DIR="$1"
LOG_FILE="/data/data/com.termux.nix/files/home/pick-up-nix2/nix_build_debug.log"

if [[ -z "${FLAKE_DIR}" ]]; then
  echo "Usage: $0 <FLAKE_PATH>"
  exit 1
fi

if [[ ! -d "${FLAKE_DIR}" ]]; then
  echo "Error: Flake path '${FLAKE_DIR}' does not exist."
  exit 1
fi

cd "${FLAKE_DIR}"
nix build > "${LOG_FILE}" 2>&1
