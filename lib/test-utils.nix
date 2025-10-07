{
  pkgs,
  lib,
  builtins,
  ...
}:

let
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

in
{
  inherit dummyProjectRoot;
}
