# gemini-prompt-derivation.nix
# Builds a derivation by running gemini-cli with a given prompt.

{ pkgs, lib, prompt, gemini-cli, sops-nix }: # gemini-cli is now passed as an input

let
  # Define the system for flake-utils
  system = builtins.currentSystem;

  # Import the secrets definition
  secretsConfig = import ./secrets.nix { inherit pkgs lib; };

  # Derivation to decrypt sops secrets
  decryptedSopsSecrets = pkgs.stdenv.mkDerivation {
    pname = "decrypted-sops-secrets";
    version = "1.0";

    buildPhase = ''
      mkdir -p $out/.gemini
      ${pkgs.sops}/bin/sops -d ./sops-secrets/oauth_creds.json > $out/.gemini/oauth_creds.json
      ${pkgs.sops}/bin/sops -d ./sops-secrets/settings.json > $out/.gemini/settings.json
      ${pkgs.sops}/bin/sops -d ./sops-secrets/google_accounts.json > $out/.gemini/google_accounts.json
    '';

    buildInputs = [ pkgs.sops ];
  };

  # Path to the gemini-cli executable
  geminiCliPath = "${gemini-cli.packages.${system}.default}/bin/gemini";

in
pkgs.stdenv.mkDerivation {
  pname = "gemini-prompt-output";
  version = "1.0";

  # Source is just a dummy file, as the work is done in buildPhase
  src = pkgs.writeText "dummy" "gemini prompt derivation";
  dontUnpack = true;

  # Allow network access during the build
  __impure = true;

  buildInputs = [
    pkgs.nodejs_22 # gemini.js needs nodejs
    pkgs.cacert # For SSL/TLS
    gemini-cli.packages.${system}.default # Ensure gemini-cli is in buildInputs
    decryptedSopsSecrets # Add the derivation that decrypts sops secrets
  ];

  # Pass the prompt as an environment variable
  GEMINI_PROMPT = prompt;

  buildPhase = ''
    echo "🚀 Running gemini-cli with prompt: $GEMINI_PROMPT"
    mkdir -p $out

    # Set HOME to a writable temporary directory for gemini-cli
    export HOME=$(mktemp -d)
    trap 'rm -rf "$HOME"' EXIT

    # Copy credential files from decryptedSopsSecrets
    mkdir -p $HOME/.gemini/
    cp ${decryptedSopsSecrets}/.gemini/settings.json $HOME/.gemini/
    cp ${decryptedSopsSecrets}/.gemini/oauth_creds.json $HOME/.gemini/
    cp ${decryptedSopsSecrets}/.gemini/google_accounts.json $HOME/.gemini/
    echo "✅ Credentials copied from decryptedSopsSecrets to $HOME/.gemini/"

    # Execute gemini-cli and capture its output
    ${geminiCliPath} --debug --output-format json --approval-mode yolo --model gemini-2.5-flash --prompt "$GEMINI_PROMPT" > $out/gemini_output.json
    echo "✅ Gemini CLI output captured to $out/gemini_output.json"
  '';

  installPhase = ''
    echo "🎉 Gemini prompt derivation build complete!"
  '';
}
