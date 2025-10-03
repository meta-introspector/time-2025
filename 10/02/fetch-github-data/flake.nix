{
  description = "Minimal flake for fetch-github-data";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        lib = {
          fetchGithubData = {
            fetchRepository = { owner, repoName }: { type = "repoData"; owner = owner; name = repoName; };
          };
        };
      }
    );
}