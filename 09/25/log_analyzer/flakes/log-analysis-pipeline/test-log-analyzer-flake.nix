{
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    log-analyzer-flake.url = "github:meta-introspector/time-2025?dir=09/25/log_analyzer&ref=feature/foaf";
    rootFlake.url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir";
  };

  outputs = { self, nixpkgs, flake-utils, log-analyzer-flake, rootFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        common = rootFlake.lib.common-imports { inherit system; };
        inherit (common) pkgs;
        inherit (common) lib;
        inherit (common) builtins;
      in
      {
        packages.test-output = pkgs.runCommand "test-log-analyzer-package" {
          buildInputs = [ log-analyzer-flake.packages.${system}.default ];
        } "echo \"Log analyzer package found!\" > $$out";
      }
    );
}

