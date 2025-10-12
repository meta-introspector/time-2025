{ lib, pkgs, sumUtil, ... }:

# Returns the 'defaultAttr' part of the sizeAlgebra
(attrs: 1 + sumUtil.sum (pkgs.lib.attrValues attrs))
