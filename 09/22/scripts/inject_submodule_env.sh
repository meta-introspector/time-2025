#!/usr/bin/env bash

# This script injects a prepared Gemini CLI environment into a specified submodule.

set -euo pipefail

if [ -z "$2" ]; then
  echo "Usage: $0 <TARGET_SUBMODULE_PATH> <CRQ_NUMBER>"
  echo "Example: $0 vendor/nix/nixtract 123"
  exit 1
fi

TARGET_SUBMODULE_PATH="$1"
CRQ_NUMBER="$2"

ROOT_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2"
FULL_TARGET_PATH="${ROOT_DIR}/${TARGET_SUBMODULE_PATH}"

echo "Injecting Gemini CLI environment into ${FULL_TARGET_PATH} for CRQ-${CRQ_NUMBER}"

# Ensure target directory exists
mkdir -p "${FULL_TARGET_PATH}"

# --- Create tailored boot.sh for the submodule ---
cat << 'EOF' > "${FULL_TARGET_PATH}/boot.sh"
#!/usr/bin/env bash

# This boot.sh is tailored for the submodule to launch the Gemini CLI.

# Configuration
SUBMODULE_NAME=$(basename "$(pwd)")
SESSION_NAME="crq-${CRQ_NUMBER}-${SUBMODULE_NAME}"
LOG_DIR=".gemini_logs"
RECORDING_DIR="${LOG_DIR}/recordings"
mkdir -p "$RECORDING_DIR"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Asciinema recording
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ASCIINEMA_REC_FILE="${RECORDING_DIR}/session_${TIMESTAMP}.cast"

echo "Starting asciinema recording to: ${ASCIINEMA_REC_FILE}"

# The command to be executed inside tmux, which launches the Gemini CLI
TMUX_INNER_COMMAND="nix develop --command bash -c \"/data/data/com.termux.nix/files/home/pick-up-nix2/gemini_cli_recent.sh\""

# Start asciinema recording, and inside it, start/attach to a tmux session.
# The tmux session will then execute the gemini command.
# The 'bash -c' is used to ensure the inner command is executed correctly within tmux.
ascinema rec "${ASCIINEMA_REC_FILE}" --command "tmux new-session -A -s \"${SESSION_NAME}\" \; send-keys -t \"${SESSION_NAME}\" \"${TMUX_INNER_COMMAND}\" C-m"

echo "Recording finished. To play: asciinema play ${ASCIINEMA_REC_FILE}"

# Initiate Crash Recovery Checks (adjusted for submodule context)
echo "--- Initiating Crash Recovery Checks ---" | tee -a "$LOG_DIR/crash_recovery_log.txt"
echo "Git Status:" | tee -a "$LOG_DIR/crash_recovery_log.txt"
git status --ignore-submodules | tee -a "$LOG_DIR/crash_recovery_log.txt"
echo "" | tee -a "$LOG_DIR/crash_recovery_log.txt"

echo "Git Diff HEAD:" | tee -a "$LOG_DIR/crash_recovery_log.txt"
git diff HEAD | tee -a "$LOG_DIR/crash_recovery_log.txt"
echo "" | tee -a "$LOG_DIR/crash_recovery_log.txt"

echo "--- Crash Recovery Checks Complete ---" | tee -a "$LOG_DIR/crash_recovery_log.txt"

EOF

# Make the generated boot.sh executable
chmod +x "${FULL_TARGET_PATH}/boot.sh"

# --- Create minimal flake.nix for the submodule ---
cat << 'EOF' > "${FULL_TARGET_PATH}/flake.nix"
{
  description = "A flake for the submodule, providing a development shell for Gemini CLI.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bash
            git
            asciinema
            pre-commit # Add pre-commit to the devShell
            shellcheck # Add shellcheck to the devShell
          ];

          shellHook = ''
            echo "Welcome to the submodule Gemini CLI development shell!"
            pre-commit install # Install pre-commit hooks when entering the shell
          '';
        };
      }
    );
}
EOF

# --- Create .pre-commit-config.yaml for shellcheck ---
PRE_COMMIT_CONFIG_PATH="${FULL_TARGET_PATH}/.pre-commit-config.yaml"
LOG_FILE="${ROOT_DIR}/logs/inject_submodule_env.log"

if [ -f "$PRE_COMMIT_CONFIG_PATH" ]; then
  echo "Warning: .pre-commit-config.yaml already exists in ${FULL_TARGET_PATH}. A new LLM task needs to be created to merge or fix the pre-commit configuration." | tee -a "$LOG_FILE"
else
  cat << 'EOF' > "$PRE_COMMIT_CONFIG_PATH"
repos:
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.5 # Use a specific version
    hooks:
      - id: shellcheck
EOF
fi

# --- Copy docs ---

mkdir -p "${FULL_TARGET_PATH}/docs"

# Copy a placeholder standard doc (e.g., README.md from root) to the submodule's docs
echo "Copying standard docs..."
cp "$ROOT_DIR/README.md" "${FULL_TARGET_PATH}/docs/README.md"

# Create crqs directory in the target submodule's docs
mkdir -p "${FULL_TARGET_PATH}/docs/crqs"

# Find and copy the specified CRQ file
CRQ_GLOB="${ROOT_DIR}/docs/crqs/CRQ_${CRQ_NUMBER}_*.md"
CRQ_FILE=""
for file in $CRQ_GLOB; do
  if [ -e "$file" ]; then
    CRQ_FILE="$file"
    break
  fi
done

if [ -n "$CRQ_FILE" ]; then
  echo "Copying $(basename "$CRQ_FILE")..."
  cp "$CRQ_FILE" "${FULL_TARGET_PATH}/docs/crqs/$(basename "$CRQ_FILE")"
else
  echo "Warning: CRQ_${CRQ_NUMBER}_*.md not found at ${ROOT_DIR}/docs/crqs/. Skipping copy."
fi

echo "Injection script finished."