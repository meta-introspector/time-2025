{
  description = "Flake for streamofrandom/2025/09, exposing daily content.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    self.url = "path:."; # Reference to the current directory (streamofrandom/2025/09)
    search-results.url = "path:./flakes/search-results"; # New input for search results flake
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # The current directory is streamofrandom/2025/09, so dayDirs are directly here
        dayDirs = builtins.filter
          (name: builtins.isDir (self + "/${name}"))
          (builtins.attrNames (builtins.readDir self));

        # Create an attribute set of each day's content
        dailyContent = builtins.listToAttrs (builtins.map
          (day: {
            name = "day-${day}";
            value = pkgs.runCommand "day-${day}-content" {} ''
              cp -r ${self}/${day} $out
            '';
          })
          dayDirs);

      in {
        packages = {
          inherit dailyContent;
          # Expose the entire streamofrandom/2025/09 directory as a package
          streamofrandom-09 = pkgs.runCommand "streamofrandom-2025-09" {} ''
            cp -r ${self} $out
          '';
        };

        # A devShell that includes nixpkgs and potentially other tools
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Add common development tools here
            git
            gh
            nix-prefetch-git
          ];
          # You can add environment variables or other shell configurations
        };

        # Expose the FOAF Nix functions
        foaf = import ./foaf.nix { inherit pkgs self; };

        # Expose the seed FOAF data
        seedFoaf = import ./seed.foaf.nix { inherit pkgs self; };

        # Expose the search results NARs
        searchNars = search-results.packages.${system}.default;

        # Expose the url2file locator script
        url2fileLocatorScript = search-results.packages.${system}.url2fileLocatorScript;
      }
    );
}
