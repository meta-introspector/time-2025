#!/usr/bin/env bash

# strace_file is intended for future use in generating unique log filenames.
strace_file="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
#strace -f -o logs/strace_${strace_file}.txt -s 9999
~/gemini-cli/bundle/gemini.js --output-format json \
			      --approval-mode yolo \
			      --model gemini-2.5-flash \
			      --checkpointing \
			      --debug \
     			      --include-directories ~/today/ \
			      --include-directories ~/nix/ai-ml-zk-ops/flakes/ \
			      --include-directories ~/nix/vendor/external/gemini-cli/ \
			      --include-directories ~/nix/ \
			      --prompt "$@" 
