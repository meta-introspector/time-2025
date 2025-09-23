#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="$1"
NUMBER_23_PATH="$2"
IS_PRIME_23_PATH="$3"
FACT_23_ORACLE_PATH="$4"
ZOS_PRIMES_LINKS="$5" # This will be a multi-line string of ln -s commands

mkdir -p "$OUT_DIR/concepts"
ln -s "$NUMBER_23_PATH" "$OUT_DIR/concepts/number_23"
ln -s "$IS_PRIME_23_PATH" "$OUT_DIR/concepts/is_prime_23"
ln -s "$FACT_23_ORACLE_PATH" "$OUT_DIR/concepts/fact_23"

# Execute the zosPrimesLinks
eval "$ZOS_PRIMES_LINKS"