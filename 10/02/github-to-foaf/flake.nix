{
  description = "Minimal flake for github-to-foaf";

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
          githubToFoaf = {
            repoToFoaf = repoJson: { type = "repoFoaf"; data = repoJson; };
            userToFoaf = userJson: { type = "userFoaf"; data = userJson; };
          };
        };
      }
    );
}
