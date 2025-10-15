# lib/github-wrapper.nix
{ lib, ... }:

let
  # Define local mirror paths. These are assumed paths for now.
  # The user mentioned ~/nix/vendor/nixpkgs, so I'll use that as a base.
  localMirrors = {
    nixpkgs = "/data/data/com.termux.nix/files/home/nix/vendor/nixpkgs";
    "flake-utils" = "/data/data/com.termux.nix/files/home/nix/vendor/flake-utils";
    "rnix-parser" = "/data/data/com.termux.nix/files/home/nix/vendor/rnix-parser";
    "nix-task" = "/data/data/com.termux.nix/files/home/nix/vendor/nix-task";
    "sops-nix" = "/data/data/com.termux.nix/files/home/nix/vendor/sops-nix";
    "node2nix" = "/data/data/com.termux.nix/files/home/nix/vendor/node2nix";
    "nurl" = "/data/data/com.termux.nix/files/home/nix/vendor/nurl";
    "ontology" = "/data/data/com.termux.nix/files/home/nix/vendor/ontology";
    # The current repository (time-2025) is handled by 'self' input, so no need for a mirror here.
  };

  githubWrapper = { owner, repo, ref ? "master", dir ? null, useLocalMirror ? false }:
    let
      repoName = repo;
      localPath = localMirrors.${repoName} or null;
      basePath = if dir == null then "" else "/${dir}";
    in
    if useLocalMirror && localPath != null then
      "file://${localPath}${basePath}"
    else
      "github:${owner}/${repo}?ref=${ref}${basePath}";

in
githubWrapper
