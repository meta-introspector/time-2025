#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="$1"
IS_PRIME_SCRIPT="$2"
NUMBER="$3"

mkdir -p "$OUT_DIR"
chmod +x "$IS_PRIME_SCRIPT"
"$IS_PRIME_SCRIPT" "$NUMBER" > "$OUT_DIR/result"