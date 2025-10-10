{ lib, pkgs, firstReflection }:

let
  # List of all flake.nix files in the repository
  # This needs to be dynamically generated or passed as an argument
  # For now, we'll use a placeholder list.
  # In a real scenario, this would come from a glob or a file index.
  flakeFiles = [
    ./flake.nix # Example: current flake
    # Add other flake.nix paths here
  ];

  # Collect all commands from all flakes
  allCommands = lib.flatten (
    lib.map (flakePath: firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath) flakeFiles
  );

  # Convert the list of commands into an attribute set for checkUniqueness
  # Each command needs a unique identifier (key)
  commandsAttrSet = lib.listToAttrs (
    lib.mapWithIndex (index: command: {
      name = "command-${toString index}";
      value = command;
    }) allCommands
  );

  # Perform uniqueness check
  uniquenessResults = firstReflection.identityPrincipleSpec.uniquenessValidation.check commandsAttrSet;

in
{
  # Expose the uniqueness results
  results = uniquenessResults;
  report = firstReflection.identityPrincipleSpec.reportingAndRemediation.generateReport uniquenessResults;
}
