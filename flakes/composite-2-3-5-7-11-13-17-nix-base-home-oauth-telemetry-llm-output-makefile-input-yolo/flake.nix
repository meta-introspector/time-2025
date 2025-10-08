{
  description = "Composite Flake: Combines Nix Base (2), Home Directory Credentials (3), OAuth Credentials (5), Telemetry Capture (7), LLM Output Capture (11), Makefile Input (13), and YOLO Approval (17).";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";

    # Feature flakes as inputs
    feature2 = {
      url = "path:../feature-2-nix-base";
      flake = false;
    };
    feature3 = {
      url = "path:../feature-3-home-dir-creds";
      flake = false;
    };
    feature5 = {
      url = "path:../feature-5-oauth-creds";
      flake = false;
    };
    feature7 = {
      url = "path:../feature-7-telemetry-capture";
      flake = false;
    };
    feature11 = {
      url = "path:../feature-11-llm-output-capture";
      flake = false;
    };
    feature13 = {
      url = "path:../feature-13-makefile-input";
      flake = false;
    };
    feature17 = {
      url = "path:../feature-17-yolo-approval";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli, feature2, feature3, feature5, feature7, feature11, feature13, feature17, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Get pkgs and lib from feature-2-nix-base
        baseLib = import feature2 { inherit nixpkgs flake-utils; }.lib.${system};
        inherit (baseLib) pkgs lib;

        # Get the geminiCliWithHomeCreds from feature-3-home-dir-creds
        homeCredsApp = import feature3 { inherit nixpkgs flake-utils gemini-cli; }.apps.${system}.default;

        # Get OAuth credential info from feature-5-oauth-creds
        oauthLib = import feature5 { inherit nixpkgs flake-utils; }.lib.${system};

        # Get telemetry capture function from feature-7-telemetry-capture
        telemetryLib = import feature7 { inherit nixpkgs flake-utils gemini-cli; }.lib.${system};

        # Get LLM output capture function from feature-11-llm-output-capture
        llmOutputLib = import feature11 { inherit nixpkgs flake-utils; }.lib.${system};

        # Get Makefile input processing function from feature-13-makefile-input
        makefileInputLib = import feature13 { inherit nixpkgs flake-utils; }.lib.${system};

        # Get YOLO approval function from feature-17-yolo-approval
        yoloApprovalLib = import feature17 { inherit nixpkgs flake-utils; }.lib.${system};

      in
      {
        packages = {
          inherit (homeCredsApp) default; # Expose the app from feature-3
        };

        apps = {
          default = homeCredsApp;
        };

        lib = {
          inherit (telemetryLib) captureGeminiTelemetry;
          inherit (oauthLib) hasOAuthCredentials getOAuthCredentials;
          inherit (llmOutputLib) captureLLMOutputs;
          inherit (makefileInputLib) processMakefileInput;
          inherit (yoloApprovalLib) withYoloApproval;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            gemini-cli.packages.${system}.default
            homeCredsApp.drv # Access the underlying derivation of the app
          ];

          shellHook = ''
            echo "Welcome to the composite devShell with Nix Base, Home Directory Credentials, OAuth Credentials, Telemetry Capture, LLM Output Capture, Makefile Input, and YOLO Approval."
            echo "Use 'gemini-cli-with-home-creds' to run gemini-cli with credentials from your host ~/.gemini."
            ${lib.optionalString oauthLib.hasOAuthCredentials "echo \"OAuth credentials feature is present.\" "}
            echo "Telemetry capture function available via 'captureGeminiTelemetry'."
            echo "LLM output capture function available via 'captureLLMOutputs'."
            echo "Makefile input processing function available via 'processMakefileInput'."
            echo "YOLO approval function available via 'withYoloApproval'."
          '';
        };
      }
    );
}
