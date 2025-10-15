{
  description = "A flake to test the 002_process_locks flake.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    processLocks = {
      url = "path:."; # Reference to the current 002_process_locks flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.collectLocks.follows = "collectLocks"; # Follow the collectLocks input from the main flake
      inputs.bagOfWordsGenerator.follows = "bagOfWordsGenerator"; # Follow the bagOfWordsGenerator input from the main flake
    };
    collectLocks.url = "path:../001_collect_locks"; # Explicitly define collectLocks input
    bagOfWordsGenerator = {
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=flakes/bag-of-words-generator";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, flake-utils, processLocks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
      {
        checks.testProcessedFiles = pkgs.runCommand "test-processed-files"
          {
            allLockFileSummaries = processLocks.packages.${system}.default; # Path to the aggregated output
            nativeBuildInputs = [ pkgs.jq ];
          }
          ''
            # Ensure the aggregated JSON is valid
            jq . "$allLockFileSummaries/all-lock-file-summaries.json"

            # Check for expected fields in the first entry (assuming at least one entry)
            jq -e '.[0] | has("nixFilePath")' "$allLockFileSummaries/all-lock-file-summaries.json"
            jq -e '.[0] | has("lockFilePath")' "$allLockFileSummaries/all-lock-file-summaries.json"
            jq -e '.[0] | has("bagOfWords")' "$allLockFileSummaries/all-lock-file-summaries.json"

            echo "Processed file info test passed."
          '';
      });
}
