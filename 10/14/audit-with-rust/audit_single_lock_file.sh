#!/usr/bin/env bash

set -euo pipefail

out="${out:-/tmp/nix-build-output}" # Default for shellcheck, actual value from Nix

# These variables are expected to be provided by the Nix build environment.
# flakeAuditor: Path to the flake_auditor executable.
# lockFileDerivation: Path to the derivation containing lock-file-info.json.

# Ensure required environment variables are set
: "${flakeAuditor?Error: flakeAuditor is not set}"
: "${lockFileDerivation?Error: lockFileDerivation is not set}"

# Build the lockFilePackage derivation to get its output path
lock_file_info_path=$(nix build --no-link --print-out-paths "$lockFileDerivation")

# Extract the actual lockFilePath from the lock-file-info.json
actual_lock_file_path=$(jq -r '.lockFilePath' "$lock_file_info_path/lock-file-info.json")

# Run the flakeAuditor on the extracted lockFilePath
mkdir -p "$out"
"$flakeAuditor"/bin/flake_auditor "$actual_lock_file_path" > "$out/audit-report.txt"
