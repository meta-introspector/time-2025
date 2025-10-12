# lib/nix-templates/recursive-scanner.nix
# Abstraction for recursively scanning a directory and aggregating results/errors.
{ lib, builtins, types, safeEval, foldAccumulator, nix-stdlib, ... }: # safeEval and foldAccumulator would be the templates above

let
  # Mutually recursive definitions for processEntry and generate
  recursiveDefinitions = rec {
    processEntry = path: name: type:
      let
        fullPath = "${path}/${name}";
      in
      if type == "directory" then
        recursiveDefinitions.generate fullPath # Recursive call
      else if nix-stdlib.lib.types.strings.hasSuffix ".nix" name then
        safeEval fullPath # Use the safe-eval template
      else
        { value = { }; errors = [ ]; }; # Ignore other files;

    generate = path:
      let
        getDirectoryEntries = builtins.readDir path;
        processedEntries = lib.mapAttrs (name: type: recursiveDefinitions.processEntry path name type) getDirectoryEntries;
        aggregatedResult = lib.foldlAttrs
          foldAccumulator
          { result = { }; errors = [ ]; }
          processedEntries;
      in
      aggregatedResult;
  };
in
recursiveDefinitions.generate
