{ lib, pkgs, ... }:

# Returns the 'app' part of the depthAlgebra
({ fn, arg }: 1 + pkgs.lib.max fn arg)