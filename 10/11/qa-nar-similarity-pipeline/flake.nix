{
  description = "QA plan for Nix NAR Similarity Search Pipeline.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    narSimilaritySearch = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=10/11/nar-similarity-search";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    narBinstoreBuilder = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=10/11/nar-binstore-builder";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.narLocatorFlake.follows = "narSimilaritySearch.narLocatorFlake"; # Assuming narLocatorFlake is an input to narSimilaritySearch
    };
  };

  outputs = { self, nixpkgs, flake-utils, narSimilaritySearch, narBinstoreBuilder }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # Helper function to create a test derivation
        mkTest = name: script: pkgs.runCommand name
          {
            nativeBuildInputs = [ pkgs.bash pkgs.jq ];
            inherit script;
          } ''
          bash $script
          echo "Test ${name} passed." > $out
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.jq
            narSimilaritySearch.packages.${system}.default # Provides rnix-parser and other tools
          ];
        };

        checks = {
          # --- Phase 1: Nix Flake Ingestion & Parsing ---
          testParseValidFlake = mkTest "test-parse-valid-flake" (pkgs.writeShellScript "test-parse-valid-flake-script" (builtins.readFile ./scripts/test-parse-valid-flake.sh));

          testParseInvalidFlake = mkTest "test-parse-invalid-flake" (pkgs.writeShellScript "test-parse-invalid-flake-script" (builtins.readFile ./scripts/test-parse-invalid-flake.sh));

          # --- Phase 2: Monster Knot Encoding ---
          testCalculateMonsterKnotSimple = mkTest "test-calculate-monster-knot-simple" (pkgs.writeShellScript "test-calculate-monster-knot-simple-script" (builtins.readFile ./scripts/test-calculate-monster-knot-simple.sh));

          # --- Phase 3: Dimensionality Reduction & Multivector Representation ---
          testProjectTo8D = mkTest "test-project-to-8d" (pkgs.writeShellScript "test-project-to-8d-script" (builtins.readFile ./scripts/test-project-to-8d.sh));
          # --- Phase 4: NAR Content Addressable Storage ---
          testNarGeneration = mkTest "test-nar-generation" (pkgs.writeShellScript "test-nar-generation-script" (builtins.readFile ./scripts/test-nar-generation.sh));

          # --- Phase 5: Similarity Search & Verification ---
          testFindSimilarFlakes = mkTest "test-find-similar-flakes" (pkgs.writeShellScript "test-find-similar-flakes-script" (builtins.readFile ./scripts/test-find-similar-flakes.sh));

          testVerifyQuasifiber = mkTest "test-verify-quasifiber" (pkgs.writeShellScript "test-verify-quasifiber-script" (builtins.readFile ./scripts/test-verify-quasifiber.sh));
        };
      }
    );
}
