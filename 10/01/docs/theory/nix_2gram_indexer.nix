{
  lib,
  pkgs,
  builtins,
  nixCodeIndexerModule,
  nGramGeneratorModule,
  ...
}:

let
  # Define the structure for a 2-gram instance
  TwoGramInstanceSchema = {
    value = null; # The 2-gram string (e.g., "flake_inputs")
    count = 0;    # Number of times this 2-gram is used
    uniquePaths = []; # A deduplicated list of file paths where this 2-gram is found
    pathSetHash = null; # A hash representing the unique set of paths (conceptual prime factorization)
  };

  # Define the structure for a usage location (no longer directly used in TwoGramInstanceSchema.usages)
  UsageLocationSchema = {
    filePath = null; # Path to the Nix file where the 2-gram is found
    # Conceptual: line number, column, or surrounding context could be added here
  };

  # A function to generate an index of 2-grams from Nix file paths, with usage pointers.
  generate2GramIndexStep8Module = import ./nix_2gram_indexer_step8.nix { inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule; };

  generate2GramIndex = {
    projectRoot, # The root path of the project to index
    name ? "nix-2gram-index",
  }:
  generate2GramIndexStep8Module.generate2GramIndexStep8 {
    projectRoot = projectRoot;
    name = name;
  };

in
{
  generate2GramIndex = generate2GramIndex;
  TwoGramInstanceSchema = TwoGramInstanceSchema; # Export the type definition
  UsageLocationSchema = UsageLocationSchema;     # Export the type definition
}