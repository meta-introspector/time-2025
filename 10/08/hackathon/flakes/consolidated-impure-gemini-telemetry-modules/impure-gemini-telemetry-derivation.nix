{ filePath, mycologyContext, pkgs, gemini-cli, flakeNixContent, inputs }:
  pkgs.stdenv.mkDerivation {
    pname = "consolidated-impure-gemini-telemetry";
    version = "1.0";

    src = pkgs.writeText "dummy" "build telemetry";
    dontUnpack = true;

    __impure = true;

    buildInputs = [
      pkgs.nodejs_22
      pkgs.jq
      pkgs.curl
      pkgs.cacert
      gemini-cli.packages.${system}.default
    ];

    FLAKE_NIX_CONTENT = flakeNixContent;

    NIX_BUILD_TELEMETRY = "true";

    buildPhase = ''
      # ... (credential copying logic - hardcoded cp commands) ...
      # cp /data/data/com.termux.nix/files/home/.gemini/settings.json $HOME/.gemini/
      # cp /data/data/com.termux.nix/files/home/.gemini/oauth_creds.json $HOME/.gemini/
      # cp /data/data/com.termux.nix/files/home/.gemini/google_accounts.json $HOME/.gemini/
      # ... (Gemini CLI calls) ...
    '';

    installPhase = '';
  }
