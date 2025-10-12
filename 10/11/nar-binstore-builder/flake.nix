{
  description = "Nix flake to build all Nix flakes/packages in the repository and add them to the structured binstore.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    narLocatorFlake = {
      url = "path:../nar-locator"; # Relative path to the nar-locator flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow"; # Project root
    };
  };

  outputs = { self, nixpkgs, flake-utils, narLocatorFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # Function to find all flake.nix files in the project
        findAllFlakes = lib.filter (path: lib.strings.hasSuffix "flake.nix" path) (lib.filesystem.listFilesRecursive self);

        # Build each flake and create a NAR for it
        allNars = lib.map
          (flakePath:
            let
              # Get the flake reference (e.g., path:/absolute/path/to/flake)
              flakeRef = "path:${self.outPath}/${flakePath}";
              # Build the flake to get its default package (or a specific output)
              # This assumes each flake has a 'packages.default' output
              builtFlake = pkgs.callPackage ({ flake }: flake.packages.${system}.default) { flake = builtins.getFlake flakeRef; };
            in
            narLocatorFlake.lib.locateAndArchiveStorePath {
              storePath = builtFlake;
              originalFilePath = flakePath;
              archiveType = "nar";
            }
          )
          findAllFlakes;

      in
      {
        packages.default = pkgs.lib.listToAttrs (
          lib.map (nar: { name = lib.strings.removeSuffix ".nar" (lib.strings.baseNameOf nar); value = nar; }) allNars
        );
        lib.allNars = allNars;
      }
    );
}
