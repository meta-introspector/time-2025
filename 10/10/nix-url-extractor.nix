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

  # Function to parse a GitHub URL into its components
  parseGithubUrl = url:
    let
      # Regex to match github:owner/repo?ref=branch&dir=path or https://github.com/owner/repo/tree/branch/path
      # This is a simplified regex and will need refinement
      githubMatch = lib.strings.match "github:([^/]+)/([^?#]+)(\\?ref=([^&]+))?(&dir=(.*))?" url;
      httpsMatch = lib.strings.match "https://github.com/([^/]+)/([^/]+)/tree/([^/]+)/(.*)" url;
    in
    if githubMatch != null then {
      owner = lib.head githubMatch.captures;
      repo = lib.head (lib.tail githubMatch.captures);
      ref = lib.head (lib.tail (lib.tail githubMatch.captures)); # This needs to be refined to get the ref correctly
      dir = lib.head (lib.tail (lib.tail (lib.tail githubMatch.captures))); # This needs to be refined to get the dir correctly
      inherit url;
    } else if httpsMatch != null then {
      owner = lib.head httpsMatch.captures;
      repo = lib.head (lib.tail httpsMatch.captures);
      ref = lib.head (lib.tail (lib.tail httpsMatch.captures));
      dir = lib.head (lib.tail (lib.tail (lib.tail httpsMatch.captures)));
      inherit url;
    } else {
      owner = null; repo = null; ref = null; dir = null; inherit url;
    };

  # Parsed URLs
  parsedUrls = lib.map parseGithubUrl allUniqueGithubUrls;

in
{
  urls = allUniqueGithubUrls;
  inherit parsedUrls;
}
