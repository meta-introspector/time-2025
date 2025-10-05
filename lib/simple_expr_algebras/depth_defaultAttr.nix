{ lib, pkgs, ... }:

# Returns the 'defaultAttr' part of the depthAlgebra
(attrs: 1 + pkgs.lib.foldl' pkgs.lib.max 0 (pkgs.lib.attrValues attrs))