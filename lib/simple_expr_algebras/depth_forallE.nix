{ lib, pkgs, ... }:

# Returns the 'forallE' part of the depthAlgebra
({ binderName, binderInfo, binderType, body }: 1 + pkgs.lib.max binderType body)
