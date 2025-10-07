{
  description = "Nix flake for LLM tasks involving NAR files from crq-binstore";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    crq-binstore.url = "github:meta-introspector/time-2025/feature/foaf?dir=09/22/crq-binstore";
  };

  outputs = { self, nixpkgs, flake-utils, crq-binstore }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nix
            nix-nar-unpack
            # Add any other tools needed for development here
          ];
          shellHook = ''
            echo "Entering LLM task development shell."
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "llm-nar-data-fetcher";
          version = "0.1.0";

          src = ./.; # This will be the directory containing the NAR fetching script

          buildInputs = [ pkgs.nix ]; # Ensure nix is available for nix-nar-unpack

          installPhase = ''
                        mkdir -p $out/bin
                        cp $src/fetch-nar-data.sh $out/bin/fetch-nar-data.sh
                        chmod +x $out/bin/fetch-nar-data.sh

                        # Create a wrapper script to set CRQ_BINSTORE_PATH
                        cat > $out/bin/fetch-nar-data-wrapper.sh << EOF
            #!/usr/bin/env bash
            export CRQ_BINSTORE_PATH=${crq-binstore}
            exec $out/bin/fetch-nar-data.sh "$@"
            EOF
                        chmod +x $out/bin/fetch-nar-data-wrapper.sh
          '';
        };
      });
}
