#!/usr/bin/env bash
set -euo pipefail
system="aarch64-linux" # Dummy definition for shellcheck
narSimilaritySearch="" # Dummy definition for shellcheck

echo "Testing parseFlakeToTerm with a valid flake..."
# Create a dummy valid flake
mkdir -p valid-flake
echo "{ description = \"A valid flake\"; outputs = { self, nixpkgs }: { packages.default = nixpkgs.legacyPackages.${system}.hello; }; }" > valid-flake/flake.nix

# Parse the flake
${narSimilaritySearch.lib.${system}.parseFlakeToTerm (pkgs.path + "/valid-flake")}
echo "Valid flake parsed successfully."