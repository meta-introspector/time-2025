# lib/qa-helpers.nix
#
# This module provides helper functions for the Pure Nix Quality System.
# These functions are designed to be atomic and testable, facilitating the
# composition of comprehensive QA checks.

{ pkgs, lib, nixpkgs-fmt, statix, nix-stdlib, ... }:

let
  # Function to recursively collect all .nix file paths from a given attribute set.
  # It traverses the attribute set, identifying paths that end with ".nix".
  collectNixFilesFromAttrset = attrs:
    lib.lists.flatten (
      lib.attrsets.mapAttrsToList (name: value:
        if nix-stdlib.lib.types.attrs.isType value then
          collectNixFilesFromAttrset value # Recurse into sub-attribute sets
        else if nix-stdlib.lib.types.paths.isType value && lib.strings.hasSuffix ".nix" (builtins.toString value) then
          [ (builtins.toString value) ] # Collect .nix file paths
        else
          [] # Ignore other values
      ) attrs
    );

  # Function to run nixpkgs-fmt --check on a list of Nix file paths.
  runNixFmtCheck = nixFiles: pkgs.runCommand "nixpkgs-fmt-check" {
    inherit nixFiles;
    inherit (pkgs) nixpkgs-fmt;
  } ''
    echo "Running nixpkgs-fmt --check on Nix files..."
    for nixFile in $nixFiles; do
      echo "  - Checking formatting: $nixFile"
      ${nixpkgs-fmt}/bin/nixpkgs-fmt --check $nixFile
    done
    touch $out
  '';

  # Function to run statix check on a list of Nix file paths.
  runStatixCheck = nixFiles: pkgs.runCommand "statix-check" {
    inherit nixFiles;
    inherit (pkgs) statix;
  } ''
    echo "Running statix check on Nix files..."
    for nixFile in $nixFiles; do
      echo "  - Checking static analysis: $nixFile"
      ${statix}/bin/statix check $nixFile
    done
    touch $out
  '';

  # Function to run shellcheck -x on a list of shell script paths.
  runShellcheckCheck = { shellFiles, shellcheck }: pkgs.runCommand "shellcheck-check" {
    shellFiles = lib.strings.concatStringsSep " " shellFiles;
    inherit shellcheck;
  } ''
    echo "Running shellcheck -x on shell scripts..."
    for shellFile in $shellFiles; do
      echo "  - Checking shell script: $shellFile"
      ${shellcheck}/bin/shellcheck -x $shellFile
    done
    touch $out
  '';

in
{
  inherit collectNixFilesFromAttrset runNixFmtCheck runStatixCheck runShellcheckCheck;
}
