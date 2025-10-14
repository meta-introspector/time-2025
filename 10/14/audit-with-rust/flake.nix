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
                  lockFileDerivation = lockFilePackage; # The derivation containing the lock file info
                  nativeBuildInputs = [ pkgs.jq ];
                } ''
                # Build the lockFilePackage derivation to get its output path
                lock_file_info_path=$(nix build --no-link --print-out-paths "$lockFileDerivation")

                # Extract the actual lockFilePath from the lock-file-info.json
                actual_lock_file_path=$(jq -r '.lockFilePath' "$lock_file_info_path/lock-file-info.json")

                # Run the flakeAuditor on the extracted lockFilePath
                mkdir -p $out
                ${flakeAuditor}/bin/flake_auditor "$actual_lock_file_path" > $out/audit-report.txt
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
