{
  description = "A Nix flake that consumes another flake and interacts with the Gemini API.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # The 'inputFlake' is where the user would specify the flake they want to provide as input.
    # For now, it's optional, and the consumer flake will just demonstrate Gemini API usage.
    inputFlake.url = "path:./."; # Placeholder, can be overridden by user
    inputFlake.flake = false; # Treat as a path, not necessarily a flake itself
  };

  outputs = { self, nixpkgs, flake-utils, inputFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonEnv = pkgs.python3.withPackages (p: with p; [
          google-generativeai
        ]);
      in
      {
        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "gemini-api-consumer-app" ''
            echo "--- Running Gemini API Consumer Flake ---"
            echo "Input Flake Path: ${inputFlake}"
            echo "Current directory: $(pwd)"

            # Ensure the Python environment is activated
            export PATH=${pythonEnv}/bin:$PATH

            # Check for GEMINI_API_KEY
            if [ -z "$GEMINI_API_KEY" ]; then
              echo "Error: GEMINI_API_KEY environment variable is not set." >&2
              echo "Please set it before running this flake, e.g.:" >&2
              echo "GEMINI_API_KEY='YOUR_API_KEY' nix run --impure ." >&2
              exit 1
            fi

            # Run the Python script
            python ${./gemini_consumer.py}
          ''}";
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "gemini-api-consumer";
          version = "0.1.0";
          src = ./.;
          buildInputs = [ pythonEnv ];
          installPhase = ''
            mkdir -p $out/bin
            cp ${./gemini_consumer.py} $out/bin/gemini_consumer.py
            substituteInPlace $out/bin/gemini_consumer.py --replace "import google.generativeai as genai" "import google.generativeai as genai"
            # Create a wrapper script to run the Python script
            cat > $out/bin/gemini-api-consumer <<EOF
            #!${pkgs.stdenv.shell}
            export PATH=${pythonEnv}/bin:$PATH
            if [ -z "$GEMINI_API_KEY" ]; then
              echo "Error: GEMINI_API_KEY environment variable is not set." >&2
              echo "Please set it before running this package, e.g.:" >&2
              echo "GEMINI_API_KEY='YOUR_API_KEY' $out/bin/gemini-api-consumer" >&2
              exit 1
            fi
            python $out/bin/gemini_consumer.py "$@"
            EOF
            chmod +x $out/bin/gemini-api-consumer
          '';
        };
      }
    );
}
