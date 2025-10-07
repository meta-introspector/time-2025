# lib/generate-project-nix.nix
#
# This module orchestrates the dynamic scanning and evaluation of .nix files
# within the project, generating a nested attribute set representation.
# It composes smaller, atomic helper functions for clarity and testability.

{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) lib; # Define lib here

  # Import nix-stdlib for error handling and type checking utilities
  nix-stdlib = (import "github:meta-introspector/nix-stdlib?ref=feature/CRQ-016-nixify").lib { inherit pkgs lib; };
  inherit (nix-stdlib) errors;
  inherit (nix-stdlib) types;

  # Define a recursive attribute set for all helper functions
  # This allows them to refer to each other
  helpers = rec {
    tryEval = import (builtins.fetchTarball "github:meta-introspector/time-2025?ref=feature/foaf&dir=lib/generate-project-nix/tryEval.nix") { inherit builtins; };
    evaluateNixFile = import (builtins.fetchTarball "github:meta-introspector/time-2025?ref=feature/foaf&dir=lib/generate-project-nix/evaluateNixFile.nix") { inherit pkgs lib builtins tryEval errors types; };
    processEntry = import (builtins.fetchTarball "github:meta-introspector/time-2025?ref=feature/foaf&dir=lib/generate-project-nix/processEntry.nix") {
      inherit lib evaluateNixFile errors types;
      inherit (helpers) generate; # Explicitly pass the recursive generate
    };
    generate = import (builtins.fetchTarball "github:meta-introspector/time-2025?ref=feature/foaf&dir=lib/generate-project-nix/generate.nix") {
      inherit lib builtins evaluateNixFile errors types;
      inherit (helpers) processEntry; # Explicitly pass the recursive processEntry
      inherit (helpers) generate; # Explicitly pass the recursive generate to itself
    };
  };

in

# The top-level function of the module, which takes the root path to scan.
# Returns { result = <nested_attrset>, errors = <list_of_errors> }.
{ path }:
  helpers.generate path
