{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
(import ../31-mathematical-forms-cube-number-check-fix.nix { inherit lib; }).fixedLine