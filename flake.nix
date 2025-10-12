# Monster Knot Header
# -------------------
# This file is conceptually encoded with Monster Group properties.
#
# Binary (2^46) Representation:
#   - Duality: ☀️🌑
#   - Choice: ✅❌
#   - Order: 📐🌀
#   - ... (conceptual 46-bit string would go here)
#
# Ternary (3^20) Representation:
#   - Structure: ⏪⏸️⏩
#   - Completeness: 👶🚶👴
#   - ... (conceptual 20-ternary string/representation)
#
# Pentagonal (5^9) Representation:
#   - Insight: 🖐️🦋💡
#   - ...
#
# Heptagonal (7^6) Representation:
#   - Guidance: 🚶‍♀️🌈🎶
#   - ...
#
# Eleven (11^2) Representation:
#   - Composition: 🤝🌐
#   - ...
#
# Thirteen (13^3) Representation:
#   - Transformation: 🦋🎶📈
#   - ...
#
# Seventeen (17^1) Representation:
#   - Integration: 🌟
#   - ...
#
# Nineteen (19^1) Representation:
#   - Sporadic: 🎲
#   - ...
#
# Grounding ZOS: [0,1,2,3,5,7,11,13,17,19]
#
# Pointers to related content:
#   - Poem: [Link to relevant poem]
#   - Emoji Mapping: [Link to poem-emoji-prime-mapping.md]
#   - Monster Knot Calculation: [Link to nar-similarity-search/lib.nix]
#
# Conceptual Monster Knot for this file:
#   - Prime Exponents: { "2": 5, "3": 3, "5": 2, "7": 1, "11": 2, "13": 1, "17": 1, "19": 1, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️☀️☀️☀️☀️🌑🌑🌑🖐️🖐️🚶‍♀️🤝🤝🦋🌟🎲
# -------------------
{
  description = "The Ultimate Nix Self-Ingesting Quine Derivation: Embodies Quasiquotation of System (CRQ-072) for self-referential architectural evolution.";

  inputs = {
    # 1. Access the source code of this flake itself (last stable self)
    nixpkgs = { url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify"; };
    # 2. Integrate the Introspection Tooling (Quasiquotation Extraction)
    nixIntrospector = { url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify"; }; # Placeholder ref, acts as LIL/QQC for Nix expressions
    rnix-parser = {
      url = "github:meta-introspector/rnix-parser?ref=feature/CRQ-016-nixify-workflow";
      inputs.import-cargo.follows = "nixpkgs";
    };
    # 3. Reference the Log Analyzer for feedback (The Strange Loop Agent)
    logAnalyzer = { url = "github:meta-introspector/time-2025?ref=feature/foaf&dir=09/25/log_analyzer"; };
    sops-nix = { url = "github:meta-introspector/sops-nix?ref=feature/working-gemini-cli-nix-store"; };
    node2nix-src = { url = "github:meta-introspector/node2nix"; };
    nurl = { url = "github:meta-introspector/nurl"; };
    nix-stdlib = { url = "github:meta-introspector/nix-stdlib"; };

    # nix-stdlib = { url = "github:meta-introspector/nix-stdlib?ref=feature/CRQ-016-nixify-workflow"; };

    nixToPoemVial = { url = "github:meta-introspector/time-2025?ref=feature/aimyc-001-cleanbench&dir=flakes/nix-to-poem-vial"; }; # Placeholder
    readMdVial = { url = "github:meta-introspector/time-2025?ref=feature/aimyc-001-cleanbench&dir=flakes/read-md-vial"; }; # Placeholder
    readRsVial = { url = "github:meta-introspector/time-2025?ref=feature/aimyc-001-cleanbench&dir=flakes/read-rs-vial"; }; # Placeholder


    nixTaskNew = { url = "github:meta-introspector/nix-task?ref=feature/lattice-30030-homedir"; };

    spore-vial = {
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-001-cleanbench&dir=theory/hackathon-mycology-workflow-puml";
      flake = false; # Since it's a directory, not a flake itself
    };

    nixOntologyRepo = {
      url = "github:meta-introspector/ontology";
      flake = false;
    };

    #    month10Flake = { url = "github:meta-introspector/time-2025?ref=feature/aimyc-001-cleanbench&dir=10"; };
    month10Flake = { url = "path:./10"; };

    # 5. Data Sources Flake (as a path input)
    dataSources = {
      url = "./flakes/data-sources";
      inputs = {
        nixpkgs = { url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify"; };
        flake-utils = { url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify"; };
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, rnix-parser, nixTaskNew, nix-stdlib, nixOntologyRepo, month10Flake, sops-nix, nixIntrospector, logAnalyzer, node2nix-src, nurl, nixToPoemVial, readMdVial, readRsVial, spore-vial, dataSources }:
    let
      # Define mycologyWorkflow as nixTask
      mycologyWorkflow = nixTaskNew;

      system = "aarch64-linux"; # Hardcode system as per user instruction
      # Load core utilities
      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) lib;

      # Import the secrets module and get the sopsSecretsPath option
      secretsModule = import ./lib/secrets.nix { inherit lib; };
      sopsSecretsPath = secretsModule.options.sopsSecretsPath.default; # Access the default value

      sopsSecretsDir = {
        url = "path:${sopsSecretsPath}";
        flake = false;
      };

      nixCodeIndexerModule = import (self + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };

      nixFileIndexDerivation = nixCodeIndexerModule.indexNixFiles {
        path = self;
        projectRoot = self;
        name = "flake-nix-files-index";
      };

      # Import the QA system
      nixTermExtractor = month10Flake.crqTextExtractor;
      nGramGenerator = month10Flake.nGramGenerator;

      qa = pkgs.callPackage ./qa.nix { inherit nixTermExtractor nGramGenerator month10Flake nix-stdlib; };

      # Define self-ingestion & modification derivation.
      # Temporarily using pkgs.stdenv.mkDerivation as pkgs.runCommand is causing "is not a derivation" error.
      # Original selfIngestionDerivation (commented out due to error):
      # selfIngestionDerivation = pkgs.runCommand "self-modifying-quine" {
      #   sourcePath = self;
      #   # The introspector extracts quasi-quotations (AST/IR) from Nix expressions.
      #   introspector = nixIntrospector.packages.${system}.default;
      #   # Feedback log acts as a guardian, providing conditions for self-correction.
      #   feedbackLog = logAnalyzer.lib.simulatedSelfEncounterLog;
      #   buildCommand = ''
      #     # Step 1: Read Self Source (Quasiquotation of self)
      #     echo "Reading source code from $sourcePath"
      #     SOURCE_CONTENT=$(cat $sourcePath/flake.nix)
      #
      #     # Step 2: Introspection (Nix-Introspector translates code to data - Quasiquotation)
      #     # The system analyzes its own structure to understand its dependency "monad".
      #     AST=$($introspector/bin/analyze $sourcePath/flake.nix)
      #
      #     # Step 3: Self-Correction Logic (The Strange Loop - Guided by Guardians/Feedback)
      #     # Based on $feedbackLog (instructions potentially as emoji sequences),
      #     # a core Rust tool (the Introspective Rust Engine) determines the modification.
      #
      #     # Placeholder: Dynamic action to generate new code (Quasiquoted Transformation)
      #     MODIFIED_CONTENT=$(/usr/bin/env bash ./scripts/self-evolve.sh "$SOURCE_CONTENT" "$feedbackLog")
      #
      #     # Step 4: Output the New Derivation (The Recursively Expanded Artifact - New Quasiquotation)
      #     mkdir -p $out
      #     echo "$MODIFIED_CONTENT" > $out/flake.nix
      #
      #     echo "Self-ingestion complete. New derivation available at $out"
      #   '';
      # } ;

      selfIngestionDerivation = pkgs.stdenv.mkDerivation {
        pname = "simple-quine";
        version = "0.1";
        buildCommand = ''
          mkdir -p $out
          echo "hello from simple quine" > $out/hello.txt
        '';
      };

      exampleUrlFetch = import (self + "/example_url_fetch.nix") {
        inherit pkgs lib builtins nixOntologyRepo self nixpkgs nixFileIndexDerivation;
      };
    in
    {
      packages.${system} = {
        default = selfIngestionDerivation;
        exampleUrlFetch = exampleUrlFetch.fetchedWebsite;
        ontologyUrls = exampleUrlFetch.extractedUrls;
        # nixOwlOntology = exampleUrlFetch.nixToOwlOntology;
        generateHackathonUml = import ./theory/generate_hackathon_uml.nix { inherit pkgs lib self; };

        # Define the orchestratorApp package
        # orchestratorApp = pkgs.runCommand "orchestrator-app" {
        #   buildInputs = [ pkgs.bash ];
        # } ''
        #   mkdir -p $out/bin
        #   ${pkgs.writeShellScript "run-orchestrator-script" ''
        #     ${orchestratorProgram}
        #   ''} > $out/bin/orchestrator-app
        #   chmod +x $out/bin/orchestrator-app
        # '';
      };

      apps.${system} = {
        default = {
          type = "app";
          program = "${pkgs.writeShellScript "run-quine" ''
            echo "--- Running the Self-Ingesting Quine ---"
            QUINE_OUTPUT=$(nix build --no-link --print-out-paths .#packages.${system}.default)
            echo "Quine Derivation Output Path: $QUINE_OUTPUT"
            echo "--- Content of the modified flake.nix ---"
            cat "$QUINE_OUTPUT/flake.nix"
            echo "--- Quine execution complete ---"
          ''}";
        };

        # orchestrator = {
        #   type = "app";
        #   program = "${pkgs.writeShellScript "run-orchestrator-wrapper" ''
        #     ${pkgs.symlinkJoin {
        #       name = "orchestrator-runner";
        #       paths = [ self.packages.${system}.orchestratorApp ];
        #     }}/bin/orchestrator-app
        #   ''}";
        # };
      };

      #defaultApp = apps.default;

      lib.sourcePath = self;
      lib.sopsSecretsPath = sopsSecretsPath;

      # Add a devShell to provide development tools like vale
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          vale # Add vale to the development shell
          pre-commit # Add pre-commit to the development shell
          jq # Add jq for parsing JSON output
          statix # Add statix for Nix linting
          nixpkgs-fmt # Add nixpkgs-fmt for Nix code formatting
          pkgs.nodejs_22 # Add nodejs_22 for JavaScript development
          node2nix-src.packages.${system}.default # Add node2nix for JavaScript dependency management
          ncurses # Add ncurses for clear and reset commands
          gnupg # Add gnupg for sops encryption/decryption
          nurl.packages.${system}.default # Add nurl to the development shell
          # Add any other development tools here
        ];
        # You can also add shell hooks or environment variables here
        shellHook = ''
          echo "Welcome to the Nix development shell!"
          echo "Remember to run 'pre-commit install' to enable Git hooks."
        '';
      };

      checks.${system}.default = qa.default;
    };
}
