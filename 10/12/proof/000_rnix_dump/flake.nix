# 10/12/proof/000_rnix_dump/flake.nix
{
  description = "A flake to dump the AST of a .nix file.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    rnix-parser.url = "github:meta-introspector/rnix-parser?ref=feature/CRQ-016-nixify-workflow";
    nix-store-dump.url = "github:meta-introspector/time-2025?ref=feature/aimyc-002-sample-extraction&dir=10/11/nix-store-dump";
  };

  outputs = { self, nixpkgs, flake-utils, rnix-parser, nix-store-dump }@inputs:
    rec {
      lib = {
        dumpNixFile = { system, targetNixFile }:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            rnixParserExecutable = rnix-parser.packages.${system}.rnix-parser;
          in
          pkgs.runCommand "rnix-ast-json"
            {
              buildInputs = [ rnix-parser.packages.${system}.rnix-parser ];
              inherit targetNixFile;
            } ''
            mkdir -p $out
            dump-ast --json "$targetNixFile" > "$out/ast.json"
          '';
      };
    }
    // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        dumper = import ./default.nix;
      in
      {
        apps.default = {
          type = "app";
          program = pkgs.writeShellScript "rnix-dump" ''
            set -e
            if [ -z "$1" ]; then
              echo "Usage: $0 <path-to-nix-file>"
              exit 1
            fi
            FILE_PATH="$1"
            dump-ast --json "$FILE_PATH" > $out/ast.json
          '';
        };
        packages.default = self.lib.dumpNixFile { inherit system; targetNixFile = ./test.nix; };
      }
    );
}
