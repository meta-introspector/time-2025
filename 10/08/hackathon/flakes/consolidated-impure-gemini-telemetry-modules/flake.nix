{
  description = "Modularized Consolidated Impure Gemini CLI telemetry capture and credential testing.";

  inputs = {
    originalFlake.url = "path:../../../09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry";
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, originalFlake, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Expose the original flake's outputs
        inherit (originalFlake.outputs.${system}) lib packages apps;

        # Optionally, add new outputs or override existing ones here
      }
    );
}
