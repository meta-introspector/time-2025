{
  nixpkgs,
  system,
}:

let
  pkgs = nixpkgs.legacyPackages.${system};
  lib = pkgs.lib;
in
{
  inherit pkgs lib;
}
