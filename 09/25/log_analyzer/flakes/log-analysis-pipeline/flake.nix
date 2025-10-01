{
  description = "A Nix-flake for analyzing build telemetry logs using log_analyzer";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    log-analyzer-flake.url = "github:meta-introspector/streamofrandom?ref=feature/CRQ-016-nixify&dir=2025/09/25/log_analyzer";
    build-telemetry-flake.url = "github:meta-introspector/time-2025?ref=feature/vale-precommit&dir=09/27/7-concepts/6-qa-testing/tests/2025-01-27-build-time-gemini-capture";
  };

  outputs = { self, nixpkgs, flake-utils, log-analyzer-flake, build-telemetry-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Build the buildTimeTelemetry derivation to get its output
        buildTimeTelemetryOutput = build-telemetry-flake.packages.${system}.default;
      in
      {
        packages.default = pkgs.runCommandLocal "analyzed-build-telemetry-log" {
          nativeBuildInputs = [ log-analyzer-flake.packages.${system}.log-analyzer ];
        }
        '''
          ${log-analyzer-flake.packages.${system}.log-analyzer}/bin/log-analyzer < ${buildTimeTelemetryOutput}/logs/build-time-capture.log > $out/analysis-result.txt
        ''';
      }
    );
}