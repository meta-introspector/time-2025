# leech-lattice-blade-instance.nix
#
# This Nix file demonstrates how to instantiate and inspect a single blade
# (dimension) from the 24-dimensional Leech lattice model.

{ lib, ... }:

let
  leechLattice = import ./leech-lattice-24d.nix { inherit lib; };

  # Instantiate a specific blade, for example, the 17th dimension (index 16)
  # Prime 17 represents "Refinement/Communication, Integration/Pattern Recognition, and Large Group Composition"
  # in the bott Universal Architectural Framework.
  blade17 = leechLattice.getDimension 16; # 0-based index for the 17th element

in
blade17
