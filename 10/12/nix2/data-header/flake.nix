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
        packages = rec {
          inherit (lib.mapAttrs
            (name: value:
              pkgs.runCommand "${name}-data"
                {
                  data = value;
                } ''
                mkdir -p $out/share/${name}
                echo "$data" > $out/share/${name}/data.json
              ''
            )
            dataFiles) platos-mountain; # Explicitly inherit platos-mountain for now

          default = packages; # Expose all packages under default
        };
      }
    );
}
