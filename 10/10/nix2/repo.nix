{ lib, pkgs, repoPath }:

let
  flakeNix = "${repoPath}/flake.nix";
  gitmodules = "${repoPath}/.gitmodules";
in
{
  flakeNix = if builtins.pathExists flakeNix then flakeNix else null;
  gitmodules = if builtins.pathExists gitmodules then gitmodules else null;
  # Add other relevant information about the repository here
}
