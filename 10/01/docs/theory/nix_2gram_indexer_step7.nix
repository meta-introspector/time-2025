{
  lib,
  pkgs,
  builtins,
  nixCodeIndexerModule,
  nGramGeneratorModule,
  ...
}:

let
  generate2GramIndexStep6Module = import ./nix_2gram_indexer_step6.nix { inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule; };

  TwoGramInstanceSchema = {
    value = null; # The 2-gram string (e.g., "flake_inputs")
    count = 0;    # Number of times this 2-gram is used
    uniquePaths = []; # A deduplicated list of file paths where this 2-gram is found
    pathSetHash = null; # A hash representing the unique set of paths (conceptual prime factorization)
  };

  generate2GramIndexStep7 = {
    projectRoot, # The root path of the project to index
    name ? "nix-2gram-index",
  }:
  let
    grouped2Grams = generate2GramIndexStep6Module.generate2GramIndexStep6 {
      projectRoot = projectRoot;
      name = name;
    };

    twoGramIndex = lib.mapAttrs (twoGramValue: usages: # For each unique 2-gram
      let
        # Get unique file paths where this 2-gram is used
        uniquePaths = lib.unique (lib.map (usage: usage.filePath) usages);
        # Sort paths for consistent hashing of the set
        sortedUniquePaths = lib.sort lib.compareStrings uniquePaths;
        # Hash the sorted unique paths to get a unique identifier for the set
        # This serves as our conceptual "nested tuple based on prime factorization"
        pathSetHash = builtins.hashString "sha256" (lib.strings.concatStringsSep ";" sortedUniquePaths);
      in
      TwoGramInstanceSchema // {
        value = twoGramValue;
        count = builtins.length usages;
        uniquePaths = sortedUniquePaths;
        pathSetHash = pathSetHash;
      }
    ) grouped2Grams;
  in
  twoGramIndex;

in
{
  inherit generate2GramIndexStep7;
}
