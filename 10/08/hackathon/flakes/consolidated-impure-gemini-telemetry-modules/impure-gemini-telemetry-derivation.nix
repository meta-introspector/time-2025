rec {
  impureGeminiTelemetryDerivation = { filePath, mycologyContext, pkgs, gemini-cli, flakeNixContent, inputs, system }:
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

      buildPhase = "echo 'Building telemetry'";

      installPhase = "echo 'Installing telemetry'";
    };
}
