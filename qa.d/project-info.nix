{ lib, self, pkgs, qaHelpers }:

let
  # The entire project source for checks that need it
  projectSrc = self;

  # Import the dynamically generated project.nix
  projectNix = import ../project.nix;

  # Collect all .nix file paths from the projectNix attribute set
  allProjectNixFiles = qaHelpers.qa-helpers.collectNixFilesFromAttrset projectNix;
in
{
  inherit projectSrc projectNix allProjectNixFiles;
}
