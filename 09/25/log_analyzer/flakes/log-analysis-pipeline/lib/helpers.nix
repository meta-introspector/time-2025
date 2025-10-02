{ system, secretScannerModule, log-analyzer-flake, build-time-gemini-capture-flake, ... } @ args:

let
  common = import ../../../lib/common-imports.nix { inherit system; };
  lib = common.lib;
  pkgs = common.pkgs;
  builtins = common.builtins;

  # Helper function for pure log analysis
  analyzePureLogsToStore = {
    logSourcePath, # Path to the log file within the Nix store
    name ? "analyzed-log",
  }:
    pkgs.stdenv.mkDerivation {
      pname = name;
      version = "1.0";
      __impure = true;
      nativeBuildInputs = [ log-analyzer-flake.packages.${system}.default ];
      buildCommand = ''
        mkdir -p $out
        RUST_BACKTRACE=1 ${log-analyzer-flake.packages.${system}.default}/bin/log_analyzer --log-file ${logSourcePath} > $out/analysis-result.txt
      '';
    };

  # Helper function for impure log analysis (reading from outside Nix store)
  analyzeImpureLogsToStore = {
    logFilePath, # Path to the log file on the host filesystem
    name ? "analyzed-impure-log",
  }:
    let
      secretScanResult = secretScannerModule.scanForSecrets {
        filePath = logFilePath;
        name = "${name}-secret-scan";
      };
    in
    pkgs.stdenv.mkDerivation {
      pname = name;
      version = "1.0";
      __impure = true; # Explicitly mark as impure
      __noChroot = true; # Allow access to host filesystem
      nativeBuildInputs = [ log-analyzer-flake.packages.${system}.default ];
      buildCommand = ''
        mkdir -p $out
        # Check secret scan result
        if [ "$(cat ${secretScanResult}/status.txt)" = "SECRETS_DETECTED=true" ]; then
          echo "WARNING: Secrets detected in ${logFilePath}. Review ${secretScanResult}/secret_report.txt" >&2
          # In a real scenario, this might exit 1 to halt the build.
        fi
        RUST_BACKTRACE=1 ${log-analyzer-flake.packages.${system}.default}/bin/log_analyzer --log-file ${logFilePath} > $out/analysis-result.txt
      '';
    };

  # Helper function for analyzing logs from a NAR file (impure fetch)
  analyzeNarLogsToStore = {
    narUrl, # URL to the NAR file
    narHash, # Hash of the NAR file
    logFileName ? "telemetry.log", # Expected name of the log file inside the NAR
    name ? "analyzed-nar-log",
  }:
    pkgs.stdenv.mkDerivation {
      pname = name;
      version = "1.0";
      __impure = true; # Fetching from external URL is impure
      nativeBuildInputs = [ log-analyzer-flake.packages.${system}.default pkgs.gnutar ]; # gnutar for extracting NAR
      
      # Fetch the NAR file
      narFile = pkgs.fetchurl {
        url = narUrl;
        sha256 = narHash;
      };

      buildCommand = ''
        mkdir -p $out
        # Extract the NAR file
        tar -xf $narFile -C .
        # Find the log file within the extracted NAR content
        # Assuming the NAR contains a single directory or the log file at its root
        LOG_FILE_PATH=$(find . -name "${logFileName}" | head -n 1)
        if [ -z "$LOG_FILE_PATH" ]; then
          echo "Error: Log file '${logFileName}' not found in NAR." >&2
          exit 1
        fi
        RUST_BACKTRACE=1 ${log-analyzer-flake.packages.${system}.default}/bin/log_analyzer --log-file $LOG_FILE_PATH > $out/analysis-result.txt
      '';
    };

in
{
  inherit analyzePureLogsToStore analyzeImpureLogsToStore analyzeNarLogsToStore;
}
