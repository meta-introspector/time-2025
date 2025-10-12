#!/usr/bin/env bash
set -euo pipefail
echo "Testing projectTo8D..."
# Build the monster-knot-calculator flake and get its output
monster_knot_value_path=$(nix build ../../flakes/monster-knot-calculator -o monster-knot-result --no-link --print-out-paths)
monster_knot_value=$(cat "$monster_knot_value_path")

echo "Monster Knot Value: $monster_knot_value"

# Assert that the monster knot value is as expected (this is a placeholder assertion)
if [[ "$monster_knot_value" != "expected_monster_knot_value" ]]; then
  echo "Error: Monster Knot value not as expected." >&2
  exit 1
fi