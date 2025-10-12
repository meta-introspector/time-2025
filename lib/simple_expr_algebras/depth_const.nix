{ lib, pkgs, ... }:

# Returns the 'const' part of the depthAlgebra
({ declName, levels, type }: 1 + (pkgs.lib.foldl' pkgs.lib.max 0 levels) + type)
