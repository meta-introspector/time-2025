#!/usr/bin/env bash

# Remove HTML tags and extract words
cat wikipedia_cache/*.html |
 sed -E 's/<[^>]*>//g' |
 grep -o -E '\w+' |
 tr '[:upper:]' '[:lower:]' |
 sort | uniq -c | sort -nr
