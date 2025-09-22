#!/usr/bin/env bash

# This script runs the automate_dependency_forking.sh script within the
# dedicated Nix development shell for CRQ-018.

set -euo pipefail

FLAKE_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/flakes/crq-018"
TARGET_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/scripts/automate_dependency_forking.sh"

# Change to the flake directory, run nix develop, and then execute the target script
cd "${FLAKE_DIR}"
nix develop --command bash -c "${TARGET_SCRIPT}" "$@"
