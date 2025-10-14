#!/usr/bin/env bash
set -euo pipefail

echo "Updating and building all flakes..."

# Find all directories containing flake.nix files
FLAKE_DIRS=$(find . -name flake.nix -print0 | xargs -0 -n1 dirname)

for dir in $FLAKE_DIRS; do
  echo "Processing flake in: $dir"
  (
    cd "$dir" || exit 1
    echo "Running nix flake update in $dir..."
    nix flake update
    echo "Running nix build in $dir..."
    nix build
  )
done

echo "All flakes updated and built individually."

echo "Building 002c_collected_locks_derivation default package..."
nix build ./10/12/audit-flakes/002c_collected_locks_derivation#default --json > result.json

echo "Verifying output..."
jq . result.json

echo "Building 002c_collected_locks_derivation allProcessedPackageNames check..."
nix build ./10/12/audit-flakes/002c_collected_locks_derivation#checks.allProcessedPackageNames --json > names_result.json

echo "Verifying names output..."
jq . names_result.json

echo "Debug-jq.sh completed successfully."
