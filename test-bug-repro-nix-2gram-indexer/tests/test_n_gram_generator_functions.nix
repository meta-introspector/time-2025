let
  common = import ../../lib/common-imports.nix {};
  inherit (common) lib;
  inherit (common) pkgs;
  inherit (common) builtins;

  nGramGeneratorModule = import ../../10/01/docs/theory/n_gram_generator.nix { inherit lib pkgs builtins; };

  # Test tokenizePath
  testPath = "/foo/bar/baz.nix";
  tokenizedPath = nGramGeneratorModule.tokenizePath testPath;

  # Test generateNGrams
  testTokens = [ "foo" "bar" "baz" "nix" ];
  testNGramLengths = [ 2 ];
  generatedNGrams = nGramGeneratorModule.generateNGrams { tokens = testTokens; nGramLengths = testNGramLengths; };

in
builtins.toJSON {
  inherit tokenizedPath;
  inherit generatedNGrams;
}
