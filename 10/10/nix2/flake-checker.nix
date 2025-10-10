{ lib, pkgs, firstReflection, flakePaths }:

let
  # List of all flake.nix files in the repository
  # This will be passed as an argument to the flake-checker.nix
  flakeFiles = flakePaths;

  # Define allowed URL prefixes
  allowedUrlPrefixes = [
    "github:meta-introspector"
    "https://github.com/meta-introspector"
    # Add other allowed prefixes as needed
  ];

  # Collect all commands from all flakes
  allCommands = lib.flatten (
    lib.map (flakePath: firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath) flakeFiles
  );

  # Extract all URLs from flakes
  allFlakeUrls = lib.flatten (lib.map (flakePath: (firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath).urls) flakeFiles);

  # Paths to .gitmodules files (from context)
  gitmodulesPaths = [
    (toString ../../context/pick-up-nix/.gitmodules)
    (toString ../../context/streamofrandom/.gitmodules)
  ];

  # Extract submodule URLs
  allSubmoduleUrls = lib.flatten (lib.map (gitmodulesPath: firstReflection.identityPrincipleSpec.rawCommandExtraction.extractSubmoduleUrls gitmodulesPath) gitmodulesPaths);

  # Combine all URLs for prefix validation
  allUrls = allFlakeUrls ++ allSubmoduleUrls;

  # Perform URL prefix validation
  urlPrefixValidationResults = firstReflection.identityPrincipleSpec.flakeValidation.validateUrlsWithPrefixes {
    urls = allUrls;
    allowedPrefixes = allowedUrlPrefixes;
  };

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

  # Extract submodule branches
  allSubmoduleBranches = lib.flatten (lib.map (gitmodulesPath: firstReflection.identityPrincipleSpec.rawCommandExtraction.extractSubmoduleBranches gitmodulesPath) gitmodulesPaths);

  # Convert the list of submodule URLs into an attribute set for checkUniqueness
  submoduleUrlsAttrSet = lib.listToAttrs (
    lib.mapWithIndex (index: url: {
      name = "submodule-url-${toString index}";
      value = url;
    }) allSubmoduleUrls
  );

  # Perform submodule URL uniqueness check
  submoduleUrlUniquenessResults = firstReflection.identityPrincipleSpec.uniquenessValidation.check submoduleUrlsAttrSet;

  # Perform submodule branch validation
  submoduleBranchValidationResults =
    let
      currentBranch = firstReflection.identityPrincipleSpec.currentBranchName;
      invalidBranches = lib.filter (branch: branch != currentBranch) allSubmoduleBranches;
      hasInvalidBranches = (lib.length invalidBranches) > 0;
    in
    {
      inherit invalidBranches hasInvalidBranches;
    };

in
{
  # Expose the uniqueness results
  results = uniquenessResults;
  report = ''
    ${firstReflection.identityPrincipleSpec.reportingAndRemediation.generateReport uniquenessResults}

    --- URL Prefix Validation ---
    Has Invalid URLs: ${if urlPrefixValidationResults.hasInvalidUrls then "Yes" else "No"}
    Invalid URLs: ${builtins.toJSON urlPrefixValidationResults.invalidUrls}

    --- Submodule URL Uniqueness ---
    Has Duplicate Submodule URLs: ${if submoduleUrlUniquenessResults.hasDuplicates then "Yes" else "No"}
    Duplicate Submodule URLs: ${builtins.toJSON submoduleUrlUniquenessResults.duplicates}

    --- Submodule Branch Validation ---
    Has Invalid Submodule Branches: ${if submoduleBranchValidationResults.hasInvalidBranches then "Yes" else "No"}
    Invalid Submodule Branches: ${builtins.toJSON submoduleBranchValidationResults.invalidBranches}
  '';
}
