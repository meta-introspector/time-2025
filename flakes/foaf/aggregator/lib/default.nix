{
  nixpkgs,
  system,
}:

let
  pkgs = nixpkgs.legacyPackages.${system};
  inherit (pkgs) lib;
in
{
  inherit pkgs lib;
}
