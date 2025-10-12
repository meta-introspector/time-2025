{ lib, pkgs, projectInfo, qaHelpers }:

let
  # Function to find all files named uncommitted.nix recursively
  findUncommittedNixFiles = dir:
    let
      entries = builtins.readDir dir;
      files = pkgs.lib.attrsets.mapAttrsToList
        (name: type:
          if type == "regular" && name == "uncommitted.nix" then
            [ (dir + "/" + name) ]
          else
            [ ]
        )
        entries;
      dirs = pkgs.lib.attrsets.mapAttrsToList
        (name: type:
          if type == "directory" then
            findUncommittedNixFiles (dir + "/" + name)
          else
            [ ]
        )
        entries;
    in
    pkgs.lib.lists.flatten (files ++ dirs);

  # Find all uncommitted.nix files in the project source
  uncommittedNixFiles = findUncommittedNixFiles projectInfo.projectSrc;

  # Import all uncommitted.nix files and merge their uncommittedFiles lists
  allUncommittedFiles = pkgs.lib.lists.flatten (pkgs.lib.lists.map (file: (import file).uncommittedFiles) uncommittedNixFiles);

  shellcheck-check = qaHelpers.qa-helpers.runShellcheckCheck { shellFiles = allUncommittedFiles; inherit (qaHelpers) shellcheck; };
in
{
  inherit uncommittedNixFiles allUncommittedFiles shellcheck-check;
}
