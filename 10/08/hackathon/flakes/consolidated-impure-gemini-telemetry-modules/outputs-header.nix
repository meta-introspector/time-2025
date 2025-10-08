{ self, nixpkgs, flake-utils, gemini-cli, ... } @ inputs:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs) lib;
    in
    {
      # This is a placeholder for actual outputs.
      # This file is likely a header/fragment.
    }
  )
