#!/usr/bin/env bash
set -euo pipefail

nix flake update

echo "Building 002c_collected_locks_derivation default package..."
nix build ./10/12/audit-flakes/002c_collected_locks_derivation#default --json > result.json

echo "Verifying output..."
jq . result.json

echo "Building 002c_collected_locks_derivation allProcessedPackageNames check..."
nix build ./10/12/audit-flakes/002c_collected_locks_derivation#checks.allProcessedPackageNames --json > names_result.json

echo "Verifying names output..."
jq . names_result.json

echo "Debug-jq.sh completed successfully."
