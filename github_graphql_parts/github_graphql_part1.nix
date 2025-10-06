{ nixpkgs }:

let
  common = import /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/lib/common-imports.nix { inherit nixpkgs; };
  inherit (common) lib;
  inherit (common) pkgs;
  inherit (common) builtins;

  githubApiUrl = "https://api.github.com/graphql";
in
{
  inherit lib pkgs builtins githubApiUrl;
}
