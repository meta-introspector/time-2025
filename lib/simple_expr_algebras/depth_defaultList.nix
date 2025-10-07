{ lib, pkgs, ... }:

# Returns the 'defaultList' part of the depthAlgebra
(list: pkgs.lib.foldl' pkgs.lib.max 0 list)