{ pkgs, lib, self, nix-stdlib, nixTermExtractor, nGramGenerator, month10Flake }:

let
  # Common inputs for all modules
  commonArgs = {
    inherit pkgs lib self nix-stdlib nixTermExtractor nGramGenerator month10Flake;
  };

  # Import common helper modules
  qaHelpers = import ./qa.d/helpers.nix (commonArgs // {
    inherit (pkgs) nixpkgs-fmt statix shellcheck;
    inherit (commonArgs) nix-stdlib;
  });
  projectInfo = import ./qa.d/project-info.nix (commonArgs // { inherit qaHelpers; });

  # Dynamically load checks from qa.d/
  qaModules = lib.mapAttrs' 
    (name: path:
      # Filter out non-nix files and the common helper modules
      if lib.hasSuffix ".nix" name && name != "helpers.nix" && name != "project-info.nix"
      then {
        name = lib.removeSuffix ".nix" name;
        value = import path (commonArgs // { inherit qaHelpers projectInfo; });
      }
      else null # Filter out non-nix files and common modules
    )
    (builtins.readDir ./qa.d);

  # Collect all checks
  allChecks = lib.filterAttrs (name: value: value != null) qaModules;

  # Define the default check that runs all other checks
  defaultCheck = pkgs.runCommand "default-qa-check"
    {
      # Inherit all checks to ensure they are built
      inherit (allChecks)
        check-all-nix-files
        check-uncommitted-files
        nix-flake-check
        pre-commit-all-files
        shellcheck-config-sh
        nix-emoji-report
        flake-metadata-from-nix2-task;
    } ''
    echo "--- Running all default QA checks ---"
    ${allChecks.check-all-nix-files}
    ${allChecks.check-uncommitted-files}
    ${allChecks.nix-flake-check}
    ${allChecks.pre-commit-all-files}
    ${allChecks.shellcheck-config-sh}
    ${allChecks.nix-emoji-report}
    ${allChecks.flake-metadata-from-nix2-task}
    echo "--- All default QA checks passed. ---"
    touch $out
  '';

in
allChecks // { default = defaultCheck; }