{ lib, pkgs, firstReflection, urlExtractor, flakePaths, gitmodulesPaths }:

let
  # Import the abstract task definition
  task = import ./task.nix {
    inherit lib pkgs firstReflection urlExtractor;
    inherit flakePaths gitmodulesPaths;
  };
in
{
  # Expose the report from the task
  inherit (task) report;
  # Expose individual reports for detailed inspection
  inherit (task) commandUniquenessReport urlPrefixValidationReport systemValidationReport submoduleUrlUniquenessReport submoduleBranchValidationReport;
}
