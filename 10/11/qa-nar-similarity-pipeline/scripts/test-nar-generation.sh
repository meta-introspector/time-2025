#!/usr/bin/env bash
set -euo pipefail

system="aarch64-linux" # Dummy definition for shellcheck

echo "Testing NAR generation with nar-binstore-builder..."
# Create a dummy flake to be built and NAR-ified
mkdir -p dummy-nar-flake
echo "{ description = \"Dummy NAR flake\"; outputs = { self, nixpkgs }: { packages.default = nixpkgs.legacyPackages.${system}.hello; }; }" > dummy-nar-flake/flake.nix

# Build the dummy flake using nar-binstore-builder
pushd "$(dirname "$0")" > /dev/null
nar_output=$(nix eval --raw --flake .#allNarsOutput)
popd > /dev/null
echo "NAR output: $nar_output"
# Further assertions: check if NAR is in binstore, verify content address