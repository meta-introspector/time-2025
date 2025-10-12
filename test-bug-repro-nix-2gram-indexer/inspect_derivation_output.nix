let
  common = import ../lib/common-imports.nix { };
  inherit (common) pkgs;
  inherit (common) lib;
  inherit (common) builtins;

  testUtils = import ../lib/test-utils.nix { inherit pkgs lib builtins; };
  inherit (testUtils) dummyProjectRoot;

  time-2025-src = builtins.fetchTarball {
    url = "https://github.com/meta-introspector/time-2025/archive/e53d59001de6f67e513328a4602a24fa0956cf7c.tar.gz";
  };

  nixCodeIndexerModule = import (time-2025-src + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };
  nGramGeneratorModule = import (time-2025-src + "/10/01/docs/theory/n_gram_generator.nix") { inherit lib pkgs builtins; };
  nix2gramIndexerModule = import (time-2025-src + "/10/01/docs/theory/nix_2gram_indexer.nix") {
    inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule;
  };

  # Call generate2GramIndex and return its derivation
  testDerivation = nix2gramIndexerModule.generate2GramIndex {
    projectRoot = "${dummyProjectRoot}";
    name = "test-2gram-index";
  };

in
testDerivation
