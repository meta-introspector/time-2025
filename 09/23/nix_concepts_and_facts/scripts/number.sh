#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="$1"
NUMBER="$2" # New parameter for the number

mkdir -p "$OUT_DIR"
echo "$NUMBER" > "$OUT_DIR/number"