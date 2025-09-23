#!/usr/bin/env bash
set -euo pipefail

NAR_PATH="$1"
OUT_DIR="$2"

mkdir -p "$OUT_DIR"

# Realize the NAR file into the Nix store
STORE_PATH=$(nix-store --realise "$NAR_PATH")

# Copy the contents of the store path to the output directory
cp -r "$STORE_PATH"/* "$OUT_DIR/unpacked_nar"
cp "$OUT_DIR/unpacked_nar/primes.txt" "$OUT_DIR/primes.txt"