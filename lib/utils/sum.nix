{ lib, ... }:

let
  # Our custom sum function
  # Takes a list of numbers and returns their sum
  sum = list: lib.foldl' (a: b: a + b) 0 list;
in {
  inherit sum;
}