{
  lib, pkgs, allRepos
}:

let
  # Function to check if a repository contains a Cargo.toml file
  isRustProject = repoPath: builtins.pathExists (repoPath + "/Cargo.toml");

  # Filter allRepos to find Rust projects
  rustProjects = lib.filter (repo: isRustProject repo.path) (lib.attrValues allRepos);

in
rustProjects
