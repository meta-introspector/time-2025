#!/usr/bin/env bash

set -euo pipefail

FLAKE_NIX_PATH="$(dirname "$(readlink -f "$0")")/flake.nix"

# Get the last 8 Git commit hashes
COMMIT_HASHES=($(git log --pretty=format:%H -n 8))

# Read current generation
CURRENT_GENERATION=$(grep -oP 'generation = \K\d+' "$FLAKE_NIX_PATH")

# Calculate next generation (modulo 8, 1-based)
NEXT_GENERATION=$(((CURRENT_GENERATION % 8) + 1))

echo "Updating generation from $CURRENT_GENERATION to $NEXT_GENERATION in $FLAKE_NIX_PATH"

# Update generation in flake.nix
sed -i "s/generation = $CURRENT_GENERATION;/generation = $NEXT_GENERATION;/" "$FLAKE_NIX_PATH"

# Update snapshot inputs in flake.nix
for i in $(seq 1 8); do
  SNAPSHOT_REF=${COMMIT_HASHES[$((i-1))]} # Get the i-th commit hash
  # Replace the ref for each snapshot input
  sed -i "s|time-2025-snapshot-$i = { url = \"github:meta-introspector/time-2025?ref=.*\"; flake = true; };|time-2025-snapshot-$i = { url = \"github:meta-introspector/time-2025?ref=$SNAPSHOT_REF\"; flake = true; }|" "$FLAKE_NIX_PATH"
done

# Format flake.nix before committing
nixpkgs-fmt "$FLAKE_NIX_PATH"

# Stage and commit changes
git add "$FLAKE_NIX_PATH"
git commit -m "chore: Update ZOS orchestrator generation to $NEXT_GENERATION and update snapshots"

echo "Generation and snapshots updated and committed."
