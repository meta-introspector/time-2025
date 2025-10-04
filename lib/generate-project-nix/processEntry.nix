# lib/generate-project-nix/processEntry.nix
#
# Helper function to process a single entry (file or directory) during the recursive scan.
# It decides whether to recurse into a directory, evaluate a .nix file, or ignore the entry.
# Returns the evaluated content (if a .nix file) or the result of a recursive call (if a directory),
# along with any errors encountered.

{ lib, generate, evaluateNixFile, path, ... }: # Accept dependencies as arguments

name: type:
  let
    fullPath = path + "/" + name;
  in
  if type == "directory" then
    generate fullPath # Recurse for directories
  else if type == "regular" && lib.strings.hasSuffix ".nix" name && name != "project.nix" && name != "flake.nix" then
    # Evaluate .nix files using the helper function
    evaluateNixFile fullPath
  else
    # Ignore other files, return a structure indicating no value and no errors
    { value = null, errors = [] };
