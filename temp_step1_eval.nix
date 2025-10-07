let
  common = import ./lib/common-imports.nix {};
  inherit (common) pkgs;
  inherit (common) lib;
  inherit (common) builtins;

  nixCodeIndexerModule = import ./10/01/docs/theory/nix_code_indexer.nix { inherit lib pkgs builtins; };
  nGramGeneratorModule = import ./10/01/docs/theory/n_gram_generator.nix { inherit lib pkgs builtins; };

  generate2GramIndexStep1Module = import ./10/01/docs/theory/nix_2gram_indexer_step1.nix {
    inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule;
  };

  projectRoot = ./.; # Current directory as project root

in
generate2GramIndexStep1Module.generate2GramIndexStep1 {
  inherit projectRoot;
  name = "step1-nix-file-index";
}
