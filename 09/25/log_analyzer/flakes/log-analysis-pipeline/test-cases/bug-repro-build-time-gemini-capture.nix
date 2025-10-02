{
  description = "Minimal test case to reproduce build-time-gemini-capture-flake bug";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    build-time-gemini-capture-flake.url = "github:meta-introspector/time-2025?dir=09/27/7-concepts/6-qa-testing/tests/2025-01-27-build-time-gemini-capture&ref=feature/foaf";
  };

  outputs = { self, nixpkgs, flake-utils, build-time-gemini-capture-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        common = import ../../../../lib/common-imports.nix { inherit system; };
        pkgs = common.pkgs;
      in
      {
        packages.default = build-time-gemini-capture-flake.packages.${system}.default;
      }
    );
}
