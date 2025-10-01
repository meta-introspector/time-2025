# fetch-github-data.nix
{ pkgs, lib, ... }:

let
  # Function to fetch GitHub repository data
  fetchRepository = { owner, repoName }:
    let
      # Use curl to fetch repository data from GitHub API
      # This is an impure operation, but it's contained within this function
      repoJson = builtins.fromJSON (builtins.readFile (
        pkgs.runCommand "github-repo-data" {} ''
          ${pkgs.curl}/bin/curl -s "https://api.github.com/repos/${owner}/${repoName}" > $out
        ''
      ));
    in
    repoJson;

in {
  fetchRepository = fetchRepository;
}
