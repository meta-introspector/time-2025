{ lib, ... }:

let
  formsDir = ./mathematical-forms;
  # Dynamically import all .nix files from the formsDir
  # and combine them into a single attribute set.
  # The filename (without .nix) will be the attribute name.
  # This assumes each file returns a single value.
  allForms = lib.mapAttrs'
    (name: type: {
      name = lib.removeSuffix ".nix" name;
      value = (import (formsDir + "/${name}")) { inherit lib; }; # Construct full path
    })
    (lib.filterAttrs (name: value: lib.hasSuffix ".nix" name && name != "_common.nix")
      (builtins.readDir formsDir));
in
allForms
