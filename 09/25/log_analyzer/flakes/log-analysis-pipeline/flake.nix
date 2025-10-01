{
  description = "A Nix-flake for analyzing build telemetry logs using log_analyzer";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    log-analyzer-flake.url = "github:meta-introspector/streamofrandom?ref=feature/foaf&dir=2025/09/25/log_analyzer";
    build-telemetry-flake.url = "github:meta-introspector/time-2025?ref=feature/vale-precommit&dir=09/27/7-concepts/6-qa-testing/tests/2025-01-27-build-time-gemini-capture";
    secret-scanner-flake.url = "github:meta-introspector/streamofrandom?ref=feature/foaf&dir=2025/10/01/docs/theory/secret_scanner.nix";
    nix2gramIndexerModule.url = "github:meta-introspector/streamofrandom?ref=feature/foaf&dir=2025/10/01/docs/theory/nix_2gram_indexer.nix";
    nGramGeneratorModule.url = "github:meta-introspector/streamofrandom?ref=feature/foaf&dir=2025/10/01/docs/theory/n_gram_generator.nix";
    twoGramReportGeneratorModule.url = "github:meta-introspector/streamofrandom?ref=feature/foaf&dir=2025/10/01/docs/theory/2gram_report_generator.nix";
  };

  outputs = { self, nixpkgs, flake-utils, log-analyzer-flake, build-telemetry-flake, secret-scanner-flake, nix2gramIndexerModule, nGramGeneratorModule, twoGramReportGeneratorModule }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Build the buildTimeTelemetry derivation to get its output
        buildTimeTelemetryOutput = build-telemetry-flake.packages.${system}.default;

        # Helper function for pure log analysis
        analyzePureLogsToStore = {
          logSourcePath, # Path to the log file within the Nix store
          name ? "analyzed-log",
        }:
          pkgs.stdenv.mkDerivation {
            pname = name;
            version = "1.0";
            __impure = true;
            nativeBuildInputs = [ log-analyzer-flake.packages.${system}.log-analyzer ];
            buildCommand = ''
              mkdir -p $out
              RUST_BACKTRACE=1 ${log-analyzer-flake.packages.${system}.log-analyzer}/bin/log_analyzer --log-file ${logSourcePath} > $out/analysis-result.txt
            '';
          };

        # Helper function for impure log analysis (reading from outside Nix store)
        analyzeImpureLogsToStore = {
          logFilePath, # Path to the log file on the host filesystem
          name ? "analyzed-impure-log",
        }:
          let
            secretScanResult = secret-scanner-flake.scanForSecrets {
              filePath = logFilePath;
              name = "${name}-secret-scan";
            };
          in
          pkgs.stdenv.mkDerivation {
            pname = name;
            version = "1.0";
            __impure = true; # Explicitly mark as impure
            __noChroot = true; # Allow access to host filesystem
            nativeBuildInputs = [ log-analyzer-flake.packages.${system}.log-analyzer ];
            buildCommand = ''
              mkdir -p $out
              # Check secret scan result
              if [ "$(cat ${secretScanResult}/status.txt)" = "SECRETS_DETECTED=true" ]; then
                echo "WARNING: Secrets detected in ${logFilePath}. Review ${secretScanResult}/secret_report.txt" >&2
                # In a real scenario, this might exit 1 to halt the build.
              fi
              RUST_BACKTRACE=1 ${log-analyzer-flake.packages.${system}.log-analyzer}/bin/log_analyzer --log-file ${logFilePath} > $out/analysis-result.txt
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
            nativeBuildInputs = [ log-analyzer-flake.packages.${system}.log-analyzer pkgs.gnutar ]; # gnutar for extracting NAR
            
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
              RUST_BACKTRACE=1 ${log-analyzer-flake.packages.${system}.log-analyzer}/bin/log_analyzer --log-file $LOG_FILE_PATH > $out/analysis-result.txt
            '';
          };

      in
      {
        packages.default = analyzePureLogsToStore {
          logSourcePath = "${buildTimeTelemetryOutput}/logs/build-time-capture.log";
          name = "analyzed-build-telemetry-log";
        };

        packages.analyzePureLogsToStore = analyzePureLogsToStore {
          logSourcePath = "${buildTimeTelemetryOutput}/logs/build-time-capture.log";
          name = "analyzed-build-telemetry-log";
        };

        packages.analyzeImpureLogsToStore = analyzeImpureLogsToStore {
          logFilePath = "/dev/null"; # Temporarily hardcoded for testing
          name = "analyzed-system-log";
        };

        packages.analyzeNarLogsToStore = analyzeNarLogsToStore {
          narUrl = "https://example.com/path/to/logs.nar"; # Placeholder URL
          narHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder hash
          name = "analyzed-remote-nar-log";
        };

        packages.build2GramIndex = nix2gramIndexerModule.generate2GramIndex {
          projectRoot = self; # The flake itself is the project root
          name = "project-2gram-index";
        };

        packages.generate2GramReport = twoGramReportGeneratorModule.generate2GramReport {
          twoGramIndexJsonPath = self.packages.${system}.build2GramIndex; # Use the output of the 2-gram index build
          name = "project-2gram-report";
        };

        lib = {
          inherit analyzePureLogsToStore analyzeImpureLogsToStore analyzeNarLogsToStore;
        };
      }
    );
}