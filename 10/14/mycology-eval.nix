{ pkgs, lib, ... }:

let
  # Input for the current state of the mycology project
  mycologyState = {
    url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/14";
    flake = false; # Since it's a directory, not a flake itself
  };

  # Import the monster-group-prime-lattice.nix from the mycologyState input
  monsterGroupPrimeLattice = import (mycologyState + "/monster-group-prime-lattice.nix") { inherit pkgs lib; };

in
{
  # Expose the monster group data from the imported state
  monsterGroupDataFromGit = monsterGroupPrimeLattice.monsterGroupData;

  # Optionally, you could also expose the JSON derivation from the imported state
  # monsterGroupJsonFromGit = monsterGroupPrimeLattice.monsterGroupJson;
}
