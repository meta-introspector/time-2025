{ lib, pkgs, logAnalysisPipeline, system, currentTokens, knownTokens } @ args:

let
  sampleGenerator = import ./sample-generator.nix args;
in
builtins.toJSON (sampleGenerator.updateKB { inherit currentTokens knownTokens; })