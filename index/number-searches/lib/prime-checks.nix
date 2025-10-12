{
  pkgs, lib, numberSearcher, system
}:

let
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
                PRIME_STR = primeStr;
                RESULTS = searchResults;
              } ''
              #!/bin/bash
              echo "--- Search for $PRIME_STR completed. Results in $RESULTS ---"
              if [ -s "$RESULTS" ]; then
                echo "Found occurrences of $PRIME_STR."
                cat "$RESULTS"
              else
                echo "No occurrences of $PRIME_STR found."
              fi
            '');
in
primeSearchChecks
