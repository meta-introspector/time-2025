{ lib, pkgs, logAnalysisPipeline, system, currentTokens, knownTokens } @ args:

let
  sampleGenerator = import ./sample-generator.nix args;
in
if sampleGenerator.isNovel { inherit currentTokens knownTokens; } then "true" else "false"