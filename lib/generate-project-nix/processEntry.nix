# lib/generate-project-nix/processEntry.nix
#
# Helper function to process a single entry (file or directory) during the recursive scan.
# It decides whether to recurse into a directory, evaluate a .nix file, or ignore the entry.
# Returns the evaluated content (if a .nix file) or the result of a recursive call (if a directory),
# along with any errors encountered.

{ lib, generate, evaluateNixFile, errors, types, builtins, ... }:

path:
name: type:
  let
    fullPath = path + "/" + name;
  in
  if type == "directory" then
    (let res = generate fullPath; in { value = res.result; errors = res.errors; }) # Recurse for directories
  else if type == "regular" && lib.strings.hasSuffix ".nix" name && name != "project.nix" && name != "flake.nix" then
    # Evaluate .nix files using the helper function
    let
      evaluated = (import (builtins.fetchTarball "github:meta-introspector/time-2025?ref=feature/foaf&dir=lib/generate-project-nix/evaluateNixFile.nix")) { file = fullPath; inherit errors types builtins; };
    in
    import (builtins.fetchTarball "github:meta-introspector/time-2025?ref=feature/foaf&dir=10/04/lib/error-isolation.nix") { evalResult = evaluated; file = fullPath; inherit builtins errors types; }
  else
    # Ignore other files, return a structure indicating no value and no errors
    { value = null; errors = []; }
