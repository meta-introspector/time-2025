{
  lib, pkgs, repoFileInstructions
}:

lib.map (
  instruction: pkgs.writeText instruction.path instruction.content
) repoFileInstructions
