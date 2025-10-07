let
  common = import ../../lib/common-imports.nix {};
  inherit (common) pkgs;
  inherit (common) lib;
  inherit (common) builtins;

  testUtils = import ../../lib/test-utils.nix { inherit pkgs lib builtins; };
  inherit (testUtils) dummyProjectRoot;

  time-2025-src = builtins.fetchTarball {
    url = "https://github.com/meta-introspector/time-2025/archive/e53d59001de6f67e513328a4602a24fa0956cf7c.tar.gz";
  };

  nixCodeIndexerModule = import (time-2025-src + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };

  # Call indexNixFiles to get the derivation
  nixFileIndex = nixCodeIndexerModule.indexNixFiles {
    path = dummyProjectRoot;
    projectRoot = dummyProjectRoot;
    name = "test-nix-file-index";
  };

in
"${nixFileIndex}/nix-files.index.json"
