#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

execute_cmd bash -c "grep -h -oE 'https://en.wikipedia.org/wiki/[^[:space:]]+' *_tiktok_tutorial.md | sort -u"