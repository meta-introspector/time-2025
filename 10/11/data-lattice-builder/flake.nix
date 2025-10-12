{
  description = "Nix flake for building a lattice of data files based on file indexing, splitting, and keyword searching.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow"; # Project root
    };
    fileIndexer = {
      url = "path:../file-indexer";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    fileSplitter = {
      url = "path:../file-splitter";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    keywordSearcher = {
      url = "path:../keyword-searcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, fileIndexer, fileSplitter, keywordSearcher }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # 1. Index all files in the project
        allFilesIndex = fileIndexer.lib.${system}.indexAllFiles { path = self; };

        # 2. Split files by extension
        splitFilesByExt = fileSplitter.lib.${system}.splitFilesByExtension { filesList = allFilesIndex; };

        # Define keywords to search for (example keywords)
        searchKeywords = [ "flake" "inputs" "outputs" "lib" "pkgs" "system" "builtins" "runCommand" ];

        # 3. Search for keywords in each chunked file, creating a nested attribute set (lattice)
        dataLattice = lib.mapAttrs
          (extFileName: type:
            if type == "regular" then # Only process regular files (the chunked lists)
              let
                ext = lib.strings.removeSuffix ".txt" extFileName;
                chunkFilePath = "${splitFilesByExt}/chunks/${extFileName}";
              in
              lib.genAttrs searchKeywords (keyword:
                keywordSearcher.lib.${system}.searchKeywordInFiles {
                  filesList = chunkFilePath;
                  inherit keyword;
                }
              )
            else null # Ignore directories or other types
          )
          (lib.readDir "${splitFilesByExt}/chunks");

        # Filter out null values from dataLattice (for non-regular files)
        filteredDataLattice = lib.filterAttrs (name: value: value != null) dataLattice;

      in
      {
        packages.default = filteredDataLattice;
        lib.dataLattice = filteredDataLattice;
      }
    );
}
