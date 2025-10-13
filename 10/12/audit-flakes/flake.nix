{
  description = "A flake to audit all flake.lock files in a project.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # The project to audit, typically the root of the repository
    project = {
      url = "path:../.."; # Points to the streamofrandom 2025 root
      flake = false; # Treat as a path, not a flake
    };

    # Sub-flakes for the audit process
    collectLocks = {
      url = "path:./001_collect_locks";
      inputs.project.follows = "project";
    };
    extractData = {
      url = "path:./002_extract_data";
      inputs.collectedLocks.follows = "collectLocks";
    };
    grepReferences = {
      url = "path:./002a_grep_references";
      inputs.extractedData.follows = "extractData";
      inputs.project.follows = "project";
    };
    generateVirtualPackages = {
      url = "path:./003_generate_virtual_packages";
      inputs.extractedData.follows = "grepReferences";
    };
    foldToMatrix = {
      url = "path:./004_fold_to_matrix";
      inputs.virtualPackages.follows = "generateVirtualPackages";
    };
    finalReport = {
      # New input for the final report
      url = "path:./005_final_report";
      inputs.foldToMatrix.follows = "foldToMatrix";
    };
  };

  outputs = { self, nixpkgs, flake-utils, project, collectLocks, extractData, grepReferences, generateVirtualPackages, foldToMatrix, finalReport }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Chain the outputs of the sub-flakes
        collectedLocksOutput = collectLocks.packages.${system}.default;
        extractedDataOutput = extractData.packages.${system}.default;
        generatedVirtualPackagesOutput = generateVirtualPackages.packages.${system}.default;
        finalAuditMatrix = foldToMatrix.packages.${system}.default;
        finalAuditReport = finalReport.packages.${system}.default; # New output
      in
      {
        packages.default = finalAuditReport; # Expose the final report as the default package
        checks.auditReport = finalAuditReport;
      }
    );
}
