{
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    meta-introspector-flake.url = "github:meta-introspector/time-2025?ref=feature/foaf"; # Point to root
  };

  outputs = { self, nixpkgs, flake-utils, meta-introspector-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        common = import ../../../../lib/common-imports.nix { inherit system; };
        inherit (common) pkgs;
        inherit (common) lib;
        inherit (common) builtins;
      in
      {
        packages.meta-introspector-attrs = pkgs.runCommand "meta-introspector-attrs" {
          # Evaluate and print the attributes of meta-introspector-flake
          # This will show what's available under meta-introspector-flake
          # We'll try to access a known path to see if it works
          # For example, try to access the '09' directory
          output = builtins.toJSON (builtins.readDir (meta-introspector-flake + "/09"));
        } "echo \"$$output\" > $$out";
      }
    );
}
