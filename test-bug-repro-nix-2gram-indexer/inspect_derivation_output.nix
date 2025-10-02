let
  nixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/meta-introspector/nixpkgs/archive/feature/CRQ-016-nixify.tar.gz";
  }) { system = "aarch64-linux"; };

  flake-utils = import (builtins.fetchTarball {
    url = "https://github.com/meta-introspector/flake-utils/archive/feature/CRQ-016-nixify.tar.gz";
  }) {};

  time-2025-src = builtins.fetchTarball {
    url = "https://github.com/meta-introspector/time-2025/archive/e53d59001de6f67e513328a4602a24fa0956cf7c.tar.gz";
  };

  pkgs = nixpkgs;
  lib = nixpkgs.lib;

  nixCodeIndexerModule = import (time-2025-src + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };
  nGramGeneratorModule = import (time-2025-src + "/10/01/docs/theory/n_gram_generator.nix") { inherit lib pkgs builtins; };
  nix2gramIndexerModule = import (time-2025-src + "/10/01/docs/theory/nix_2gram_indexer.nix") {
    inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule;
  };

  # Define a dummy project root for testing
  dummyProjectRoot = pkgs.runCommand "dummy-project-root" {
    buildInputs = [ pkgs.bash ];
  } ''
#!/usr/bin/env bash
set -euo pipefail

# Create the output directory
mkdir -p "$out/foo"

# Create the test.nix file
echo 'bar' > "$out/foo/test.nix"
'';

  # Call generate2GramIndex and return its derivation
  testDerivation = nix2gramIndexerModule.generate2GramIndex {
    projectRoot = "${dummyProjectRoot}";
    name = "test-2gram-index";
  };

in
testDerivation