#!/usr/bin/env bash

REPO_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025"

# Get all .nix files
NIX_FILES=$(find "$REPO_ROOT" -type f -name "*.nix" -print)

# Create a temporary file to store file and their last commit dates
TEMP_FILE=$(mktemp)

# For each .nix file, get its last commit date and store in the temp file
for file in $NIX_FILES;
do
    # Get the last commit date for the file in ISO format
    LAST_COMMIT_DATE=$(git -C "$REPO_ROOT" log -1 --format="%cd" --date=iso -- "$file" 2>/dev/null)
    if [ -n "$LAST_COMMIT_DATE" ]; then
        echo "$LAST_COMMIT_DATE $file" >> "$TEMP_FILE"
    else
        # If not in git history, use modification time (fallback)
        MOD_DATE=$(date -r "$file" +%Y-%m-%d\ %H:%M:%S\ %z)
        echo "$MOD_DATE $file" >> "$TEMP_FILE"
    fi
done

# Sort the files by date (newest first) and extract only the file paths
sort -r -k1,2 "$TEMP_FILE" | awk '{print $NF}' > "$REPO_ROOT/index/nix_files.txt"

# Clean up the temporary file
rm "$TEMP_FILE"

echo "Generated sorted list of .nix files in $REPO_ROOT/index/nix_files.txt"
