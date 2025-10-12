# lib/nix-templates/safe-eval.nix
# Abstraction for safely evaluating a Nix file and returning a ProcessedEntry.
{ lib, builtins, types, errorConstructors, errorHandler, nix-stdlib, ... }:

file:
let
  # 1. Safely evaluate the file using nix-stdlib's eval
  evalResult = nix-stdlib.lib.nix.eval (import file);

in
evalResult
