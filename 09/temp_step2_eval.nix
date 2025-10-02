let
  common = import ./lib/common-imports.nix {};
  pkgs = common.pkgs;
  lib = common.lib;
  builtins = common.builtins;

  nixCodeIndexerModule = import ./theory/nix_code_indexer.nix { inherit lib pkgs builtins; };
  nGramGeneratorModule = import ./theory/n_gram_generator.nix { inherit lib pkgs builtins; };

  generate2GramIndexStep1Module = import ./theory/nix_2gram_indexer_step1.nix {
    inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule;
  };
  generate2GramIndexStep2Module = import ./theory/nix_2gram_indexer_step2.nix {
    inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule;
  };

  projectRoot = ./.; # Current directory as project root

  step1Output = generate2GramIndexStep1Module.generate2GramIndexStep1 {
    inherit projectRoot;
    name = "step1-nix-file-index";
  };

in
generate2GramIndexStep2Module.generate2GramIndexStep2 {
  inherit projectRoot;
  name = "step2-indexed-files-json";
}
