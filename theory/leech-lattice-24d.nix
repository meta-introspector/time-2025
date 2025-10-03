# leech-lattice-24d.nix
#
# This Nix file models key properties of the 24-dimensional Leech lattice (Λ₂₄).
# The Leech lattice is a unique even unimodular lattice in 24 dimensions,
# notable for having no vectors of squared length 2.
#
# It plays a crucial role in the construction of the Monster Group (F₁),
# as the Monster Group acts as a symmetry group of the Leech lattice.
# This connection is fundamental to the project's meta-theoretical framework,
# linking abstract mathematical structures to the architectural genome.

{ lib, ... }:

let
  # Load special blade configurations from the .d/ directory
  specialBladeConfigs = lib.mapAttrs (
    name: path: import path { inherit lib; }
  ) (lib.filterAttrs (
    name: type: type == "regular"
  ) (builtins.readDir ./leech-lattice-blades.d));

  leechLattice = {
    name = "Leech Lattice (Λ₂₄)";
    dimensions = 24;
    properties = [
      "even" # All squared lengths of vectors are even integers
      "unimodular" # Determinant of its Gram matrix is 1
      "noVectorsOfSquaredLength2" # A defining characteristic
    ];
    connectionToMonsterGroup = "The Monster Group (F₁) acts as a symmetry group of the Leech lattice.";
    dimensionsList = lib.genList (i: "d${toString (i + 1)}") 24;

    getDimension = index:
      let
        bladeName = lib.elemAt leechLattice.dimensionsList index;
        baseBlade = {
          name = bladeName;
          index = index;
          architecturalSignificance = "This blade is a fundamental component of the Leech lattice, contributing to the overall system's structural integrity.";
        };
        # Check if a special configuration exists for this blade
        specialConfig = specialBladeConfigs."${bladeName}.nix" or null;
      in
      if specialConfig != null
      then specialConfig { inherit lib; baseBlade = baseBlade; }
      else baseBlade;

    # Further properties or constructions could be added here.
    # For instance, a derivation that generates a representation of its root system,
    # or a function to compute its theta series.
  };
in
leechLattice
