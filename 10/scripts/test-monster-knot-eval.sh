#!/usr/bin/env bash
set -euo pipefail

echo "Testing evaluation of monster-knot-calculator flake..."

# Evaluate the monsterKnotValue from the flake
# We need to specify a system, for example, x86_64-linux
# The flake.nix defines supportedSystems, so we can pick one.
# Note: This assumes the current shell has access to Nix and the flake inputs.
monster_knot_value=$(nix eval --raw ../../flakes/monster-knot-calculator#packages.x86_64-linux.monsterKnotValue)

echo "Evaluated Monster Knot Value: $monster_knot_value"

# Assert that the monster knot value is not empty (a more specific assertion would require knowing the expected value)
if [[ -z "$monster_knot_value" ]]; then
  echo "Error: Evaluated Monster Knot value is empty." >&2
  exit 1
fi

echo "Test successful: Monster Knot value evaluated and is not empty."
