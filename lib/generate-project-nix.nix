# lib/generate-project-nix.nix
#
# This module orchestrates the dynamic scanning and evaluation of .nix files
# within the project, generating a nested attribute set representation.
# It composes smaller, atomic helper functions for clarity and testability.

{ pkgs ? import <nixpkgs> {} }:

let
  lib = pkgs.lib; # Define lib here
  builtins = builtins; # Make builtins available

  # Define a recursive attribute set for all helper functions
  # This allows them to refer to each other
  helpers = rec {
    tryEval = import ./generate-project-nix/tryEval.nix { inherit builtins; };
    evaluateNixFile = import ./generate-project-nix/evaluateNixFile.nix { inherit pkgs lib builtins tryEval; };
    processEntry = import ./generate-project-nix/processEntry.nix { inherit lib generate evaluateNixFile; };
    generate = import ./generate-project-nix/generate.nix { inherit lib builtins processEntry evaluateNixFile; };
  };

in

# The top-level function of the module, which takes the root path to scan.
# Returns { result = <nested_attrset>, errors = <list_of_errors> }.
{ path }:
  helpers.generate path
