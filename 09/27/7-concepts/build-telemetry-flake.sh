#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

FLAKE_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/7-concepts/6-qa-testing/tests/2025-01-27-gemini-telemetry-capture-v3#packages.aarch64-linux.default"

# Get the user's actual HOME directory
HOST_HOME="$HOME"

# Define Nix build arguments
NIX_BUILD_ARGS=(
  "--extra-experimental-features"
  "impure-derivations"
  "--extra-experimental-features"
  "ca-derivations"
)

echo "Building Nix flake: $FLAKE_PATH"
echo "Using HOST_HOME: $HOST_HOME" # This will now just show the shell's HOME, not passed to Nix

nix build "$FLAKE_PATH" "${NIX_BUILD_ARGS[@]}"

echo "Nix build completed. Checking for telemetry.log..."

# Check if the result symlink exists and then check for telemetry.log
if [ -L ./result ]; then
  if [ -f ./result/logs/telemetry.log ]; then
    echo "SUCCESS: telemetry.log found in ./result/logs/"
    ls -l ./result/logs/telemetry.log
  else
    echo "WARNING: telemetry.log NOT found in ./result/logs/"
    echo "Contents of ./result/logs/:"
    ls -l ./result/logs/
  fi
else
  echo "ERROR: Nix build did not produce a ./result symlink."
fi
