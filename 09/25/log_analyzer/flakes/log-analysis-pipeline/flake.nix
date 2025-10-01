{
  description = "A Nix-flake for analyzing build telemetry logs using log_analyzer";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    meta-introspector-flake.url = "github:meta-introspector/time-2025?dir=09&ref=feature/foaf";
    log-analyzer-flake.url = "github:meta-introspector/time-2025?dir=09/25/log_analyzer&ref=feature/foaf";
  };

  outputs = { self, nixpkgs, flake-utils, meta-introspector-flake, log-analyzer-flake } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Import modules from meta-introspector-flake's source
        secretScannerModule = import "${meta-introspector-flake}/2025/10/01/docs/theory/secret_scanner.nix" { inherit lib pkgs; };
        nix2gramIndexerModule = import "${meta-introspector-flake}/2025/10/01/docs/theory/nix_2gram_indexer.nix" { inherit lib pkgs; };
        nGramGeneratorModule = import "${meta-introspector-flake}/2025/10/01/docs/theory/n_gram_generator.nix" { inherit lib pkgs; };
        twoGramReportGeneratorModule = import "${meta-introspector-flake}/2025/10/01/docs/theory/2gram_report_generator.nix" { inherit lib pkgs; };

        # Build the buildTimeTelemetry derivation to get its output
        buildTimeTelemetryOutput = meta-introspector-flake.packages.${system}.build-telemetry-flake.packages.${system}.default;

        # Helper functions (now imported from ./lib/helpers.nix)
        helpers = import ./lib/helpers.nix {
          inherit lib pkgs system meta-introspector-flake secretScannerModule log-analyzer-flake;
        };

        # Import packages definitions (now imported from ./packages/analysis.nix)
        analysisPackages = import ./packages/analysis.nix {
          inherit lib pkgs self system helpers meta-introspector-flake nix2gramIndexerModule twoGramReportGeneratorModule;
        };

      in
      {
        packages = analysisPackages;

        lib = helpers; # Expose helpers in lib
      }
    );
}
