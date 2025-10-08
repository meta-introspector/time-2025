{
  description = "Feature 7: Telemetry Capture - Captures telemetry from Gemini CLI execution.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit lib;

        # A function that takes a gemini-cli command and captures its telemetry
        captureGeminiTelemetry = { command, args ? [] }:
          pkgs.stdenv.mkDerivation {
            pname = "gemini-telemetry-capture";
            version = "1.0";

            src = pkgs.writeText "dummy" "telemetry capture";
            dontUnpack = true;

            __impure = true; # Network access for gemini-cli

            buildInputs = [
              pkgs.nodejs_22 # For gemini.js
              pkgs.jq        # For JSON processing
              gemini-cli.packages.${system}.default
            ];

            buildPhase = ''
              mkdir -p $out/{logs,telemetry}

              echo "=== Gemini Telemetry Capture Started ===" | tee $out/logs/capture.log
              echo "Timestamp: $(date -Iseconds)" | tee -a $out/logs/capture.log
              echo "Command: ${command} ${lib.concatStringsSep " " args}" | tee -a $out/logs/capture.log

              # Execute gemini-cli and capture output
              ${command} ${lib.concatStringsSep " " args} 2>&1 | tee -a $out/logs/capture.log
              GEMINI_EXIT_CODE=$?

              # Create telemetry summary
              cat > $out/telemetry/summary.json << EOF
              {
                "command": "${command}",
                "args": "${lib.concatStringsSep " " args}",
                "exit_code": ${GEMINI_EXIT_CODE},
                "timestamp": "$(date -Iseconds)"
              }
              EOF
              echo "=== Gemini Telemetry Capture Complete ===" | tee -a $out/logs/capture.log
            '';

            installPhase = ''
              echo "Telemetry captured in $out/logs/capture.log and $out/telemetry/summary.json"
            '';
          };

      in
      {
        lib = {
          inherit captureGeminiTelemetry;
        };

        packages.default = pkgs.writeText "telemetry-feature" "This flake provides Gemini telemetry capture.";
      }
    );
}