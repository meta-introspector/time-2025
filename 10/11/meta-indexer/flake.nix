{
  description = "Nix flake for meta-indexing the data lattice, NAR-ifying keyword search results, and producing a new keyword map.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=source/github/meta-introspector/streamofrandom/2025"; # Project root
    };
    dataLatticeBuilder = {
      url = "path:../data-lattice-builder";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    narLocatorFlake = {
      url = "path:../nar-locator";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, dataLatticeBuilder, narLocatorFlake }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Get the data lattice from the dataLatticeBuilder flake
        dataLattice = dataLatticeBuilder.packages.${system}.default;

        # NAR-ify each keyword search result and place it in the binstore
        narifiedKeywordIndexes = lib.mapAttrs (extFileName: keywordAttrset: 
          lib.mapAttrs (keyword: searchResultsDerivation: 
            let
              ext = lib.strings.removeSuffix ".txt" extFileName;
              narName = "${ext}-${keyword}-index.txt";
            in
            narLocatorFlake.lib.${system}.locateAndArchiveStorePath {
              storePath = searchResultsDerivation;
              originalFilePath = narName;
              archiveType = "nar";
            }
          ) keywordAttrset
        ) dataLattice;

        # Flatten the nested attrset of narifiedKeywordIndexes
        flattenedNarifiedKeywordIndexes = lib.flatten (lib.attrValues narifiedKeywordIndexes);

        # Produce a new keyword map (list of all unique keywords searched)
        newKeywordMap = dataLatticeBuilder.lib.${system}.searchKeywords;

      in
      {
        packages.default = flattenedNarifiedKeywordIndexes;
        lib = {
          inherit flattenedNarifiedKeywordIndexes;
          inherit newKeywordMap;
        };
      }
    );
}