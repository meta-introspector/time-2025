{ lib, pkgs, firstReflection, urlExtractor }:

let
  # List of all flake.nix files in the repository (relative to this prelude.nix)
  # This needs to be dynamically generated or passed as an argument
  allFlakeNixFiles = [
    # Placeholder for actual flake.nix paths
  ];

  # List of all .gitmodules files in the repository (relative to this prelude.nix)
  # This needs to be dynamically generated or passed as an argument
  allGitmodulesFiles = [
    # Placeholder for actual .gitmodules paths
  ];

  # Extract all unique GitHub URLs
  extractedUrls = urlExtractor {
    inherit lib pkgs firstReflection;
    flakePaths = allFlakeNixFiles;
    gitmodulesPaths = allGitmodulesFiles;
  };

  # Convert URLs to flake inputs
  flakeInputs = lib.listToAttrs (lib.map (url: {
    name = lib.strings.sanitizeDerivationName (lib.strings.removePrefix "github:" url);
    value = { inherit url; };
  }) extractedUrls.urls);

in
flakeInputs
