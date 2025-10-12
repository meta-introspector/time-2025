let
  common = import ../../lib/common-imports.nix { };
  inherit (common) pkgs;
  inherit (common) lib;
  inherit (common) builtins;

  testUtils = import ../../lib/test-utils.nix { inherit pkgs lib builtins; };
  inherit (testUtils) dummyProjectRoot;

  time-2025-src = builtins.fetchTarball {
    url = "https://github.com/meta-introspector/time-2025/archive/e53d59001de6f67e513328a4602a24fa0956cf7c.tar.gz";
  };

  nixCodeIndexerModule = import (time-2025-src + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };
  nGramGeneratorModule = import (time-2025-src + "/10/01/docs/theory/n_gram_generator.nix") { inherit lib pkgs builtins; };

  # Call indexNixFiles to get the derivation
  nixFileIndex = nixCodeIndexerModule.indexNixFiles {
    path = dummyProjectRoot;
    projectRoot = dummyProjectRoot;
    name = "test-nix-file-index";
  };

  # Read the indexed files from the JSON output and parse it
  indexedFiles = builtins.fromJSON (builtins.readFile "${nixFileIndex}/nix-files.index.json");

  # Process each Nix file to extract 2-grams and their locations
  all2GramUsages = lib.flatten (lib.map
    (fileInfo: # For each indexed file
      let
        filePath = fileInfo.path; # Relative path of the Nix file
        tokens = nGramGeneratorModule.tokenizePath filePath;
        # Generate only 2-grams
        twoGrams = nGramGeneratorModule.generateNGrams { inherit tokens; nGramLengths = [ 2 ]; };
      in
      # For each 2-gram found in this file, create a usage entry
      lib.map
        (twoGram: {
          value = twoGram;
          inherit filePath; # Store filePath directly for grouping
        })
        twoGrams
    )
    indexedFiles);

in
builtins.toJSON all2GramUsages
