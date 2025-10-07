#!/usr/bin/env bash

# This script analyzes the ngram_index.json file to find the top 10 most frequent ngrams.
# It uses the Nix expression in analyze_ngrams.nix to perform the analysis.
# The output is formatted as JSON.

# --- WARNING ---
# This script will cause Nix to read the entire ngram_index.json file (which is very large) into memory.
# This may be slow and memory-intensive.

nix-instantiate --eval analyze_ngrams.nix --json | jq .
