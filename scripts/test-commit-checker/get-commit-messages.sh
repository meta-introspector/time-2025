#!/usr/bin/env bash

# Fetches the last N commit messages, including hash, subject, and body.
# Each commit entry is separated by ---COMMIT-DELIMITER---\n
# Usage: get-commit-messages.sh <NUM_COMMITS>

set -euo pipefail

NUM_COMMITS="$1"

# --pretty=format: combines hash (%H), subject (%s), and body (%b)
# %x00 is used to separate the fields within a commit, but we'll use a custom delimiter for clarity
# %n is a newline
# We'll use a custom delimiter for the entire commit entry for easier parsing in the main script
git log -n "${NUM_COMMITS}" --pretty=format:"%H---FIELD-DELIMITER---%s---FIELD-DELIMITER---%b%n---COMMIT-DELIMITER---"
