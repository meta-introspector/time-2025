{ lib, pkgs, logAnalysisPipeline, system, line } @ args:

let
  sampleGenerator = import ./sample-generator.nix args;
in
builtins.toJSON (sampleGenerator.tokenizeLine line)
