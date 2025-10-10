{
  lib,
  pkgs,
}:

let
  # Function to get all .nix files in a given directory (non-recursive)
  getNixFiles = dir:
    let
      entries = builtins.readDir dir;
      files = lib.filter (
        name: builtins.match ".*\\.nix" name != null
      ) (builtins.attrNames entries);
    in
    files; # Return just the names of the files

in
{
  inherit getNixFiles;
}