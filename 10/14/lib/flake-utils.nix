{ pkgs
, lib
,
}:

{
  monsterGroupPrimeLattice = import ../monster-group-prime-lattice.nix { inherit pkgs lib; };
}
