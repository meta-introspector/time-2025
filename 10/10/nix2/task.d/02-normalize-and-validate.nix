{ lib, pkgs, firstReflection, extractedInfo }:

let
  # Normalize extracted information
  normalizedCommands = lib.map firstReflection.identityPrincipleSpec.commandNormalization.normalizeShellCommand extractedInfo.flakeCommands;
  # ... other normalizations ...

  # Validate uniqueness and adherence to rules
  commandUniquenessReport = firstReflection.identityPrincipleSpec.uniquenessValidation.check (lib.listToAttrs (lib.mapWithIndex (i: cmd: { name = "cmd-${toString i}"; value = cmd; }) normalizedCommands));
  allUrls = extractedInfo.flakeUrls ++ extractedInfo.submoduleUrls;
  urlPrefixValidationReport = firstReflection.identityPrincipleSpec.flakeValidation.validateUrlsWithPrefixes {
    urls = allUrls;
    allowedPrefixes = [ "github:meta-introspector" "https://github.com/meta-introspector" ];
  };
  systemValidationReport = firstReflection.identityPrincipleSpec.flakeValidation.validateFlakeSystems extractedInfo.flakeSystems;
  submoduleUrlUniquenessReport = firstReflection.identityPrincipleSpec.uniquenessValidation.check (lib.listToAttrs (lib.mapWithIndex (i: url: { name = "submodule-url-${toString i}"; value = url; }) extractedInfo.submoduleUrls));
  submoduleBranchValidationReport =
    let
      currentBranch = firstReflection.identityPrincipleSpec.currentBranchName;
      invalidBranches = lib.filter (branch: branch != currentBranch) extractedInfo.submoduleBranches;
    in
    {
      inherit invalidBranches;
      hasInvalidBranches = (lib.length invalidBranches) > 0;
    };

in
{
  inherit commandUniquenessReport urlPrefixValidationReport systemValidationReport submoduleUrlUniquenessReport submoduleBranchValidationReport;
}
