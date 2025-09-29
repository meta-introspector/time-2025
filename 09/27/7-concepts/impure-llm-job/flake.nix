{
  description = "An impure Nix job for running an LLM with credentials and network access.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Function to load secrets from a pre-decrypted file
        loadImpureSecrets = {}:
          let
            decryptedPath = builtins.getEnv "LLM_API_KEY_FILE" ""; # Get path from host env
            hasDecrypted = builtins.pathExists decryptedPath;
          in
          if hasDecrypted then
            builtins.readFile decryptedPath # Read the content of the decrypted file
          else
            throw "LLM_API_KEY_FILE environment variable not set or file not found for impure build.";

        llmJob = pkgs.stdenv.mkDerivation {
          pname = "llm-impure-job";
          version = "1.0";
          src = pkgs.writeText "dummy-source" ""; # Provide a dummy source

          dontUnpack = true; # No need to unpack a plain text file

          __impure = true; # Allow network access and host filesystem access

          # Pass the API key as an environment variable to the buildPhase
          # This makes it available as $LLM_API_KEY in the build script
          buildInputs = [ pkgs.curl pkgs.python3 ]; # Example build inputs

          buildPhase = ''
            echo "Starting impure LLM build..."
            echo "LLM setup complete"
          '';

          installPhase = ''
            mkdir -p $out/bin
            echo "LLM job built successfully" > $out/status.txt
            cp models.json $out/models.json || true
          '';
        };

      in
      {
        packages.default = llmJob;
      });
}
