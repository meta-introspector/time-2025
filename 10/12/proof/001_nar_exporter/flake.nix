{
  description = "A flake to export the JSON AST from 000_rnix_dump to a NAR file.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    rnix-dump-flake.url = "path:../000_rnix_dump"; # Input from Layer 1
  };

  outputs = { self, nixpkgs, flake-utils, rnix-dump-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        astJsonDerivation = rnix-dump-flake.packages.${system}.default;
      in
      {
        packages.default = pkgs.runCommand "ast-nar-file"
          {
            nativeBuildInputs = [ pkgs.nix ]; # For nix-store --dump
            astJsonPath = astJsonDerivation;
          } ''
          mkdir -p $out
          nix-store --dump $astJsonPath/ast.json > $out/ast.nar
        '';
      }
    );
}
