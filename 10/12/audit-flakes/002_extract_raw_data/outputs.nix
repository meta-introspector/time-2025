{ self, nixpkgs, flake-utils, ... }:
flake-utils.lib.eachDefaultSystem (system:
{
  packages.default = nixpkgs.legacyPackages.${system}.hello;
}
)
