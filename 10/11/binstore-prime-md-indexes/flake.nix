{
  description = "Nix flake to dynamically create NAR files indexing Markdown files containing Monster Group primes under 71.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    numberSearcher = {
      url = "path:../../number-searcher"; # Relative path to the generic number-searcher flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    narLocatorFlake = {
      url = "path:../nar-locator"; # Relative path to the nar-locator flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, numberSearcher, narLocatorFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # Monster Group primes under 71
        primesUnder71 = [ 2 3 5 7 11 13 17 19 23 29 31 41 47 59 ];

        filePatterns = [ "**/*.md" ]; # Only Markdown files

        # Dynamically generate NAR indices for each prime
        primeMdIndexes = lib.genAttrs (lib.map toString primesUnder71) (primeStr:
          let
            searchNumber = builtins.fromJSON primeStr;
            # Get the list of Markdown files containing the current prime
            mdFilesWithPrime = numberSearcher.lib.${system}.searchNumberInFiles {
              number = searchNumber;
              inherit filePatterns;
            };

            # Create a derivation that outputs this list as a text file
            mdFilesWithPrimeList = pkgs.runCommand "md-files-with-${primeStr}-list"
              {
                nativeBuildInputs = [ pkgs.bash ];
                results = mdFilesWithPrime;
              } ''
              cp $results $out
            '';

            # NAR-ify this list and place it in the binstore
            narifiedIndex = narLocatorFlake.lib.${system}.locateAndArchiveStorePath {
              storePath = mdFilesWithPrimeList;
              originalFilePath = "${primeStr}-md-index.txt"; # Canonical name for the index NAR
              archiveType = "nar";
            };
          in
          narifiedIndex
        );

      in
      {
        packages = primeMdIndexes;
        lib.primeMdIndexes = primeMdIndexes;
      }
    );
}
