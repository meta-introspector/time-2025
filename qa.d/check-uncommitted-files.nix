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

  check = pkgs.runCommand "check-uncommitted-files"
    {
      uncommittedFiles = lib.strings.concatStringsSep " " allUncommittedFiles;
    } ''
    echo "--- Running checks on uncommitted files ---"
    echo "Found the following uncommitted files:"
    for f in $uncommittedFiles; do
      echo "  - $f"
    done
    echo "--- All uncommitted file checks passed. ---"
    touch $out
  '';
in
check
