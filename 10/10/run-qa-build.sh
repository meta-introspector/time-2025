#!/usr/bin/env bash

set -euo pipefail

# Get the directory of the current script
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Set NIX_PATH to ensure nix-build can find nixpkgs
NIXPKGS_PATH=$(nix-instantiate --find-file nixpkgs)
export NIX_PATH=nixpkgs=$NIXPKGS_PATH

# Build the Nix derivation and capture its output path
# Pass pkgs explicitly to run-qa.nix, using the specified flake input for nixpkgs
NIX_BUILD_RESULT="$(nix-build "$SCRIPT_DIR/run-qa.nix" --arg pkgs '(import (builtins.fetchTarball "https://github.com/meta-introspector/nixpkgs/archive/feature/CRQ-016-nixify.tar.gz") {})')"

# Read the content of the derivation (which contains the QA output)
echo "--- QA Output ---"
cat "$NIX_BUILD_RESULT"
echo "-----------------"