#!/usr/bin/env bash
set -euo pipefail

system="x86_64-linux" # Dummy definition for shellcheck
narSimilaritySearch="" # Dummy definition for shellcheck

echo "Testing parseFlakeToTerm with an invalid flake (expecting failure)..."
# Create a dummy invalid flake
mkdir -p invalid-flake
echo "{ description = \"An invalid flake\"; outputs = { self, nixpkgs }: { packages.default = nixpkgs.legacyPackages.${system}.hello; }; " > invalid-flake/flake.nix # Missing closing brace

# Attempt to parse the flake (should fail)
if ${narSimilaritySearch.lib.${system}.parseFlakeToTerm (pkgs.path + "/invalid-flake")} 2>&1 | grep -q "error"; then
  echo "Invalid flake parsing failed as expected."
else
  echo "Error: Invalid flake parsing did not fail."
  exit 1
fi