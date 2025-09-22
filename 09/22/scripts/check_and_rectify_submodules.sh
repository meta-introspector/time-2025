#!/usr/bin/env bash

# This script checks the origin and branch of all Git submodules
# and rectifies them to point to meta-introspector forks and the
# feature/CRQ-016-nixify-workflow branch if they are not already.

set -euo pipefail

SUBMODULE_STATUS_FILE="index/submodules_status.txt"
VEND_FORK_SCRIPT="scripts/vendorize_and_fork_submodule.sh"
TARGET_BRANCH="feature/CRQ-016-nixify-workflow"
META_INTROSPECTOR_ORG="meta-introspector"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

if [[ ! -f "${SUBMODULE_STATUS_FILE}" ]]; then
  log "Error: ${SUBMODULE_STATUS_FILE} not found. Please run generate_submodule_status.sh first."
  exit 1
fi

log "Starting submodule origin and branch rectification."

# Read submodule status file line by line
while IFS= read -r line; do
  if [[ "$line" =~ ^Entering\ '(.+)' ]]; then
    SUBMODULE_PATH="${BASH_REMATCH[1]}"
    log "Processing submodule: ${SUBMODULE_PATH}"

    # Get current remote URL
    CURRENT_URL=$(git -C "${SUBMODULE_PATH}" remote get-url origin 2>/dev/null || echo "")
    
    # Get current branch
    CURRENT_BRANCH=$(git -C "${SUBMODULE_PATH}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

    IS_META_INTROSPECTOR_ORIGIN=false
    if [[ "$CURRENT_URL" =~ ^https://github.com/${META_INTROSPECTOR_ORG}/ ]]; then
      IS_META_INTROSPECTOR_ORIGIN=true
    fi

    IS_ON_TARGET_BRANCH=false
    if [[ "$CURRENT_BRANCH" == "${TARGET_BRANCH}" ]]; then
      IS_ON_TARGET_BRANCH=true
    fi

    if ! "${IS_META_INTROSPECTOR_ORIGIN}" || ! "${IS_ON_TARGET_BRANCH}"; then
      log "  Rectifying submodule: ${SUBMODULE_PATH}"
      log "    Current URL: ${CURRENT_URL}"
      log "    Current Branch: ${CURRENT_BRANCH}"

      # Extract original repo URL if not meta-introspector, or assume it if it is.
      # This is a heuristic; a more robust solution might involve a mapping.
      ORIGINAL_REPO_URL=""
      if "${IS_META_INTROSPECTOR_ORIGIN}"; then
        # If it's already meta-introspector, assume the original was the same name under NixOS or similar
        # This is a simplification for now. A proper mapping would be better.
        REPO_BASENAME=$(basename "${CURRENT_URL}" .git)
        # Heuristic: if it's a nixpkgs fork, assume original was NixOS/nixpkgs
        if [[ "$REPO_BASENAME" == "nixpkgs" ]]; then
          ORIGINAL_REPO_URL="https://github.com/NixOS/nixpkgs"
        else
          # Fallback to assuming the original was also meta-introspector, which means it's already forked
          ORIGINAL_REPO_URL="${CURRENT_URL}"
        fi
      else
        ORIGINAL_REPO_URL="${CURRENT_URL}"
      fi

      # Run the vendorize and fork script
      # Note: This script expects the original repo URL, not the current one if it's wrong.
      # This part needs careful consideration if the original URL is truly unknown.
      # For now, we'll pass the current URL and let vendorize_and_fork_submodule.sh handle it.
      # It will attempt to fork if not already forked.
      "${VEND_FORK_SCRIPT}" "${ORIGINAL_REPO_URL}" "${SUBMODULE_PATH}"

    else
      log "  Submodule ${SUBMODULE_PATH} is already correctly configured."
    fi
  fi
done < "${SUBMODULE_STATUS_FILE}"

log "Submodule origin and branch rectification complete."
