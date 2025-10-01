{
  description = "Flake for streamofrandom/2025/09, exposing daily content.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    search-results.url = "path:./flakes/search-results"; # New input for search results flake
  };

  outputs = { nixpkgs, flake-utils, search-results, self, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        # A devShell that includes nixpkgs and potentially other tools
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Add common development tools here
            git
            gh
            nix-prefetch-git
            pre-commit
          ];
          # You can add environment variables or other shell configurations
        };

        foaf = import ./foaf.nix { inherit pkgs; };
        seedFoaf = import ./seed.foaf.nix { inherit pkgs; };

        searchNars = search-results.packages.${system}.default;
        url2fileLocatorScript = search-results.packages.${system}.url2fileLocatorScript;

        cwm = import ./cwm.nix { inherit pkgs lib self; };
      });
}