{ lib, pkgs, self, month10Flake }:

let
  nix2Task = month10Flake.nix2.task { inherit lib pkgs self; allFlakeNixFiles = [ ]; allGitmodulesFiles = [ ]; };

  flake-metadata-from-nix2-task = nix2Task.flakeMetadata;
in
{
  inherit nix2Task flake-metadata-from-nix2-task;
}
