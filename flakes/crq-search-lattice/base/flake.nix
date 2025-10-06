
{
  description = "Base empty flake for CRQ search lattice.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.runCommand "base-flake-metadata" {
        DESCRIPTION = "Base empty flake for CRQ search lattice.";
        meta = {
          flakeName = "base";
          system = system;
          nixpkgsRef = nixpkgs.rev or "";
          flakeUtilsRef = flake-utils.rev or "";
        };
      } "echo 'Flake Name: $(meta.flakeName)' > $out\n echo 'Description: $(DESCRIPTION)' >> $out\n echo 'System: $(meta.system)' >> $out\n echo 'Nixpkgs Ref: $(meta.nixpkgsRef)' >> $out\n echo 'Flake-Utils Ref: $(meta.flakeUtilsRef)' >> $out";
    };
}
