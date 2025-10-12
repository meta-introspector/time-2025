# 10/12/proof/001_dump_nix/flake.nix
{
  description = "A flake to dump the AST of all .nix files in the parent project.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Reference the parent project's flake to access qa.nix
    parentProject.url = "path:../../..";
  };

  outputs = { self, nixpkgs, flake-utils, parentProject }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Import the qa.nix from the parent project
        qaChecks = parentProject.checks.${system};

        # Get the nix-dump-evaluator derivation
        nixDumpEvaluator = qaChecks.nix-dump-evaluator;
      in
      {
        apps.dump-nix-ast = {
          type = "app";
          program = "${nixDumpEvaluator}/bin/nix-dump-evaluator";
        };
        apps.default = self.apps.dump-nix-ast;
      }
    );
}
