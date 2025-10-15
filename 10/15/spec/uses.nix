{ lib, pkgs }:
{
  name = "uses-analysis-task-spec";
  description = "Specification for a task that identifies the direct inputs (dependencies) of a Nix flake.";
  taskType = "uses-analysis";
  inputs = {
    flakePath = "The absolute path to the flake.nix file to analyze.";
  };
  outputs = {
    usesReport = "A derivation containing a list of the flake's direct inputs.";
  };
}
