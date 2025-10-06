let
  common = import ../lib/common-imports.nix {};
  inherit (common) pkgs;
  inherit (common) lib;
  inherit (common) builtins;

  testUtils = import ../lib/test-utils.nix { inherit pkgs lib builtins; };
  inherit (testUtils) dummyProjectRoot;

  time2025-src = builtins.fetchTarball {
    url = "https://github.com/meta-introspector/time-2025/archive/feature/foaf.tar.gz";
  };

  nixCodeIndexerModule = import (time2025-src + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };
  nGramGeneratorModule = import (time2025-src + "/10/01/docs/theory/n_gram_generator.nix") { inherit lib pkgs builtins; };

  nix_2gram_indexer_module = import (time2025-src + "/10/01/docs/theory/nix_2gram_indexer.nix") {
    inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule;
  };

  # Call generate2GramIndex and inspect its output
  twoGramIndexDerivation = nix_2gram_indexer_module.generate2GramIndex {
    projectRoot = dummyProjectRoot;
    name = "inspect-2gram-index";
  };

in
{
  nixFileIndexDrvPath = nix_2gram_indexer_module.nixFileIndex.drvPath;
  indexedFilesJsonDerivationDrvPath = nix_2gram_indexer_module.indexedFilesJsonDerivation.drvPath;
  readIndexedFilesJsonDrvPath = nix_2gram_indexer_module.readIndexedFilesJson.drvPath;
  twoGramIndexDerivationDrvPath = twoGramIndexDerivation.drvPath;
}