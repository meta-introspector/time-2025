#!/usr/bin/env bash

set -euo pipefail

SYSTEM=$(nix eval --raw --impure --expr 'builtins.currentSystem' --extra-experimental-features 'nix-command flakes')
BAG_OF_WORDS_GENERATOR_PATH="/nix/store/824rwl196z7qps94z6blmg2a903py-source"
NIX_FILE_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/flake.nix"

echo "DEBUG: SYSTEM = $SYSTEM"
echo "DEBUG: BAG_OF_WORDS_GENERATOR_PATH = $BAG_OF_WORDS_GENERATOR_PATH"
echo "DEBUG: NIX_FILE_PATH = $NIX_FILE_PATH"

BAG_OF_WORDS_DERIVATION_PATH=$(nix eval --raw --impure --extra-experimental-features 'nix-command flakes' \
  --expr "let \
    flake = (builtins.getFlake "path:$BAG_OF_WORDS_GENERATOR_PATH"); \
    pkgs = flake.inputs.nixpkgs.legacyPackages.\"$SYSTEM\"; \
    lib = pkgs.lib; \
  in \
    flake.lib.\"$SYSTEM\".generateBagOfWords \"$NIX_FILE_PATH\""
)

echo "DEBUG: BAG_OF_WORDS_DERIVATION_PATH = $BAG_OF_WORDS_DERIVATION_PATH"

BAG_OF_WORDS_OUTPUT_PATH=$(nix build --no-link --print-out-paths \
  --extra-experimental-features 'nix-command flakes' \
  "$BAG_OF_WORDS_DERIVATION_PATH")

echo "DEBUG: BAG_OF_WORDS_OUTPUT_PATH = $BAG_OF_WORDS_OUTPUT_PATH"

ls -l "$BAG_OF_WORDS_OUTPUT_PATH"

cat "$BAG_OF_WORDS_OUTPUT_PATH/report.json"