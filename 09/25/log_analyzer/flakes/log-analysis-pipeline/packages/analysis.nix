{ lib, pkgs, self, system, helpers, meta-introspector-flake, nix2gramIndexerModule, twoGramReportGeneratorModule, ... }:

let
  # Import helper functions from lib/helpers.nix
  inherit (helpers) buildTimeTelemetryOutput analyzePureLogsToStore analyzeImpureLogsToStore analyzeNarLogsToStore;

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
