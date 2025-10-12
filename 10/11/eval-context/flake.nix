{
  description = "Evaluates allContextSubmodules from 10/10/context.nix";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    # Reference 10/10 as a flake input
    tenTenFlake.url = "path:../../10";
  };

  outputs = { self, nixpkgs, tenTenFlake, ... }:
    let
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs) lib;
    in
    {
      inherit (tenTenFlake.context) allContextSubmodules;
    };
}
