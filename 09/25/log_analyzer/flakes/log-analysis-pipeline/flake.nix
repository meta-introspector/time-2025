{
  description = "A Nix-flake for analyzing build telemetry logs using log_analyzer";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    time-2025-flake.url = "github:meta-introspector/time-2025?dir=09&ref=feature/foaf";

    log-analyzer-flake.url = "github:meta-introspector/time-2025?dir=09/25/log_analyzer&ref=feature/foaf";
    build-time-gemini-capture-flake.url = "github:meta-introspector/time-2025?dir=09/27/7-concepts/6-qa-testing/tests/2025-01-27-build-time-gemini-capture&ref=feature/foaf";
    rootLib.follows = "rootFlake/lib";
  };

  outputs = { self, nixpkgs, flake-utils, time-2025-flake, log-analyzer-flake, build-time-gemini-capture-flake, rootLib } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        common = rootLib.common-imports { inherit system; };

        inherit (common) builtins;

        time-2025-src = builtins.fetchGit {
          url = "https://github.com/meta-introspector/time-2025";
          ref = "feature/foaf";
          rev = "8ce716fb9fa4e20d32687c9edb75adcccf501a02"; # Updated rev after committing fix to time-2025
        };

        # Import modules from meta-introspector-flake's source
        secretScannerModule = import "${time-2025-src}/10/01/docs/theory/secret_scanner.nix" { inherit lib pkgs builtins; };
        nix2gramIndexerModule = import "${time-2025-src}/10/01/docs/theory/nix_2gram_indexer.nix" { inherit lib pkgs builtins nGramGeneratorModule nixCodeIndexerModule; };
        nGramGeneratorModule = import "${time-2025-src}/10/01/docs/theory/n_gram_generator.nix" { inherit lib pkgs builtins; };
        nixCodeIndexerModule = import "${time-2025-src}/10/01/docs/theory/nix_code_indexer.nix" { inherit lib pkgs builtins; };
        twoGramReportGeneratorModule = import "${time-2025-src}/10/01/docs/theory/2gram_report_generator.nix" { inherit lib pkgs builtins; };

        # Build the buildTimeTelemetry derivation to get its output
        buildTimeTelemetryOutput = build-time-gemini-capture-flake.packages.${system}.default;

        # Helper functions (now imported from ./lib/helpers.nix)
        helpers = import ./lib/helpers.nix {
          inherit lib pkgs system time-2025-flake secretScannerModule log-analyzer-flake build-time-gemini-capture-flake;
        };

        # Import packages definitions (now imported from ./packages/analysis.nix)
        analysisPackages = import ./packages/analysis.nix {
          inherit lib pkgs self system helpers time-2025-flake nix2gramIndexerModule twoGramReportGeneratorModule;
        };

      in
      {
        packages = analysisPackages;

        lib = helpers; # Expose helpers in lib
      }
    );
}
