{
  lib,
  pkgs,
  builtins,
  nixCodeIndexerModule,
  nGramGeneratorModule,
  ...
}:

let
  generate2GramIndexStep4Module = import ./nix_2gram_indexer_step4.nix { inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule; };

  generate2GramIndexStep5 = {
    projectRoot, # The root path of the project to index
    name ? "nix-2gram-index",
  }:
  let
    indexedFiles = generate2GramIndexStep4Module.generate2GramIndexStep4 {
      projectRoot = projectRoot;
      name = name;
    };

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
  in
  all2GramUsages;

in
{
  generate2GramIndexStep5 = generate2GramIndexStep5;
}
