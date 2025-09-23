#!/usr/bin/env bash
set -euo pipefail

NAR_PATH="$1"
OUT_DIR="$2"

mkdir -p "$OUT_DIR"
nix-unpack "$NAR_PATH" "$OUT_DIR/unpacked_nar"
cp "$OUT_DIR/unpacked_nar/primes.txt" "$OUT_DIR/primes.txt"