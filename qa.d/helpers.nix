{ pkgs, lib, nixpkgs-fmt, statix, shellcheck, nix-stdlib }:

let
  qa-helpers = import ../lib/qa-helpers.nix { inherit pkgs lib nixpkgs-fmt statix shellcheck nix-stdlib; };

  # Define common tools
  inherit (pkgs) shellcheck;
  inherit (pkgs) pre-commit;
  inherit (pkgs) git;
  inherit (pkgs) nixpkgs-fmt;
  inherit (pkgs) statix;
in
{
  inherit qa-helpers shellcheck pre-commit git nixpkgs-fmt statix;
}
