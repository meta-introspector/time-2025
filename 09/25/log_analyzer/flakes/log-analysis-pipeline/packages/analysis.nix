{ pkgs, lib, self ? {}, system ? builtins.currentSystem, helpers ? {}, time-2025-flake ? {}, nix2gramIndexerModule ? {}, twoGramReportGeneratorModule ? {} } @ args:

let
  # common = import ../../../lib/common-imports.nix { inherit system; };
  # lib = common.lib;
  # pkgs = common.pkgs;
  # builtins = common.builtins;

  # Import helper functions from lib/helpers.nix
  inherit (helpers) analyzePureLogsToStore analyzeImpureLogsToStore analyzeNarLogsToStore;

  # Build the buildTimeTelemetry derivation to get its output (now directly from build-time-gemini-capture-flake)
  buildTimeTelemetryOutput = args.build-time-gemini-capture-flake.packages.${system}.default;

  # Define analysis-related packages
  analyzePureLogsToStorePackage = analyzePureLogsToStore {
    logSourcePath = "${buildTimeTelemetryOutput}/logs/build-time-capture.log";
    name = "analyzed-build-telemetry-log";
  };

  analyzeImpureLogsToStorePackage = analyzeImpureLogsToStore {
    logFilePath = "/dev/null"; # Temporarily hardcoded for testing
    name = "analyzed-system-log";
  };

  analyzeNarLogsToStorePackage = analyzeNarLogsToStore {
    narUrl = "https://example.com/path/to/logs.nar"; # Placeholder URL
    narHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder hash
    name = "analyzed-remote-nar-log";
  };

  build2GramIndexPackage = nix2gramIndexerModule.generate2GramIndex {
    projectRoot = self; # The flake itself is the project root
    name = "project-2gram-index";
  };

  generate2GramReportPackage = twoGramReportGeneratorModule.generate2GramReport {
    twoGramIndexJsonPath = build2GramIndexPackage; # Use the output of the 2-gram index build
    name = "project-2gram-report";
  };

in
{
  default = analyzePureLogsToStorePackage; # Keep default as pure analysis
  analyzePureLogsToStore = analyzePureLogsToStorePackage;
  analyzeImpureLogsToStore = analyzeImpureLogsToStorePackage;
  analyzeNarLogsToStore = analyzeNarLogsToStorePackage;
  build2GramIndex = build2GramIndexPackage;
  generate2GramReport = generate2GramReportPackage;
}
