{
  description = "Minimal flake for search-results";

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
        packages.default = pkgs.writeText "search-results" "This is a placeholder for search results.";
        lib.url2fileLocatorScript = pkgs.writeShellScript "url2fileLocatorScript" "echo \"Placeholder script\"";
        packages.mkRepoListNar = repoName: pkgs.writeText "${repoName}-repo-list-nar" "Placeholder for ${repoName} repo list NAR.";
      }
    );
}
