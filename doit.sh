#!/usr/bin/env bash

set -euo pipefail

# echo "Running tests for 002a_inputs_only..."
# (
#   cd 10/12/audit-flakes/002a_inputs_only
#   nix build
#   nix eval .#checks.aarch64-linux.healthcheck --json
#   cat ./result/inputs-info.json
# )

# echo "Running tests for 002b_inputs_and_description..."
# (
#   cd 10/12/audit-flakes/002b_inputs_and_description
#   nix build
#   nix eval .#checks.aarch64-linux.healthcheck --json
# )

echo "Running tests for 002c_collected_locks_derivation..."
(
  cd 10/12/audit-flakes/002c_collected_locks_derivation
  nix build
  nix eval .#checks.aarch64-linux.healthcheck --json
)

echo "Running tests for 002d_processed_lock_files..."
(
  cd 10/12/audit-flakes/002d_processed_lock_files
  nix build
  nix eval .#checks.aarch64-linux.healthcheck --json
)

# echo "Running original project test..."
# nix build .#test
