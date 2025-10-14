{
  description = "A flake to audit collected flake.lock files using the Rust flake_auditor tool.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    flake_auditor_flake = {
      url = "path:../flake_auditor"; # Path to our Rust flake_auditor crate
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    collect_locks_flake = {
      url = "path:../audit-flakes/001_collect_locks"; # Path to the flake that collects lock files
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, flake_auditor_flake, collect_locks_flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        flakeAuditor = flake_auditor_flake.packages.${system}.flake-auditor;

        auditedLockFiles = lib.mapAttrs
          (
            name: lockFilePackage: # lockFilePackage is a derivation from collect_locks_flake
              pkgs.runCommand "${name}-audited"
                {
                  inherit flakeAuditor;
                  lockFile = lockFilePackage; # The derivation containing the lock file info
                  # Extract the actual lock file path from the derivation
                  lockFilePath = "${lockFilePackage}/lock-file-info.json"; # This needs to be adjusted based on the actual output of 001_collect_locks
                } ''
                # The lockFilePackage is a derivation that contains lock-file-info.json
                # We need to extract the actual lock file path from that JSON.
                # For now, let's assume lockFilePackage/lock-file-info.json contains the path.
                # We will need to refine this based on the actual structure of lock-file-info.json

                # For now, let's just run the auditor on the lockFilePackage itself, assuming it's the lock file.
                # This will need to be corrected once we know the exact output format of 001_collect_locks
                # For now, we'll just pass the path to the derivation output.
                # The flake_auditor expects the actual flake.lock file.

                # Let's assume the lockFilePackage output contains the actual flake.lock file at its root
                # This is a placeholder and will need to be refined.
                # The flake_auditor expects the actual flake.lock file path.
                # We need to get the actual flake.lock path from the lockFilePackage derivation.

                # For now, let's just run the auditor on a dummy file to get the structure right.
                # This part needs careful adjustment based on the exact output of 001_collect_locks
                # and how it exposes the actual flake.lock path.

                # Placeholder: Run flakeAuditor on a dummy file
                # This will be replaced with the actual lock file path.
                echo "Running auditor on ${lockFilePackage}"
                ${flakeAuditor}/bin/flake_auditor ${lockFile}/lock-file-info.json > $out/audit-report.txt
              '';
          ) collect_locks_flake.packages;

      in
      {
        packages = auditedLockFiles // {
          default = pkgs.runCommand "all-audits-summary"
            {
              auditReports = lib.toJSON (lib.attrVals (lib.mapAttrs (name: value: "${value}/audit-report.txt") auditedLockFiles));
            } ''
            mkdir -p $out
            cat $(echo $auditReports | jq -r '.[]') > $out/all-audit-reports.txt
          '';
        };
      });
}
