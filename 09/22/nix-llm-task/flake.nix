{
  description = "Nix flake for LLM tasks involving NAR files from crq-binstore";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crq-binstore = {
      url = "path:../../crq-binstore"; # Relative path to the crq-binstore directory
      flake = false; # Indicate that this is not a flake, but a directory of files
    };
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
