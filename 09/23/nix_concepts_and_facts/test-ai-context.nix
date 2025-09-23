{ pkgs ? import <nixpkgs> {},
  concepts ? { number-23 = pkgs.writeText "dummy-number-23" "23"; is-prime-23 = pkgs.writeText "dummy-is-prime-23" "true"; fact-23-oracle = pkgs.writeText "dummy-fact-23-oracle" "fact"; },
  zos ? { zosPrimes = { "prime-2" = pkgs.writeText "dummy-prime-2" "2"; }; },
  nixLib ? pkgs.lib
}:

let
  aiContext = import ./lib/ai-context.nix { inherit pkgs concepts zos nixLib; };
in
aiContext