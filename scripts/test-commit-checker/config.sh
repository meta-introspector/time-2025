#!/usr/bin/env bash

# Configuration for the commit message checker test script.

# shellcheck disable=SC2034  # NUM_COMMITS is used by scripts that source this config
NUM_COMMITS=${1:-20} # Default to checking the last 20 commits

# Path to the helper script that checks a single commit message
# shellcheck disable=SC2034  # CHECK_SINGLE_MSG_SCRIPT is used by scripts that source this config
CHECK_SINGLE_MSG_SCRIPT="./scripts/check-single-commit-msg.sh"