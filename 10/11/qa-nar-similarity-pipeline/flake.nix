{
  description = "QA plan for Nix NAR Similarity Search Pipeline.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    narSimilaritySearch = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=source/github/meta-introspector/streamofrandom/2025/10/11/nar-similarity-search";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    narBinstoreBuilder = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=source/github/meta-introspector/streamofrandom/2025/10/11/nar-binstore-builder";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.narLocatorFlake.follows = "narSimilaritySearch.narLocatorFlake"; # Assuming narLocatorFlake is an input to narSimilaritySearch
    };
  };

  outputs = { self, nixpkgs, flake-utils, narSimilaritySearch, narBinstoreBuilder }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Helper function to create a test derivation
        mkTest = name: script: pkgs.runCommand name {
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
          testParseValidFlake = mkTest "test-parse-valid-flake" (pkgs.writeText "test-script.sh" '''
            set -euo pipefail
            echo "Testing parseFlakeToTerm with a valid flake..."
            # Create a dummy valid flake
            mkdir -p valid-flake
            echo '{ description = "A valid flake"; outputs = { self, nixpkgs }: { packages.default = nixpkgs.legacyPackages.${system}.hello; }; }' > valid-flake/flake.nix
            
            # Parse the flake
            ${narSimilaritySearch.lib.${system}.parseFlakeToTerm (pkgs.path + "/valid-flake")}
            echo "Valid flake parsed successfully."
          ''');

          testParseInvalidFlake = mkTest "test-parse-invalid-flake" (pkgs.writeText "test-script.sh" '''
            set -euo pipefail
            echo "Testing parseFlakeToTerm with an invalid flake (expecting failure)..."
            # Create a dummy invalid flake
            mkdir -p invalid-flake
            echo '{ description = "An invalid flake"; outputs = { self, nixpkgs }: { packages.default = nixpkgs.legacyPackages.${system}.hello; }; ' > invalid-flake/flake.nix # Missing closing brace
            
            # Attempt to parse the flake (should fail)
            if ${narSimilaritySearch.lib.${system}.parseFlakeToTerm (pkgs.path + "/invalid-flake")} 2>&1 | grep -q "error"; then
              echo "Invalid flake parsing failed as expected."
            else
              echo "Error: Invalid flake parsing did not fail."
              exit 1
            fi
          ''');

          # --- Phase 2: Monster Knot Encoding ---
          testCalculateMonsterKnotSimple = mkTest "test-calculate-monster-knot-simple" (pkgs.writeText "test-script.sh" '''
            set -euo pipefail
            echo "Testing calculateMonsterKnot with a simple flake..."
            mkdir -p simple-flake
            echo '{ description = "Simple flake"; outputs = { self, nixpkgs }: { packages.default = nixpkgs.legacyPackages.${system}.hello; }; }' > simple-flake/flake.nix
            
            local monster_knot_output=$(${narSimilaritySearch.lib.${system}.calculateMonsterKnot (pkgs.path + "/simple-flake")})
            echo "Monster Knot output: $(cat $monster_knot_output)"
            # Further assertions on the content of monster_knot_output would go here
            # For example, check for expected prime exponents for "flake", "outputs", "package"
          ''');

          # --- Phase 3: Dimensionality Reduction & Multivector Representation ---
          testProjectTo8D = mkTest "test-project-to-8d" (pkgs.writeText "test-script.sh" '''
            set -euo pipefail
            echo "Testing projectTo8D..."
            local prime_exponents_json='{"2":1, "3":2, "5":3, "7":3, "11":5, "13":6, "17":7, "19":8, "23":9, "29":10}'
            local eight_d_vector_derivation=$(${narSimilaritySearch.lib.${system}.projectTo8D (pkgs.lib.fromJSON prime_exponents_json)})
            local eight_d_vector=$(cat $eight_d_vector_derivation)
            echo "8D Vector: $eight_d_vector"
            # Assert that the 8D vector contains the first 8 exponents
            if [[ "$eight_d_vector" != "[1,2,3,3,5,6,7,8]" ]]; then
              echo "Error: 8D vector not as expected." >&2
              exit 1
            fi
          ''');

          # --- Phase 4: NAR Content Addressable Storage ---
          testNarGeneration = mkTest "test-nar-generation" (pkgs.writeText "test-script.sh" '''
            set -euo pipefail
            echo "Testing NAR generation with nar-binstore-builder..."
            # Create a dummy flake to be built and NAR-ified
            mkdir -p dummy-nar-flake
            echo '{ description = "Dummy NAR flake"; outputs = { self, nixpkgs }: { packages.default = nixpkgs.legacyPackages.${system}.hello; }; }' > dummy-nar-flake/flake.nix
            
            # Build the dummy flake using nar-binstore-builder
            local nar_output=$(${narBinstoreBuilder.packages.${system}.default})
            echo "NAR output: $nar_output"
            # Further assertions: check if NAR is in binstore, verify content address
          ''');

          # --- Phase 5: Similarity Search & Verification ---
          testFindSimilarFlakes = mkTest "test-find-similar-flakes" (pkgs.writeText "test-script.sh" '''
            set -euo pipefail
            echo "Testing findSimilarFlakes..."
            # This test requires more setup: creating multiple flakes, indexing them,
            # and then performing a similarity search. For now, this is a placeholder.
            echo "Placeholder for findSimilarFlakes test."
          ''');

          testVerifyQuasifiber = mkTest "test-verify-quasifiber" (pkgs.writeText "test-script.sh" '''
            set -euo pipefail
            echo "Testing verifyQuasifiber..."
            local verification_result_derivation=$(${narSimilaritySearch.lib.${system}.verifyQuasifiber "dummy-results"})
            local verification_result=$(cat $verification_result_derivation)
            if [[ "$verification_result" != "Verification complete: Results form a conceptual quasifiber." ]]; then
              echo "Error: Quasifiber verification failed." >&2
              exit 1
            fi
          ''');
        };
      }
    );
}