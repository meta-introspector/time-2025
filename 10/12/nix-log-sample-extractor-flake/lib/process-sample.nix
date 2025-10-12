{ lib, pkgs, logAnalysisPipeline, system, parsedLine } @ args:

let
  sampleGenerator = import ./sample-generator.nix args;
  logEntry = builtins.fromJSON parsedLine;
  processed = sampleGenerator.processLogEntry logEntry;
in
builtins.toJSON {
  filename = "${processed.eventType}-${processed.sampleHash}.nix";
  content = sampleGenerator.generateSampleNixFileContent {
    inherit (processed) eventType originalContent allPaths;
  };
}