#!/usr/bin/env bash

# This script is for debugging the nix develop command for a specific flake.
# It will cd into the flake directory and attempt to run nix develop, capturing all output.

set -euo pipefail

FLAKE_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/flakes/crq-018"
LOG_FILE="/data/data/com.termux.nix/files/home/pick-up-nix2/nix_develop_debug.log"

cd "${FLAKE_DIR}"
nix develop --command true > "${LOG_FILE}" 2>&1
