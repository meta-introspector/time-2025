
{
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };
  outputs = { self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      inherit (pkgs) lib;
      miniPrelude = import ../mini-prelude.nix { inherit pkgs lib; };
    in
    miniPrelude;
}
