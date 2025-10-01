#!/usr/bin/env bash
set -euo pipefail

GITHUB_URL="$1"

if [ -z "$GITHUB_URL" ]; then
    echo "Error: GITHUB_URL is not set. Usage: $0 \"https://github.com/owner/repo/blob/branch/path/to/file\"" >&2
    exit 1
fi

echo "Locating local file for URL: $GITHUB_URL..."

# Extract owner, repo, and path within repo
OWNER=$(echo "$GITHUB_URL" | awk -F'/' '{print $4}')
REPO=$(echo "$GITHUB_URL" | awk -F'/' '{print $5}')
# Remove "blob/branch/" part and get the rest of the path
REPO_PATH=$(echo "$GITHUB_URL" | sed -E 's|https://github.com/[^/]+/[^/]+/blob/[^/]+/||')

PROJECT_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2"
LOCAL_GITHUB_ROOT="$PROJECT_ROOT/source/github"

LOCAL_FILE_PATH="$LOCAL_GITHUB_ROOT/$OWNER/$REPO/$REPO_PATH"

if [ -f "$LOCAL_FILE_PATH" ]; then
    echo "Local file found: $LOCAL_FILE_PATH"
else
    echo "Local file not found at: $LOCAL_FILE_PATH"
fi
echo "Location attempt complete."

