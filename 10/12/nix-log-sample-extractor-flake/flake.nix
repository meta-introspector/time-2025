{
  description = "A flake to extract samples from Nix native JSON logs and generate pure test cases.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    logAnalysisPipeline.url = "github:meta-introspector/time-2025?dir=09/25/log_analyzer/flakes/log-analysis-pipeline&ref=feature/aimyc-001-cleanbench";
  };

  outputs = { self, nixpkgs, flake-utils, logAnalysisPipeline } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        sampleGenerator = import ./lib/sample-generator.nix {
          inherit lib pkgs logAnalysisPipeline system;
        };

        # The app is now a simple placeholder that tells the user how to generate samples
        sampleExtractorApp = {
          type = "app";
          program = pkgs.writeScript "sample-extractor-app" ''
            #!${pkgs.bash}/bin/bash
            echo "This app is a placeholder. Please use 'nix build .#samples' to generate samples."
            exit 1
          '';
        };

        # Define the samples output as a derivation
        generatedSamples =
          let
            # Assume develop2.json is at the root of this flake for now
            logFile = "${self}/develop2.json";
            # Get the list of sample definitions from the pure Nix function
            sampleDefinitions = sampleGenerator.extractSamplesFromLogFile {
              logFilePath = logFile;
              maxSamples = 20;
            };
            # Create individual derivations for each sample file
            sampleFileDerivations = lib.map (sample:
              pkgs.writeText sample.sampleFilename sample.sampleContent
            ) sampleDefinitions;
          in
          # Symlink join all generated sample files into a single output directory
          pkgs.symlinkJoin {
            name = "extracted-nix-log-samples";
            paths = sampleFileDerivations;
          };

      in
      {
        apps.default = sampleExtractorApp;
        packages.samples = generatedSamples; # Expose the generated samples as a package

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nix
            jq
            gnugrep
            coreutils # For sha256sum
          ];
        };
      }
    );
}
