{
  description = "Nix derivations for numerical exploration concepts and AI context.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Use a stable nixpkgs for this flake
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = builtins.currentSystem;
      };

      # Define concepts locally within this flake
      concepts = {
        number-23 = pkgs.runCommand "number-23" {} ''
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
          ${concepts.is-prime-script} 23 > $out/result
        '';

        # Oracle for fact_23
        repo = pkgs.fetchGit {
          url = "https://github.com/meta-introspector/time-2025"; # Corrected URL
          ref = "feature/808017424794512875886459904961710757005754368000000000"; # Current branch
          rev = "af69f9671f9590b04c3254884e523e336a815d2d"; # Specific commit hash for the fact
        };

        fact-23-oracle = pkgs.runCommand "fact-23-oracle" { }''
          cp ${concepts.repo}/nix_concepts_and_facts/facts/fact_about_23.txt $out/fact
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
      inherit (concepts) number-23 is-prime-23 fact-23-oracle; # Expose individual concepts
    };
}
