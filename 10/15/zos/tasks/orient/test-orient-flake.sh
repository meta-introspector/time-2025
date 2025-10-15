#!/usr/bin/env bash

# SC2154: These variables are referenced but not assigned within the script.
# They are expected to be passed as environment variables by the Makefile.
# shellcheck disable=SC2154

set -euo pipefail

nix eval --raw "$ORIENT_FLAKE_PATH"#default --argfile args ./orient-eval-args.nix --apply 'x: x args' --no-write-lock-file 
