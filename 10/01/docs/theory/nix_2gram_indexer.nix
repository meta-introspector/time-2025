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
  generate2GramIndex = {
    projectRoot, # The root path of the project to index
    name ? "nix-2gram-index",
  }:
  let
    # First, index all Nix files in the project
    nixFileIndex = nixCodeIndexerModule.indexNixFiles {
      path = projectRoot;
      projectRoot = projectRoot; # Pass projectRoot to the indexer
      name = "${name}-nix-file-index";
    };

    # Read the indexed files from the JSON output
    indexedFiles = builtins.fromJSON (builtins.readFile "${nixFileIndex}/nix-files.index.json");

    # Process each Nix file to extract 2-grams and their locations
    all2GramUsages = lib.flatten (lib.map (fileInfo: # For each indexed file
      let
        filePath = fileInfo.path; # Relative path of the Nix file
        tokens = nGramGeneratorModule.tokenizePath filePath;
        # Generate only 2-grams
        twoGrams = nGramGeneratorModule.generateNGrams { tokens = tokens; nGramLengths = [ 2 ]; };
      in
      # For each 2-gram found in this file, create a usage entry
      lib.map (twoGram: {
        value = twoGram;
        filePath = filePath; # Store filePath directly for grouping
      }) twoGrams
    ) indexedFiles);

    # Group usages by 2-gram value to build the index
    grouped2Grams = lib.groupBy (usage: usage.value) all2GramUsages;

    # Convert grouped data into the TwoGramInstanceSchema structure
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

    # Create a derivation to output the generated 2-gram index as JSON
    indexOutput = pkgs.runCommand name {
      inherit twoGramIndex;
    }
    '''
      mkdir -p $out
      echo "${builtins.toJSON twoGramIndex}" > $out/nix-2gram-index.json
      echo "Generated 2-gram index for Nix file paths in $out/nix-2gram-index.json" >&2
    '';

  in
  indexOutput;

in
{
  generate2GramIndex = generate2GramIndex;
  TwoGramInstanceSchema = TwoGramInstanceSchema; # Export the type definition
  UsageLocationSchema = UsageLocationSchema;     # Export the type definition
}
