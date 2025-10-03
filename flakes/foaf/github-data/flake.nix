{
  description = "Provides GitHub repository and user data as FOAF entities.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    fetchGithubDataFlake.url = "github:meta-introspector/time-2025/feature/foaf?dir=10/02/fetch-github-data";
    githubToFoafFlake.url = "github:meta-introspector/time-2025/feature/foaf?dir=10/02/github-to-foaf";

  };

  outputs = { self, nixpkgs, flake-utils, fetchGithubDataFlake, githubToFoafFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        fetchGithubData = fetchGithubDataFlake.lib.fetchGithubData;
        githubToFoaf = githubToFoafFlake.lib.githubToFoaf;

        # Fetch data for a specific repository
        owner = "meta-introspector";
        repoName = "streamofrandom";
        repoJson = fetchGithubData.fetchRepository { inherit owner repoName; };

        # Convert repository JSON to FOAF
        repoFoaf = githubToFoaf.repoToFoaf repoJson;

        # Extract owner information and convert to FOAF
        ownerJson = repoJson.owner;
        ownerFoaf = githubToFoaf.userToFoaf ownerJson;
      in
      {
        lib = {
          githubEntities = [
            repoFoaf
            ownerFoaf
          ];
        };
      }
    );
}
