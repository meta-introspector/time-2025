# lib/generate-project-nix/generate.nix
#
# The main recursive function to scan the directory and build the nested attribute set.
# It traverses the file system, importing `.nix` files and recursing into directories.
# Returns { result = <nested_attrset>, errors = <list_of_errors> }.

{ lib, builtins, processEntry, evaluateNixFile, ... } @ args: # Accept dependencies as arguments

# The main function that takes the root path
path:
  let
    # Helper to read directory entries
    getDirectoryEntries = builtins.readDir path;

    # Process all entries in the current directory
    # Pass 'generate' (this function) for recursive calls
    processedEntries = lib.mapAttrs (name: type: processEntry { inherit lib generate evaluateNixFile path; } name type) getDirectoryEntries;

    # Aggregate values and errors from processed entries
    aggregatedResult = lib.foldlAttrs
      (acc: name: entry:
        { result = acc.result // (if entry.value != null then { ${name} = entry.value; } else {});
          errors = acc.errors ++ entry.errors;
        }
      ) { result = {}; errors = []; } processedEntries;
  in
  aggregatedResult
