{ lib, pkgs, sumUtil, ... }:

# Returns the 'const' part of the sizeAlgebra
({ declName, levels, type }: 1 + (sumUtil.sum levels) + type)