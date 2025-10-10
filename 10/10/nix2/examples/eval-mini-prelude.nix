let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  miniPrelude = import ./mini-prelude.nix { inherit pkgs lib; };
in
# Access the 'files' attribute of each context to force evaluation
{
  pickUpNixFiles = miniPrelude.pickUpNix.files;
  streamOfRandomFiles = miniPrelude.streamOfRandom.files;
  time2025Files = miniPrelude.time2025.files;
}