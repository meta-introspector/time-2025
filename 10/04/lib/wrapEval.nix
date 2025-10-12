# lib/generate-project-nix/wrapEval.nix
# This module wraps the core evaluation logic.

{ file, builtins, ... }:

builtins.tryEval (import file)
