{ lib, pkgs, firstReflection, commandUniquenessReport, urlPrefixValidationReport, systemValidationReport, submoduleUrlUniquenessReport, submoduleBranchValidationReport }:

let
  # Generate a comprehensive report
  comprehensiveReport = ''
    --- First Principle of Identity Enforcement Report ---

    Command Uniqueness:
    ${firstReflection.identityPrincipleSpec.reportingAndRemediation.generateReport commandUniquenessReport}

    URL Prefix Validation:
    Has Invalid URLs: ${if urlPrefixValidationReport.hasInvalidUrls then "Yes" else "No"}
    Invalid URLs: ${builtins.toJSON urlPrefixValidationReport.invalidUrls}

    System Validation:
    Has Invalid Systems: ${if systemValidationReport.hasInvalidSystems then "Yes" else "No"}
    Invalid Systems: ${builtins.toJSON systemValidationReport.invalidSystems}

    Submodule URL Uniqueness:
    Has Duplicate Submodule URLs: ${if submoduleUrlUniquenessReport.hasDuplicates then "Yes" else "No"}
    Duplicate Submodule URLs: ${builtins.toJSON submoduleUrlUniquenessReport.duplicates}

    Submodule Branch Validation:
    Has Invalid Submodule Branches: ${if submoduleBranchValidationReport.hasInvalidBranches then "Yes" else "No"}
    Invalid Submodule Branches: ${builtins.toJSON submoduleBranchValidationReport.invalidBranches}
  '';
in
comprehensiveReport
