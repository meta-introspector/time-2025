#!/usr/bin/env bash

primeStr=""
results=""

echo "Search for ${primeStr} completed. Results in $results"
if [ -s "$results" ]; then
    echo "Found occurrences of ${primeStr}."
    cat "$results"
else
    echo "No occurrences of ${primeStr} found."
fi
