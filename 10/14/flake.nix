{
  description = "Flake for AI Life Mycology - Monster Group Prime Lattice";

  inputs = {
    self.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/14";
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    bag-of-words-generator.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=flakes/bag-of-words-generator";
  };

  outputs = { self, nixpkgs, bag-of-words-generator, ... }@inputs:
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

      docs.md = pkgs.writeText "mycology-flake-docs.md" "see file";
    };
}
