#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="$1"
FACT_FILE="$2"

mkdir -p "$OUT_DIR"
cp "$FACT_FILE" "$OUT_DIR/fact"