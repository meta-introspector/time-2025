{ nixpkgs }:

let
  common = import ../lib/common-imports.nix { inherit nixpkgs; };
  inherit (common) lib;
  inherit (common) pkgs;
  inherit (common) builtins;

  githubApiUrl = "https://api.github.com/graphql";
in
{
  inherit lib pkgs builtins githubApiUrl;
}
