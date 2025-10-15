{ lib, pkgs }:
{
  name = "user-analysis-task-spec";
  description = "Specification for a task that identifies which other flakes depend on (use) a given Nix flake within the project graph.";
  taskType = "user-analysis";
  inputs = {
    flakePath = "The absolute path to the flake.nix file to analyze.";
    projectFlakeGraph = "A derivation representing the entire project's flake dependency graph.";
  };
  outputs = {
    userReport = "A derivation containing a list of flakes that depend on the target flake.";
  };
}
