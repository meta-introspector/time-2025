#!/usr/bin/env bash
set -euo pipefail

BUILD_LOG="build.log"
TEST_LOG="test.log"

# Function to run the build
run_build() {
  echo "--- Running Nix Build ---"
  nix build .#defaultPackage.aarch64-linux 2>&1 | tee "$BUILD_LOG"
  echo "--- Nix Build Complete ---"
}

# Function to run the tests
run_tests() {
  echo "--- Running Nix Flake Check ---"
  nix flake check 2>&1 | tee "$TEST_LOG"
  echo "--- Nix Flake Check Complete ---"
}

# Function to check logs for errors
check_logs() {
  echo "--- Checking Logs for Errors ---"
  if grep -q "error" "$BUILD_LOG"; then
    echo "ERROR: Build log contains errors. Please check $BUILD_LOG"
    exit 1
  fi
  if grep -q "error" "$TEST_LOG"; then
    echo "ERROR: Test log contains errors. Please check $TEST_LOG"
    exit 1
  fi
  echo "--- No Errors Found in Logs ---"
}

# Main execution
main() {
  run_build
  run_tests
  check_logs
  echo "Build and Test process completed successfully!"
}

main
