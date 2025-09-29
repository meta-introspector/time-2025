{
  description = "Gemini CLI telemetry capture using working Nix store package";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini_cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { self, nixpkgs, flake-utils, gemini_cli }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      geminiCliPackagePath = "${gemini_cli.packages.aarch64-linux.default}/bin";
      testScriptPath = "${testScript}";
      geminiCliBinPath = "${gemini_cli.packages.aarch64-linux.default}/bin/gemini";

      testScript = pkgs.writeShellScript "test-gemini" ''
        echo "Test script running"
      '';

      geminiCliWrapper = { geminiCliPackagePath }: pkgs.writeShellScript "gemini-cli-wrapper" ''
        echo "Wrapper script running"
      '';

      geminiTelemetryTest = pkgs.stdenv.mkDerivation {
        pname = "gemini-telemetry-test-working";
        version = "1.0";
        src = pkgs.writeText "dummy-source" "";
        dontUnpack = true;
        __impure = true;
        buildInputs = [ pkgs.nodejs_22 ];
        GEMINI_CLI_WRAPPER = geminiCliWrapper { inherit geminiCliPackagePath; }; # Pass geminiCliPackagePath to geminiCliWrapper
        buildPhase = ''
          # Copy the creds directory from the host into the build environment
          mkdir -p creds
          cp -r /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/7-concepts/creds/* creds/

          echo "Attempting to copy credential files from creds/"
          ls -la creds/ # Check if creds directory exists and its contents
          GEMINI_CONFIG_DIR="/tmp/.gemini" # Use a known writable temporary directory
          mkdir -p "$GEMINI_CONFIG_DIR" # Create the .gemini directory
          # Copy specific credential files from creds/
          if [ -f "creds/oauth_creds.json" ]; then
            cp "creds/oauth_creds.json" "$GEMINI_CONFIG_DIR/"
            echo "Copied oauth_creds.json to $GEMINI_CONFIG_DIR/"
          else
            echo "Warning: creds/oauth_creds.json not found."
          fi

          if [ -f "creds/google_accounts.json" ]; then
            cp "creds/google_accounts.json" "$GEMINI_CONFIG_DIR/"
            echo "Copied google_accounts.json to $GEMINI_CONFIG_DIR/"
          else
            echo "Warning: creds/google_accounts.json not found."
          fi

          if [ -f "creds/settings.json" ]; then
            cp "creds/settings.json" "$GEMINI_CONFIG_DIR/"
            echo "Copied settings.json to $GEMINI_CONFIG_DIR/"
          else
            echo "Warning: creds/settings.json not found."
          fi

                      echo "testScript finished."
          
                      mkdir -p logs # Create the logs directory
          
                      # Run telemetry test
                      GEMINI_CONFIG_PATH="$GEMINI_CONFIG_DIR/settings.json" "$GEMINI_CLI_WRAPPER" 2>&1 | tee logs/capture.log        '';
        installPhase = ''
          mkdir -p $out/logs
          cp logs/capture.log $out/logs/
          echo "Installation complete - logs in $out/logs/"
        '';
      };
    in
    {
      packages.aarch64-linux.default = geminiTelemetryTest;

      apps.aarch64-linux.default = {
        type = "app";
        program = testScriptPath;
      };

      apps.aarch64-linux.gemini = {
        type = "app";
        program = geminiCliBinPath;
      };
    };
}
