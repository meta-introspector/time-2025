
{
  description = "CRQ Parser flake, adding parseCrqFilename function.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    base.follows = "base";

  };

  outputs = { self, nixpkgs, flake-utils, base }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      baseLib = base.lib or {}; # Get lib from base, or empty set if not present
    in
    {
      lib = baseLib // {
        parseCrqFilename = filename:
          let
            match = builtins.match "CRQ_([0-9]+)_(.*)\.md" filename;
          in
          if match != null then
            {
              id = builtins.elemAt match 0;
              title = builtins.replaceStrings [ "_" ] [ " " ] (builtins.elemAt match 1);
              filename = filename;
            }
          else
            null;
      };
    };
}
