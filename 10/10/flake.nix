{
  description = "Flake for 10/10 directory, exposing context.nix";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs) lib;
    in
    {
      # Expose context.nix as an attribute
      context = import ./context.nix { inherit lib pkgs; };
    };
}
