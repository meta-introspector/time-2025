{
  description = "Flake to process collectedLocks and provide count and sample.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    collectedLocks = {
      url = "path:../001_collect_locks";
    };
  };

  outputs = { self, nixpkgs, flake-utils, collectedLocks, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Access the default package of collectedLocks, which is a derivation
        collectedLocksDerivation = collectedLocks.packages.${system}.default;

        # Create a derivation to read and process the JSON file
        processedCollectedLocks = pkgs.runCommand "collected-locks-data"
          {
            # Make the collectedLocksDerivation an input to this derivation
            collectedLocksInput = collectedLocksDerivation;
            nativeBuildInputs = [ pkgs.jq ]; # Use jq to parse JSON
          } ''
          mkdir -p $out
          # Read the JSON file from the input derivation
          cat $collectedLocksInput/all-flake-locks-data.json > $out/collected-locks.json

          # Construct the healthcheck-data.json using jq
          jq -n \
            --argjson count "$(jq '. | length' $out/collected-locks.json)" \
            --argjson sample "$(jq '.[0:3]' $out/collected-locks.json)" \
            '{count: $count, sample: $sample}' > $out/healthcheck-data.json
        '';

        # Read the healthcheck data from the processedCollectedLocks derivation
        healthcheckData = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile "${processedCollectedLocks}/healthcheck-data.json")); # Apply the fix

      in
      {
        packages.default = processedCollectedLocks; # Output the processed data
        checks.healthcheck = healthcheckData;
      }
    );
}
