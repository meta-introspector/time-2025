{ pkgs, logAnalysisPipeline, system, logFile }:

let
  nixLogParser = logAnalysisPipeline.lib.${system};
  logLines = builtins.splitString "\n" (builtins.readFile logFile);
in
builtins.toJSON (nixLogParser.extractNixStorePathsFromLog logLines)
