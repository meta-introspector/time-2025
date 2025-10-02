let
  nixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/meta-introspector/nixpkgs/archive/feature/CRQ-016-nixify.tar.gz";
  }) { system = "aarch64-linux"; };

  lib = nixpkgs.lib;
  pkgs = nixpkgs;

  time-2025-src = builtins.fetchTarball {
    url = "https://github.com/meta-introspector/time-2025/archive/e53d59001de6f67e513328a4602a24fa0956cf7c.tar.gz";
  };

  nixCodeIndexerModule = import (time-2025-src + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };

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

  # Call indexNixFiles and return its derivation
  nixFileIndexDerivation = nixCodeIndexerModule.indexNixFiles {
    path = dummyProjectRoot;
    projectRoot = dummyProjectRoot;
    name = "test-nix-file-index";
  };

in
nixFileIndexDerivation
