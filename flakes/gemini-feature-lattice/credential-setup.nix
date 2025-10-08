{
  lib,
  pkgs,
  builtins,
  geminiCliPackage,
  credentialsPath,
  ...
}:

let
  # A derivation that sets up a temporary HOME and copies credentials
  setupGeminiCredentials = pkgs.runCommand "gemini-credential-setup" {
    buildInputs = [ pkgs.bash ]; # Ensure bash is available for the script
  } ''
    export HOME=$(mktemp -d)
    trap 'rm -rf "$HOME"' EXIT # Clean up the temporary HOME directory on exit

    mkdir -p "$HOME/.gemini"
    cp -r ${credentialsPath}/* "$HOME/.gemini/"
    echo "✅ Credentials copied from ${credentialsPath} to $HOME/.gemini/"

    # The output of this derivation is the path to the temporary HOME
    echo "$HOME" > $out/home_path
  '';

in
{
  inherit setupGeminiCredentials;
}
