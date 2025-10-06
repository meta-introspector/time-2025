{ lib, self, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
(self.lib.mathematical-forms-cube-number-check-fix { inherit lib; }).fixedLine