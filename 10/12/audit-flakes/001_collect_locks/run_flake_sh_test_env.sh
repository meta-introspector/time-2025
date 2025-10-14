#!/usr/bin/env bash

set -euo pipefail

# Define paths relative to the script's location
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
FLAKE_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025"

# Define the temporary shell.nix path
TMP_SHELL_NIX="$FLAKE_ROOT/tmp_test_shell.nix"

# Ensure the temporary shell.nix exists
if [ ! -f "$TMP_SHELL_NIX" ]; then
  echo "Error: $TMP_SHELL_NIX not found. Please create it first." >&2
  exit 1
fi

# Create a temporary output directory
TEMP_OUT_DIR=$(mktemp -d)

# Define environment variables for the flake.sh script
NIX_FILE_PATH="$FLAKE_ROOT/flake.nix"
lockFile="$FLAKE_ROOT/flake.lock"
BAG_OF_WORDS_GENERATOR_PATH="$FLAKE_ROOT/flakes/bag-of-words-generator"

# Construct the command to run inside nix-shell
nix-shell --run "export out=\"$TEMP_OUT_DIR\" && \
  export NIX_FILE_PATH=\"$NIX_FILE_PATH\" && \
  export lockFile=\"$lockFile\" && \
  export BAG_OF_WORDS_GENERATOR_PATH=\"$BAG_OF_WORDS_GENERATOR_PATH\" && \
  export SCRIPT_DIR=\"$SCRIPT_DIR\" && \
  bash $SCRIPT_DIR/nix_shell_inner_command.sh" --pure "$TMP_SHELL_NIX"

echo "Test environment execution completed."
