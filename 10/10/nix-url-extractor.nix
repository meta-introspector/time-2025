{ lib, pkgs, firstReflection, flakePaths, gitmodulesPaths }:

let
  # Extract all URLs from flakes
  allFlakeUrls = lib.flatten (
    lib.map (flakePath: (firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath).urls) flakePaths
  );

  # Extract all URLs from submodules
  allSubmoduleUrls = lib.flatten (
    lib.map (gitmodulesPath: firstReflection.identityPrincipleSpec.rawCommandExtraction.extractSubmoduleUrls gitmodulesPath) gitmodulesPaths
  );

  # Combine and deduplicate all URLs
  allUniqueGithubUrls = lib.unique (allFlakeUrls ++ allSubmoduleUrls);

in
{
  urls = allUniqueGithubUrls;
}
