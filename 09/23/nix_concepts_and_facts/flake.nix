{
  description = "Nix derivations for numerical exploration concepts and AI context.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Use a stable nixpkgs for this flake
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # Define concepts locally within this flake
        concepts = {
          number-23 = pkgs.runCommand "number-23" {} ''
            set -x
            mkdir -p $out
            echo "23" > $out/number
          '';

          is-prime-script = pkgs.writeText "is-prime-script" ''
            #!/usr/bin/env bash
            set -euo pipefail

            number="$1"
            if (( number < 2 )); then
              echo "false"
              exit 0
            fi
            for ((i=2; i*i<=number; i++)); do
              if (( number % i == 0 )); then
                echo "false"
                exit 0
              fi
            done
            echo "true"
          '';

          is-prime-23 = pkgs.runCommand "is-prime-23" { } ''
            set -x
            mkdir -p $out
            chmod +x ${concepts.is-prime-script}
            ${concepts.is-prime-script} 23 > $out/result
          '';

          fact-23-oracle = pkgs.runCommand "fact-23-oracle" { }''
            set -x
            mkdir -p $out
            cp ${self}/facts/fact_about_23.txt $out/fact
          '';
        };

        # Aggregate AI context
        ai-context-23 = pkgs.runCommand "ai-context-23" { }''
          mkdir -p $out/concepts
          ln -s ${concepts.number-23}/number $out/concepts/number_23
          ln -s ${concepts.is-prime-23}/result $out/concepts/is_prime_23
          ln -s ${concepts.fact-23-oracle}/fact $out/concepts/fact_23
        '';

      in
      {
        packages.default = ai-context-23; # Make ai-context-23 the default package
        defaultPackage = ai-context-23; # Explicitly define default package
        inherit (concepts) number-23 is-prime-23 fact-23-oracle; # Expose individual concepts
      }
    );
}
