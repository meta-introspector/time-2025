#!/usr/bin/env bash
set -euo pipefail

# --- Test Driver for unpack-zos-sequence.sh ---

# 1. Setup: Create a dummy NAR file and output directory
TEST_NAR_DIR=$(mktemp -d)
TEST_OUT_DIR=$(mktemp -d)
DUMMY_NAR_PATH="$TEST_NAR_DIR/dummy.nar"
EXPECTED_PRIMES_FILE="$TEST_OUT_DIR/primes.txt"

# Create a dummy primes.txt inside a temporary directory
mkdir -p "$TEST_NAR_DIR/unpacked_nar"
echo "2\n3\n5" > "$TEST_NAR_DIR/unpacked_nar/primes.txt"

# Pack the temporary directory into a NAR file
nix-store --dump "$TEST_NAR_DIR/unpacked_nar" > "$DUMMY_NAR_PATH"
DUMMY_NAR_STORE_PATH=$(nix-store --add "$DUMMY_NAR_PATH")
echo "Dummy NAR added to store at: $DUMMY_NAR_STORE_PATH"

echo "Created dummy NAR at: $DUMMY_NAR_PATH"
echo "Test output will be in: $TEST_OUT_DIR"

# 2. Run the script under test
echo "Running unpack-zos-sequence.sh..."
/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/23/nix_concepts_and_facts/scripts/unpack-zos-sequence.sh "$DUMMY_NAR_STORE_PATH" "$TEST_OUT_DIR"

# 3. Verification
echo "Verifying output..."
if [ -f "$EXPECTED_PRIMES_FILE" ]; then
  echo "Verification SUCCESS: primes.txt found."
  if cmp -s <(echo -e "2\n3\n5") "$EXPECTED_PRIMES_FILE"; then
    echo "Verification SUCCESS: primes.txt content matches."
    exit 0
  else
    echo "Verification FAILED: primes.txt content mismatch."
    exit 1
  fi
else
  echo "Verification FAILED: primes.txt not found."
  exit 1
fi

# 4. Cleanup (optional, for manual inspection)
# rm -rf "$TEST_NAR_DIR" "$TEST_OUT_DIR"
