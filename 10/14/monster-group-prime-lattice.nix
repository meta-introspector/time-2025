{ pkgs, lib, ... }:

let
  # The Monster Group's order prime factorization
  monsterGroupOrder = {
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

  # Platonic forms of prime grouping as described in the Grand Vision
  primeGroupings = [
    [ 0 1 2 3 ]
    [ 5 7 11 13 ]
    [ 17 19 23 31 ]
  ];

  # Convert Nix data to JSON string
  toJson = data: builtins.toJSON data;

in
{
  # Expose the data for other Nix expressions or for direct evaluation
  monsterGroupData = {
    orderFactorization = monsterGroupOrder;
    groupings = primeGroupings;
  };

  # A derivation to output the data as a JSON file
  monsterGroupJson = pkgs.writeText "monster-lattice.json" (toJson {
    orderFactorization = monsterGroupOrder;
    groupings = primeGroupings;
  });
}
