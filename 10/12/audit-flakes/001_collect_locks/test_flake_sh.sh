#!/usr/bin/env bash

set -euo pipefail

# Define paths relative to the script's location
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

echo "Running flake.sh test..."

# Execute run_flake_sh_test_env.sh
bash $SCRIPT_DIR/run_flake_sh_test_env.sh

echo "Test completed successfully."
