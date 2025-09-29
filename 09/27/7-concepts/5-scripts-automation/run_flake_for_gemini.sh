#!/usr/bin/env bash

# This script runs a specified Nix flake and prints its output.
# It is designed to be called by the Gemini CLI, which can then capture and process the output.

# Check if a flake path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <flake-path>"
    echo "Example: $0 github:NixOS/nixpkgs#hello"
    exit 1
fi

FLAKE_PATH="$1"

echo "Running Nix flake: $FLAKE_PATH"

# Execute the flake and capture its output
nix run "$FLAKE_PATH" -- \
    --argstr flakePath "$FLAKE_PATH" \
    --argstr geminiRun "true"

# Note: The '--' is important to separate nix run arguments from the flake's own arguments.
# We are passing 'flakePath' and 'geminiRun' as example arguments to the flake itself.
# The flake's 'apps.<system>.default' or 'packages.<system>.default' should be designed
# to accept and utilize these arguments if needed.
