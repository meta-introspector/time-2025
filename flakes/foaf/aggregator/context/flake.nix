{
  description = "Exposes the FOAF context URI from foafContextFlake.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    foafContextFlake.url = "./../../context"; # Relative path to the foafContextFlake
  };

  outputs = { self, nixpkgs, flake-utils, foafContextFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
      {
        lib = {
          foafContext = foafContextFlake.lib.foafContext;
        };
      }
    );
}
