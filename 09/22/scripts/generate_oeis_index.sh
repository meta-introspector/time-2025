#!/usr/bin/env bash

# Ensure the index directory exists
mkdir -p /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/index

# Run grep to find "oeis" in the project's index directory and save to oeis.txt
grep -r -i oeis /data/data/com.termux.nix/files/home/pick-up-nix2/index/ > /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/index/oeis.txt
