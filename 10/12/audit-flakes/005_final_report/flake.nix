{
  description = "A flake to provide the final audit report.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Input from the previous step: a derivation containing the final audit matrix
    foldToMatrix = {
      url = "path:../004_fold_to_matrix";
    };
  };

  outputs = { self, nixpkgs, flake-utils, foldToMatrix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        finalAuditMatrix = foldToMatrix.packages.${system}.default;
      in
      {
        packages.default = finalAuditMatrix;
        checks.auditReport = finalAuditMatrix;

        docs.usage = pkgs.writeText "usage.md" ''
          # Flake: 005_final_report

          ## Purpose

          This flake provides the final aggregated audit report in JSON format.

          ## Inputs

          *   `nixpkgs`: Standard Nixpkgs input.
          *   `flake-utils`: Utility functions for Nix flakes.
          *   `foldToMatrix`: The output from the `004_fold_to_matrix` flake, which is a derivation containing the final audit matrix.

          ## Outputs

          *   `packages.default`: A derivation containing the final audit report in JSON format.
          *   `checks.auditReport`: A check that outputs the same JSON report, useful for debugging and verification.

          ## Usage

          To build the final audit report:

          ```bash
          nix build .#default
          cat ./result
          ```

          This flake is the final step in the audit process.
        '';
      }
    );
}
