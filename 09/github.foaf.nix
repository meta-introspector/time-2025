# github.foaf.nix
{ pkgs, lib, fetchGithubData, githubToFoaf, ... }:

let
  # Fetch data for a specific repository
  owner = "meta-introspector";
  rootFlake.url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir";
  repoJson = fetchGithubData.fetchRepository { inherit owner repoName; };

  # Convert repository JSON to FOAF
  repoFoaf = githubToFoaf.repoToFoaf repoJson;

  # Extract owner information and convert to FOAF
  ownerJson = repoJson.owner;
  ownerFoaf = githubToFoaf.userToFoaf ownerJson;

in
{
  # Expose the GitHub FOAF entities
  githubEntities = [
    repoFoaf
    ownerFoaf
  ];
}
