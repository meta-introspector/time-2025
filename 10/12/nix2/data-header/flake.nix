{
  description = "A flake to wrap and expose data Nix files.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Assuming data Nix files are in a 'data' subdirectory
        dataFiles = lib.mapAttrs'
          (name: path: {
            name = lib.removeSuffix ".nix" name;
            value = import path { inherit pkgs lib builtins; };
          })
          (lib.filterAttrs (name: value: lib.hasSuffix ".nix" name) (builtins.readDir ./data));
      in
      {
        packages.${system}.default = pkgs.runCommand "data-header-output"
          {
            inherit dataFiles;
          } ''
          mkdir -p $out/share/data-header
          cp -r $dataFiles/* $out/share/data-header/
        '';
        # You might want to expose individual data files as separate packages or modules
        # For example:
        # packages.${system}.mySpecificData = dataFiles.mySpecificData;
      }
    );
}
