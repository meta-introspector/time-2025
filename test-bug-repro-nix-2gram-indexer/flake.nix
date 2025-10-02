{
  description = "Minimal test case to reproduce nix_2gram_indexer.nix bug";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    time-2025-src = {
      url = "github:meta-introspector/time-2025/e53d59001de6f67e513328a4602a24fa0956cf7c";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, time-2025-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        generateDummyProjectScript = pkgs.writeScript "generate-dummy-project.sh" (builtins.readFile ./generate_dummy_project.sh);

        # Import required modules
        nixCodeIndexerModule = import (time-2025-src + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };
        nGramGeneratorModule = import (time-2025-src + "/10/01/docs/theory/n_gram_generator.nix") { inherit lib pkgs builtins; };

        # Import the module under test
        nix2gramIndexerModule = import (time-2025-src + "/10/01/docs/theory/nix_2gram_indexer.nix") {
          inherit lib pkgs builtins nGramGeneratorModule nixCodeIndexerModule;
        };


        dummyProjectRoot = import ./lib/generate-dummy-project.nix { inherit pkgs lib builtins; };

        # Attempt to evaluate the generate2GramIndex function
        testEvaluation = nix2gramIndexerModule.generate2GramIndex {
          projectRoot = "${dummyProjectRoot}";
          name = "test-2gram-index";
        };

      in
      {
        packages.default = testEvaluation;
      }
    );
}