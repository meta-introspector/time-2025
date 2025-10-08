{
  description = "Wrapper flake to call consolidated-impure-gemini-telemetry with a filePath input.";

  inputs = {
    nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    consolidatedTelemetry.url = "path:../../09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry";
  };

  outputs = { self, nixpkgs, flake-utils, consolidatedTelemetry, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = consolidatedTelemetry.packages.${system}.default {
          mycologyContext = { }; # Pass an empty context for now
        };

        apps.default = {
          type = "app";
          program = "${consolidatedTelemetry.apps.${system}.default.program}";
        };
      }
    );
}
