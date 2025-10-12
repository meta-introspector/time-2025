{
  description = "Reproduce flake build issue: checks.default not found.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        checks.default = pkgs.runCommand "simple-repro-check" { } ''
          echo "--- Simple Repro Check Passed ---"
          touch $out
        '';
      }
    );
}
