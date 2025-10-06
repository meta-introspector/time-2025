{
  description = "Flake for streamofrandom/2025/09, exposing daily content.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    search-results.url = "github:meta-introspector/time-2025/feature/foaf?dir=flakes/search-results";
  };

  outputs = { nixpkgs, flake-utils, search-results, self, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        common = self.lib.common-imports;
        inherit (common) pkgs;
        inherit (common) lib;
        inherit (common) builtins;
      in {
        # A devShell that includes nixpkgs and potentially other tools
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              gh
              nix-prefetch-git
              pre-commit
            ];
            shellHook = "echo \"Pre-commit hooks installed.\"";
            # You can add environment variables or other shell configurations
          };
        };

        # Expose custom library attributes
        lib = {
          foaf = import ./foaf.nix { inherit pkgs builtins self; };
          seedFoaf = import ./seed.foaf.nix { inherit pkgs builtins self; };

          searchNars = search-results.packages.${system}.default;
          inherit (search-results.packages.${system}) url2fileLocatorScript;

          cwm = import ./cwm.nix { inherit pkgs builtins self; inherit (flake-utils) lib; };

          w3cReposNar = search-results.packages.${system}.mkRepoListNar "w3c";
        };

        # Expose packages
        packages = {
          hello = pkgs.writeShellScriptBin "hello" "echo Hello from Nix flake!";
        };
      }
    );
}