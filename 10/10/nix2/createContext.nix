{
  lib,
  pkgs,
  path,
  name,
}:

let
  utils = import ./lib/utils.nix { inherit lib pkgs; };

  # Convert path to string explicitly
  pathStr = builtins.toString path;

  # Get .nix filenames in the current path
  nixFilenames = utils.getNixFiles path;

  # Construct full paths for the .nix files
  nixFilesRaw = map (filename: pathStr + "/" + filename) nixFilenames;

  # Force evaluation of the list of files
  nixFiles = builtins.deepSeq nixFilesRaw nixFilesRaw;

in
{
  inherit name;
  inherit nixFiles;
  # No submodules or subdirectories for now
  submoduleContexts = {};
  subdirectories = {};
}