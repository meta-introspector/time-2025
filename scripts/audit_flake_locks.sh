#!/usr/bin/env bash

# Script to audit flake.lock files, extract fields, and count unique occurrences.

# Ensure jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install it (e.g., nix-shell -p jq)."
    exit 1
fi

# Initialize associative arrays to store counts for each field
declare -A urls
declare -A narHashes
declare -A owners
declare -A repos
declare -A revs
declare -A types

# Find all flake.lock files and process them
find . -name "flake.lock" -print0 | while read -r -d $'' lock_file
do
    echo "Processing: $lock_file"
    # Extract fields using jq
    # Iterate over each node in the flake.lock file
    jq -f 10/12/audit-flakes/audit.jq "$lock_file" | while IFS=$'\t' read -r url narHash owner repo rev type; do
        # Increment counts
        ((urls["$url"]++))
        ((narHashes["$narHash"]++))
        ((owners["$owner"]++))
        ((repos["$repo"]++))
        ((revs["$rev"]++))
        ((types["$type"]++))
    done
done

echo "\n--- Unique URLs and their counts ---"
for key in "${!urls[@]}"
do
    echo "${urls[$key]} $key"
done | sort -rn

echo "\n--- Unique NAR Hashes and their counts ---"
for key in "${!narHashes[@]}"
do
    echo "${narHashes[$key]} $key"
done | sort -rn

echo "\n--- Unique Owners and their counts ---"
for key in "${!owners[@]}"
do
    echo "${owners[$key]} $key"
done | sort -rn

echo "\n--- Unique Repos and their counts ---"
for key in "${!repos[@]}"
do
    echo "${repos[$key]} $key"
done | sort -rn

echo "\n--- Unique Revisions and their counts ---"
for key in "${!revs[@]}"
do
    echo "${revs[$key]} $key"
done | sort -rn

echo "\n--- Unique Types and their counts ---"
for key in "${!types[@]}"
do
    echo "${types[$key]} $key"
done | sort -rn
