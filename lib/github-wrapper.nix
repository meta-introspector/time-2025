# lib/github-wrapper.nix
{ lib, ... }:

let
  # Define local mirror paths.
  localMirrors = {
    nixpkgs = "/data/data/com.termux.nix/files/home/nix/vendor/nixpkgs";
    # Add other local mirrors here as they are confirmed by the user.
  };

  # Function to extract the revision from a GitHub URL
  getRevision = url:
    let
      # Regex to find 'ref=' in the URL
      match = builtins.match ".*ref=([^&]*).*" url;
    in
    if match != null && builtins.length match > 0 then
      builtins.elemAt match 0
    else
      null; # Or throw an error, depending on desired behavior

  # Generic self-reference function to get a permanent URL for a given repo
  # This function assumes 'self' is available in the context where it's used
  # and refers to the current flake.
  # It constructs a github URL with the current commit hash of 'self'.
  getPermaUrlSelfReference = { owner, repo, self, dir ? null }:
    let
      basePath = if dir == null then "" else "&dir=${dir}";
    in
    "github:${owner}/${repo}?ref=${self.rev}${basePath}";


  githubWrapper = { owner, repo, ref ? "master", dir ? null, useLocalMirror ? false, selfInput ? null }:
    let
      repoName = repo;
      localPath = localMirrors.${repoName} or null;
      basePath = if dir == null then "" else "/${dir}";
      # If selfInput is provided, use its revision for the ref
      effectiveRef = if selfInput != null then selfInput.rev else ref;
    in
    if useLocalMirror && localPath != null then
      "file://${localPath}${basePath}"
    else
      "github:${owner}/${repo}?ref=${effectiveRef}${basePath}";

in
{
  inherit githubWrapper getRevision getPermaUrlSelfReference;
}
