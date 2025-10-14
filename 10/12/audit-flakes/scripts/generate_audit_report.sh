#!/usr/bin/env bash

set -uo pipefail

# Define the base directory for the flakes
FLAKE_BASE_DIR="$(dirname "$(dirname "$(realpath "$0")")")"

# Define output file names (for future use)
# shellcheck disable=SC2034
OUTPUT_001_DEFAULT="${FLAKE_BASE_DIR}/001_collect_locks_default_output.json"
# shellcheck disable=SC2034
OUTPUT_001_NAMES="${FLAKE_BASE_DIR}/001_collect_locks_names_output.json"
# shellcheck disable=SC2034
OUTPUT_002_DEFAULT="${FLAKE_BASE_DIR}/002c_collected_locks_derivation_default_output.json"
# shellcheck disable=SC2034
OUTPUT_002_NAMES="${FLAKE_BASE_DIR}/002c_collected_locks_derivation_names_output.json"
# shellcheck disable=SC2034
AUDIT_REPORT="${FLAKE_BASE_DIR}/audit_report.json"
BUILD_LOG="${FLAKE_BASE_DIR}/build_log.txt"

echo "Generating audit report..."
echo "Full build log will be saved to: ${BUILD_LOG}"

# Clear previous log
true > "${BUILD_LOG}"

# Function to run nix build and append its output to the log file
run_nix_build() {
  local FLAKE_REF="$1"
  local TEMP_LOG; TEMP_LOG="${FLAKE_BASE_DIR}/temp_nix_build_$(basename "${FLAKE_REF}" | tr -d '#/.').log"
  echo "--- Building ${FLAKE_REF} ---" | tee -a "${BUILD_LOG}"
  (nix build "${FLAKE_REF}" --json --show-trace || true) &> "${TEMP_LOG}"
  tee -a "${BUILD_LOG}" < "${TEMP_LOG}"
  rm "${TEMP_LOG}"
}

# Run nix build commands
run_nix_build "${FLAKE_BASE_DIR}/001_collect_locks/.#default"
run_nix_build "${FLAKE_BASE_DIR}/001_collect_locks/.#checks.aarch64-linux.allLockFilePackageNames"
run_nix_build "${FLAKE_BASE_DIR}/002c_collected_locks_derivation/.#default"
run_nix_build "${FLAKE_BASE_DIR}/002c_collected_locks_derivation/.#checks.aarch64-linux.allProcessedPackageNames"

echo "Build process completed. Check ${BUILD_LOG} for details."
