{
  description = "Flake for AI Life Mycology - Monster Group Prime Lattice";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) lib;

      monsterGroupPrimeLattice = import ./monster-group-prime-lattice.nix { inherit pkgs lib; };
    in
    {
      packages.${system}.default = monsterGroupPrimeLattice.monsterGroupJson;

      # Expose the raw data for other flakes to consume if needed
      lib.monsterGroupData = monsterGroupPrimeLattice.monsterGroupData;
    };
}
