{ self, nixpkgs, flake-utils, gemini-cli, ... } @ inputs:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs) lib;
