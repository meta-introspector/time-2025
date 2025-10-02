let
  nixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/meta-introspector/nixpkgs/archive/feature/CRQ-016-nixify.tar.gz";
  }) { system = "aarch64-linux"; };

  lib = nixpkgs.lib;
  pkgs = nixpkgs;

  time-2025-src = builtins.fetchTarball {
    url = "https://github.com/meta-introspector/time-2025/archive/e53d59001de6f67e513328a4602a24fa0956cf7c.tar.gz";
  };

  nGramGeneratorModule = import (time-2025-src + "/10/01/docs/theory/n_gram_generator.nix") { inherit lib pkgs builtins; };

  # Test tokenizePath
  testPath = "/foo/bar/baz.nix";
  tokenizedPath = nGramGeneratorModule.tokenizePath testPath;

  # Test generateNGrams
  testTokens = [ "foo" "bar" "baz" "nix" ];
  testNGramLengths = [ 2 ];
  generatedNGrams = nGramGeneratorModule.generateNGrams { tokens = testTokens; nGramLengths = testNGramLengths; };

in
builtins.toJSON {
  tokenizedPath = tokenizedPath;
  generatedNGrams = generatedNGrams;
}
