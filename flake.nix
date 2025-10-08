{
  description = "The Ultimate Nix Self-Ingesting Quine Derivation: Embodies Quasiquotation of System (CRQ-072) for self-referential architectural evolution.";

  inputs = {
    # 1. Access the source code of this flake itself (last stable self)
    self.url = "github:meta-introspector/streamofrandom?ref=feature/foaf"; # Assuming current branch is stable self
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    # 2. Integrate the Introspection Tooling (Quasiquotation Extraction)
    nixIntrospector.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify"; # Placeholder ref, acts as LIL/QQC for Nix expressions
    # 3. Reference the Log Analyzer for feedback (The Strange Loop Agent)
    logAnalyzer.url = "github:meta-introspector/time-2025?ref=feature/foaf&dir=09/25/log_analyzer";
    sops-nix.url = "github:meta-introspector/sops-nix?ref=feature/working-gemini-cli-nix-store";
    node2nix-src.url = "github:meta-introspector/node2nix";

    spore-vial = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=theory/hackathon-mycology-workflow-puml";
      flake = false; # Since it's a directory, not a flake itself
    };

    # 4. Ontology repository for Nix concepts
    nixOntologyRepo = {
      url = "github:meta-introspector/ontology";
      flake = false;
    };

    # 5. Data Sources Flake (as a path input)
    dataSources = {
      url = "./flakes/data-sources";
      inputs = {
        nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
        flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
      };
    };

    mycologyWorkflow = {
      url = "./flakes/mycology-workflow";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "nixIntrospector"; # Assuming nixIntrospector provides flake-utils
        dataSources.follows = "dataSources";
        spore-vial.follows = "spore-vial";
      };
    };
  };

  outputs = { self, nixpkgs, nixIntrospector, logAnalyzer, nixOntologyRepo, sops-nix, node2nix-src, mycologyWorkflow, dataSources, ... }:
    let
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
        name = "flake-nix-files-index";
      };

      # Import the QA system
      qa = import ./qa.nix { inherit pkgs self; };

      # 4. Define the SELF-INGESTION & MODIFICATION derivation (Quasiquoted Transformation)
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
        nixOwlOntology = exampleUrlFetch.nixToOwlOntology;
        generateHackathonUml = import ./theory/generate_hackathon_uml.nix { inherit pkgs lib self; };
        mycologyWorkflowPuml = (import ./flakes/mycology-workflow {
          nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
          flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
          inherit dataSources; # Pass the dataSources path input
          spore-vial.url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=theory/hackathon-mycology-workflow-puml";
        }).packages.${system}.default;
        # nixOntologyRepoPath = pkgs.runCommand "nix-ontology-repo-path" {} "ln -s ${nixOntologyRepo} $out"; # Expose nixOntologyRepo as a derivation
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

        orchestrator = {
          type = "app";
          program = "${pkgs.writeShellScript "run-orchestrator-app" ''
            echo "--- Starting the Orchestrator ---"
            nix run .#orchestrator
            echo "--- Orchestrator Finished ---"
          ''}";
        };
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
          pkgs.nodejs_22 # Add nodejs_22 for JavaScript development
          node2nix-src.packages.${system}.default # Add node2nix for JavaScript dependency management
          ncurses # Add ncurses for clear and reset commands
          gnupg # Add gnupg for sops encryption/decryption
          # Add any other development tools here
        ];
        # You can also add shell hooks or environment variables here
        shellHook = ''
          echo "Welcome to the Nix development shell!"
          echo "Remember to run 'pre-commit install' to enable Git hooks."
        '';
      };

      checks.${system} = qa.checks;
    };}
