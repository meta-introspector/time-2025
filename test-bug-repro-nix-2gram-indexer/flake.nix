{
  description = "Top-level flake for 2-gram indexer vibes.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    time2025-src.url = "github:meta-introspector/time-2025?ref=feature/foaf"; # Source for nixCodeIndexerModule and nGramGeneratorModule
    rootFlake.url = "github:meta-introspector/streamofrandom?ref=feature/foaf";
  };

  outputs = { self, nixpkgs, flake-utils, time2025-src, rootFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        common = rootFlake.lib.common-imports { inherit system; };
        inherit (common) pkgs;
        inherit (common) lib;
        inherit (common) builtins;

        nixCodeIndexerModule = import (time2025-src + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };
        nGramGeneratorModule = import (time2025-src + "/10/01/docs/theory/n_gram_generator.nix") { inherit lib pkgs builtins; };

        # Vibe 1: Raw Data Ingestion/Indexing
        vibe1 = { projectRoot, name ? "vibe1-nix-indexer" }:
          let
            nixFileIndexDerivation = nixCodeIndexerModule.indexNixFiles {
              path = projectRoot;
              inherit projectRoot;
              name = "${name}-nix-file-index";
            };
          in
          pkgs.runCommand "${name}-output" {
            inherit nixFileIndexDerivation;
          } "ln -s $nixFileIndexDerivation $out";

      # Vibe 2: Segmentation/JSON Extraction
      vibe2 = { vibe1Output, name ? "vibe2-json-extractor" }:
        let
          indexedFilesJsonDerivation = pkgs.runCommand "${name}-indexed-files-json" {
            inherit vibe1Output;
            __impure = true;
            passAsFile = [ "vibe1Output" ];
          } "cat $vibe1OutputPath/nix-files.index.json > $out";
        in
        indexedFilesJsonDerivation;

      in
      {
        packages.vibe1 = vibe1;
        packages.vibe2 = vibe2;
      }
    );
}