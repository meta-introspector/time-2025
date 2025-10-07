# eval-cwm.nix
{ pkgs, lib, self }:

let
  cwm = import ./cwm.nix { inherit pkgs lib self; };
in
cwm.overallStatus
