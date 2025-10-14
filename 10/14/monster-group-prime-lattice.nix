{ lib }:

let
  # The "Grand Vision for Prime Lattice" posits that the Monster Group provides
  # the combinatorial grammar for structuring the fundamental building blocks of
  # numbers: the primes. This Nix expression is a model of that concept, a
  # "Quasi-Fiber" in the AI Life Mycology system.

  # The first 8 primes, forming the initial "shape" of the lattice.
  zos = [ 2 3 5 7 11 13 17 19 ];

  # The prime groupings, as described in the "spore vial". These are the
  # "platonic forms of prime grouping" that act as pattern matchers.
  primeGroupings = [
    [ 0 1 2 3 ]
    [ 5 7 11 13 ]
    [ 17 19 23 31 ]
  ];

  # The prime factorization of the order of the Monster Group. This is the
  # "Monster Knot" that organizes the prime lattice.
  monsterGroupOrderFactorization = {
    "2" = 46;
    "3" = 20;
    "5" = 9;
    "7" = 6;
    "11" = 2;
    "13" = 3;
    "17" = 1;
    "19" = 1;
    "23" = 1;
    "29" = 1;
    "31" = 1;
    "41" = 1;
    "47" = 1;
    "59" = 1;
    "71" = 1;
  };

in
{
  # This attribute set represents the "fruiting body" of this Nix expression:
  # a structured representation of the mathematical mycelium.
  mathematicalMycelium = {
    inherit zos primeGroupings monsterGroupOrderFactorization;
  };
}
