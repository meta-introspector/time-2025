{
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    log-analyzer-flake.url = "github:meta-introspector/time-2025?dir=09/25/log_analyzer&ref=feature/foaf";
  };

  outputs = { self, nixpkgs, flake-utils, log-analyzer-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        common = import ../../../../lib/common-imports.nix { inherit system; };
        pkgs = common.pkgs;
        lib = common.lib;
        builtins = common.builtins;
      in
      {
        packages.test-output = pkgs.runCommand "test-log-analyzer-package" {
          buildInputs = [ log-analyzer-flake.packages.${system}.default ];
        } "echo \"Log analyzer package found!\" > $$out";
      }
    );
}

