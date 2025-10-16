{
  description = "A flake to orchestrate the Rust flake_auditor tool for indexing flake.lock and flake.nix files.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    flake_auditor_flake = {
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/14/audit-with-rust/flake_auditor"; # Path to our Rust flake_auditor crate
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, flake_auditor_flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        flakeAuditor = flake_auditor_flake.packages.${system}.default; # Assuming the Rust flake provides a 'default' package
      in
      rec {
        packages.default = pkgs.runCommand "flake-audit-report"
          {
            nativeBuildInputs = [ pkgs.bash ];
            inherit flakeAuditor;
          } ''
          mkdir -p $out
          # Invoke the Rust flake_auditor tool
          # The Rust tool will need to be updated to accept these arguments
          $flakeAuditor/bin/flake_auditor \
            --lock-files "$flake_lock_list_file" \
            --nix-files "$flake_nix_store_list_file" \
            --output "$out/audit-report.json"
        '';

        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "run-flake-audit" ''
            if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
              echo "Usage: $0 <lock_files_path> <nix_files_path> <output_path>"
              exit 1
            fi
            ${flakeAuditor}/bin/nix_auditor_rust \
              --lock-files "$1" \
              --nix-files "$2" \
              --output "$3"
          ''}";
        };
      }
    );
}
