# lib/generate-project-nix/generate.nix
#
# The main recursive function to scan the directory and build the nested attribute set.
# It traverses the file system, importing `.nix` files and recursing into directories.
# Returns { result = <nested_attrset>, errors = <list_of_errors> }.

{ lib, builtins, processEntry, evaluateNixFile, errors, types, ... } @ args: # Accept dependencies as arguments

# The main function that takes the root path
path:
let
  # Helper to read directory entries
  getDirectoryEntries = builtins.readDir path;

  # Process all entries in the current directory
  # Pass 'generate' (this function) for recursive calls
  processedEntries = lib.mapAttrs (name: type: (processEntry path) name type) getDirectoryEntries;

  # Aggregate values and errors from processed entries
  aggregatedResult = lib.foldlAttrs
    (import (builtins.fetchTarball "github:meta-introspector/time-2025?ref=feature/foaf&dir=10/04/lib/fold-accumulator.nix") { inherit lib types; })
    { result = { }; errors = [ ]; }
    processedEntries;
in
aggregatedResult
