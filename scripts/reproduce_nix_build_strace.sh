#!/usr/bin/env bash

echo "Running strace for nix build ./flakes/crq-search/parser, output to nix_build_strace.log"
strace -o nix_build_strace.log nix build ./flakes/crq-search/parser
echo "Done. Check nix_build_strace.log for details."
