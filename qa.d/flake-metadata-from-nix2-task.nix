{ lib, pkgs, self, month10Flake }:

let
  nix2Task = month10Flake.nix2.task { inherit lib pkgs self; allFlakeNixFiles = [ ]; allGitmodulesFiles = [ ]; };

  check = nix2Task.flakeMetadata;
in
check
