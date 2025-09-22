#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

FILE_PATH="$1"
TOP_N="${2:-10}" # Default to top 10 if not provided

if [ -z "$FILE_PATH" ]; then
    execute_cmd echo "Usage: $0 <html_file_path> [top_n_keywords]"
    exit 1
fi

# Remove HTML tags and extract words
execute_cmd bash -c "cat \"$FILE_PATH\" | \
 sed -E 's/<[^>]*>//g' | \
 grep -o -E '\\w+' | \
 tr '[:upper:]' '[:lower:]' | \
 sort | uniq -c | sort -nr | head -n \"$TOP_N\""

