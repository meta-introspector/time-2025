{ pkgs, lib, projectInfo, qaHelpers }:

let
  nixpkgs-fmt-check = qaHelpers.qa-helpers.runNixFmtCheck projectInfo.allProjectNixFiles;
  statix-check = qaHelpers.qa-helpers.runStatixCheck projectInfo.allProjectNixFiles;

  check = pkgs.runCommand "check-all-nix-files"
    {
      inherit (projectInfo) allProjectNixFiles;
      inherit nixpkgs-fmt-check statix-check;
    } ''
    echo "--- Running checks on all .nix files ---"
    ${nixpkgs-fmt-check}
    ${statix-check}
    echo "--- All .nix file checks passed. ---"
    touch $out
  '';
in
check
