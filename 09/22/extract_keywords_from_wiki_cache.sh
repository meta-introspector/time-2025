#!/usr/bin/env bash

FILE_PATH="$1"
TOP_N="${2:-10}" # Default to top 10 if not provided

if [ -z "$FILE_PATH" ]; then
    echo "Usage: $0 <html_file_path> [top_n_keywords]"
    exit 1
fi

# Remove HTML tags and extract words
cat "$FILE_PATH" |
 sed -E 's/<[^>]*>//g' |
 grep -o -E '\w+' |
 tr '[:upper:]' '[:lower:]' |
 sort | uniq -c | sort -nr | head -n "$TOP_N"

