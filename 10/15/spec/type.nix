{ lib, pkgs }:
{
  name = "type-analysis-task-spec";
  description = "Specification for a task that performs type analysis on a Nix flake.";
  taskType = "type-analysis";
  inputs = {
    flakePath = "The absolute path to the flake.nix file to analyze.";
    # Potentially other inputs like a type system definition
  };
  outputs = {
    typeReport = "A derivation containing a report of the flake's inferred types and type errors.";
  };
}
