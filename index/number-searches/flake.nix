{
  description = "Nix flake to dynamically generate search checks for Monster Group primes in various file types.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    numberSearcher = {
      url = "path:../../10/11/number-searcher"; # Relative path to the generic number-searcher flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, numberSearcher }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Monster Group primes to search for
        monsterPrimes = [ 2 3 5 7 11 13 17 19 23 29 31 41 47 59 71 ];

        # File patterns to search within
        filePatterns = [ "**/*.md" "**/*.nix" "**/Makefile" "**/*.sh" ];

        # Dynamically generate checks for each prime
        primeSearchChecks = lib.genAttrs (lib.map toString monsterPrimes)
          (primeStr:
            let
              searchNumber = builtins.fromJSON primeStr;
              searchResults = numberSearcher.lib.${system}.searchNumberInFiles {
                number = searchNumber;
                inherit filePatterns;
              };
            in
            pkgs.runCommand "check-search-results-${primeStr}"
              {
                nativeBuildInputs = [ pkgs.bash ];
                results = searchResults;
              }
            # see script.sh
          );

      in
      {
        checks = primeSearchChecks;
      }
    );
}
