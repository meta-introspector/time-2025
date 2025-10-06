# Makefile for topological Nix builds

.PHONY: all pre-nix-check build-foaf-context

# Ensure no unstaged or uncommitted Nix files before running Nix commands.
# This helps maintain purity and prevents accidental builds from dirty working directories.
pre-nix-check:
	@echo "--- Running pre-Nix check: Ensuring no unstaged or uncommitted Nix files ---"
	@if git status --porcelain -- '*.nix' | grep -q .; then \
		echo "ERROR: Unstaged or uncommitted Nix files found. Please commit or stash them before proceeding."; \
		git status --porcelain -- '*.nix'; \
		exit 1; \
	fi
	@echo "--- Pre-Nix check passed. No unstaged or uncommitted Nix files found. ---"

# Build the FOAF context flake.
# This target evaluates the 'foaf/context' flake and prints its 'foafContext' attribute.
# It demonstrates how to build a single-concept flake and retrieve its output.
build-foaf-context: pre-nix-check
	@echo "--- Building FOAF Context Flake ---"
	nix eval --raw .#lib.foafContext
	@echo "--- FOAF Context Flake Built ---"

all: build-foaf-full-graph

# Build the GitHub FOAF data flake.
# This target evaluates the 'foaf/github-data' flake and prints its 'githubEntities' attribute as JSON.
build-github-foaf-data: pre-nix-check
	@echo "--- Building GitHub FOAF Data Flake ---"
	nix eval --json .#lib.githubEntities
	@echo "--- GitHub FOAF Data Flake Built ---"

# Debugging the Aggregator Flake (TikTok Short: Isolating Flake Errors)
# This target directly evaluates the aggregator flake to pinpoint syntax issues.
# It bypasses the root flake to ensure the error is within the aggregator itself.
debug-aggregator-flake: pre-nix-check
	@echo "--- Debugging Aggregator Flake Directly ---"
	nix eval --json ./flakes/foaf/aggregator#aarch64-linux.lib.fullGraph
	@echo "--- Aggregator Flake Debug Complete ---"

# Debugging the Aggregator Flake with Trace (TikTok Short: Advanced Nix Debugging)
# This target directly evaluates the aggregator flake with --show-trace to get detailed error information.
debug-aggregator-flake-trace: pre-nix-check
	@echo "--- Debugging Aggregator Flake Directly with Trace ---"
	nix eval --json --show-trace ./flakes/foaf/aggregator#lib.fullGraph
	@echo "--- Aggregator Flake Debug Trace Complete ---"

# Debugging Attribute Path Issue (TikTok Short: Nix Flake Output Paths)
# This target evaluates a minimal flake to reproduce and debug the attribute path resolution issue.
# It helps understand how flake-utils.lib.eachDefaultSystem structures its outputs.
debug-attribute-path-flake:
	@echo "--- Debugging Attribute Path Flake ---"
	nix eval --json ./bug_repro_attribute_path#aarch64-linux.lib.foo
	@echo "--- Attribute Path Flake Debug Complete ---"

# Build the full FOAF graph from the aggregator flake.
# This target evaluates the 'foaf/aggregator' flake and prints its 'fullGraph' attribute as JSON.
build-foaf-full-graph: pre-nix-check
	@echo "--- Building Full FOAF Graph ---"
	nix eval --json .#lib.fullGraph
	@echo "--- Full FOAF Graph Built ---"

# Build the FOAF seed data flake.
# This target evaluates the 'foaf/seed-data' flake and prints its 'seedGraph' attribute.
# It demonstrates how to build a single-concept flake and retrieve its output.
build-foaf-seed-data: pre-nix-check
	@echo "--- Building FOAF Seed Data Flake ---"
	nix eval --json .#lib.seedGraph
	@echo "--- FOAF Seed Data Flake Built ---"

.PHONY: all pre-nix-check build-foaf-context install-hooks

# ... existing targets ...

.PHONY: all pre-nix-check build-foaf-context install-hooks strace-install-hooks uninstall-pre-commit gc-pre-commit clean-pre-commit git-commit strace-git-commit statix-hackathon-parts

# ... existing targets ...

.PHONY: install_hook
install_hook:
	@./install_hook_script.sh "$(DRY_RUN)"

# New target to install pre-commit hooks within the Nix development environment
install-hooks:
	@echo "--- Installing pre-commit hooks within Nix development environment ---"
	# nix develop --command runs a command within the Nix development shell
	# This ensures that 'pre-commit' and 'vale' (and other devShell packages) are available
	nix develop --command bash -c "pre-commit install"
	@echo "--- pre-commit hooks installed. You can now 'git commit'. ---"

# Target to run pre-commit install with strace to debug the installation process
strace-install-hooks:
	@echo "--- Running pre-commit install with strace ---"
	nix develop --command bash -c "strace -o strace_install.txt -s 999 -f pre-commit install"
	@echo "--- strace-install-hooks complete. Check strace_install.txt for output. ---"

# Target to uninstall pre-commit hooks
uninstall-pre-commit:
	@echo "--- Uninstalling pre-commit hooks ---"
	nix develop --command bash -c "pre-commit uninstall"
	@echo "--- pre-commit hooks uninstalled. ---"

# Target to run pre-commit garbage collection
gc-pre-commit:
	@echo "--- Running pre-commit garbage collection ---"
	nix develop --command bash -c "pre-commit gc"
	@echo "--- pre-commit garbage collection complete. ---"

# Target to clean pre-commit cache
clean-pre-commit:
	@echo "--- Cleaning pre-commit cache ---"
	nix develop --command bash -c "pre-commit clean"
	@echo "--- pre-commit cache cleaned. ---"

.PHONY: reproduce-nix-segfault
reproduce-nix-segfault:
	@echo "--- Reproducing Nix Segmentation Fault and Capturing Logs ---"
	@bash -c "./scripts/reproduce_nix_build_log.sh"
	@bash -c "./scripts/reproduce_nix_build_strace.sh"
	@bash -c "./scripts/reproduce_nix_flake_check_log.sh"
	@bash -c "./scripts/reproduce_nix_flake_check_strace.sh"
	@echo "--- Nix Segmentation Fault Reproduction Complete. Check log files. ---"

# New target to run git commit within the Nix development environment
git-commit:
	@echo "--- Running git commit within Nix development environment ---"
	# Expects a commit message file named 'commit_message.txt' in the project root.
	# nix develop --command runs a command within the Nix development shell
	# This ensures that 'pre-commit' and 'vale' (and other devShell packages) are available
	# We pass the commit message from the file using -F
	nix develop --command bash -c "git commit -F commit_message.txt"
	@echo "--- git commit complete. ---"

# Target to run git commit with strace to debug pre-commit hook issues
strace-git-commit:
	@echo "--- Running git commit with strace ---"
	# We use a dummy commit message here, as the focus is on stracing the pre-commit hooks.
	nix develop --command bash -c "strace -o strace.txt -s 999 -f git commit -m 'strace test commit'"
	@echo "--- strace-git-commit complete. Check strace.txt for output. ---"

# Target to get the commit message regex from regex-generator.nix
# This is useful for debugging and understanding the commit message validation rules.
get-commit-regex:
	@echo "--- Getting Commit Message Regex ---"
	@nix-instantiate --eval --json regex-generator.nix --arg pkgs '(import <nixpkgs> {})'
	@echo "--- Commit Message Regex Retrieved ---"

# Target to check CRQ/Incident/Task document existence using the Nix flake app.
# This is used by the pre-commit hook.
check-crq-document:
	@echo "--- Running CRQ/Incident/Task Document Existence Check ---"
	@nix run .#aarch64-linux.crq-document-check -- $(COMMIT_MSG_FILE)
	@echo "--- CRQ/Incident/Task Document Existence Check Complete ---"

# Target to test the CRQ/Incident/Task document existence check script.
# Usage: make test-crq-document-check COMMIT_MSG_FILE=path/to/commit_message.txt
test-crq-document-check:
	@echo "--- Running CRQ/Incident/Task Document Existence Test ---"
	@$(NIX_BUILD_CRQ_CHECK_CMD) $(COMMIT_MSG_FILE)
	@echo "--- CRQ/Incident/Task Document Existence Test Complete ---"

NIX_BUILD_CRQ_CHECK_CMD = nix build .#aarch64-linux.crq-document-check-script --no-link --print-out-paths | xargs -I {} {}

# Target to test the crq-search.nix function.
# Usage: make test-crq-search [KEYWORD="your_keyword"]
test-crq-search:
	@echo "--- Testing crq-search.nix ---"
	@nix eval --json --expr 'let pkgs = import (builtins.getFlake "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify").legacyPackages.aarch64-linux; crqSearch = import ./10/04/lib/crq-search.nix { inherit pkgs; crqDir = ./docs/crqs; }; in crqSearch { keyword = "$(KEYWORD)"; }'
	@echo "--- crq-search.nix Test Complete ---"

# Target to search CRQs by keyword or list latest suggestions.
# Usage: make search-crqs [KEYWORD="your_keyword"]
search-crqs:
	@echo "--- Searching CRQs ---"
	@nix eval --json .#crqFunctions.search --apply "f: f { system = \"aarch64-linux\"; commitMsgFile = \"$(COMMIT_MSG_FILE)\"; }"
	@echo "--- CRQ Search Complete ---"

# Target to list CRQs with optional keyword filtering and number of suggestions.
# Usage: make list-crqs [KEYWORD="your_keyword"] [NUM_SUGGESTIONS=3]
list-crqs:
	@echo "--- Listing CRQs ---"
	@nix eval --json --expr 'let
	  flake = builtins.getFlake (toString ./.);
	  system = builtins.currentSystem;
	  searchCrqs = flake.inputs.flakes.crq-search.main.lib.${system}.searchCrqs;
	  keyword = builtins.getEnv "KEYWORD";
	  numSuggestions = builtins.fromJSON (builtins.getEnv "NUM_SUGGESTIONS" or "3");
	  crqDir = ./docs/crqs;
	in
	builtins.toJSON (searchCrqs crqDir (if keyword == "" then null else keyword) numSuggestions)'
	@echo "--- CRQ Listing Complete ---"

# Target to build the base CRQ search lattice flake.
build-crq-search-lattice-base: pre-nix-check
	@echo "--- Building Base CRQ Search Lattice Flake ---"
	@cd flakes/crq-search-lattice/base && nix build .#packages.aarch64-linux.default
	@echo "--- Base CRQ Search Lattice Flake Built ---"

# Target to enter a development shell for the base CRQ search lattice flake.
develop-crq-search-lattice-base: pre-nix-check
	@echo "--- Entering Development Shell for Base CRQ Search Lattice Flake ---"
	@cd flakes/crq-search-lattice/base && nix develop
	@echo "--- Exited Development Shell for Base CRQ Search Lattice Flake ---"


# Target to build the layer1 CRQ search lattice flake.
build-crq-search-lattice-layer1: pre-nix-check
	@echo "--- Building Layer 1 CRQ Search Lattice Flake ---"
	@cd flakes/crq-search-lattice/layer1 && nix build .#packages.aarch64-linux.default
	@echo "--- Layer 1 CRQ Search Lattice Flake Built ---"

# Target to enter a development shell for the layer1 CRQ search lattice flake.
develop-crq-search-lattice-layer1: pre-nix-check
	@echo "--- Entering Development Shell for Layer 1 CRQ Search Lattice Flake ---"
	@cd flakes/crq-search-lattice/layer1 && nix develop
	@echo "--- Exited Development Shell for Layer 1 CRQ Search Lattice Flake ---"


# Nix Code Quality and Static Analysis with Statix
# Statix is a linter and static analysis tool for Nix expressions. It helps enforce
# coding standards, identify potential issues, and improve the overall quality
# and maintainability of Nix code. In the context of the 'bott' framework,
# Statix contributes to the 'Refinement/Communication' (bott 17) and
# 'Verification and Testing' (bott 13) aspects by ensuring the structural
# integrity and adherence to best practices in our Nix architectural genome.

clean :
	rm -f statix_output.txt statix_output_part_*
	# echo
# Target to lint Nix files using statix.
lint-nix: clean pre-nix-check
	@echo "--- Linting Nix files with statix ---"
	-nix develop --command bash -c "statix check . > statix_output.txt 2>&1" || true
	@echo "--- Nix linting complete. Output saved to statix_output.txt ---"
	@nix develop --command bash -c "$(PROJECT_ROOT)/scripts/generate_statix_report_v3.sh"
	@echo "--- Splitting statix_output.txt into smaller files ---"
	split -l 100 statix_output.txt statix_output_part_
	@echo "--- statix_output.txt split into statix_output_part_aa, statix_output_part_ab, etc. ---"

# Target to run statix check on all Nix files in the project.
# This provides a comprehensive overview of code quality across the entire Nix codebase.
statix-all: pre-nix-check
	@echo "--- Running statix check on all Nix files in the project ---"
	nix develop --command bash -c "statix check ."
	@echo "--- Statix check on all Nix files complete ---"

# Target to run statix check on hackathon_71_parts.nix
statix-hackathon-parts: pre-nix-check
	@echo "--- Running statix check on 10/03/hackathon_71_parts.nix ---"
	nix run github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify#statix -- check 10/03/hackathon_71_parts.nix
	@echo "--- statix check on hackathon_71_parts.nix complete ---"

.PHONY: debug-pkgs-writeShellScriptBin-type statix-all
debug-pkgs-writeShellScriptBin-type:
	@echo "--- Debugging pkgs.writeShellScriptBin type ---"
	@nix eval --raw --impure --expr 'let pkgs = (builtins.getFlake "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify").outputs.legacyPackages.aarch64-linux; in builtins.typeOf pkgs.writeShellScriptBin'
	@echo "--- Debugging pkgs.writeShellScriptBin type Complete ---"

.PHONY: debug-nix-eval-args
debug-nix-eval-args:
	@echo "--- Debugging nix eval arguments ---"
	@nix eval --json --arg pkgs '${nixpkgs}' --arg crqCheckLib '${./10/04/lib/crq-document-check.nix}' --argstr commitMsgFile "dummy_commit_msg.txt" --expr 'let pkgs = import pkgs {}; in import crqCheckLib { inherit pkgs; commitMsgFile = commitMsgFile; }'
	@echo "--- Debugging nix eval arguments Complete ---"

.PHONY: debug-crq-check-lib-eval
debug-crq-check-lib-eval:

# Perform a comprehensive check of the flake, enabling impure-derivations and ca-derivations.
flake-check-impure:
	@echo "--- Running Nix Flake Check with Impure and CA Derivations ---"
	@nix flake check --extra-experimental-features "impure-derivations ca-derivations"
	@echo "--- Nix Flake Check Complete ---"

	@nix eval --json --arg pkgs '${nixpkgs}' --argstr commitMsgFile "dummy_commit_msg.txt" --expr 'import ${./10/04/lib/crq-document-check.nix} { pkgs = import pkgs {}; commitMsgFile = commitMsgFile; }'

# Debugging the absolute path to plantuml_generator.nix within the flake context.
debug-plantuml-path:
	@echo "--- Debugging PlantUML Generator Path ---"
	@nix eval --raw --impure --expr '(builtins.path { path = ./.; name = "flake-root"; }) + "/lib/plantuml_generator.nix"'
	@echo "--- PlantUML Generator Path Debug Complete ---"

# Nix File Evaluation Targets

.PHONY: eval-github-graphql-example-queries
eval-github-graphql-example-queries:
	@echo "--- Evaluating github_graphql_parts/github_graphql_example_queries.nix ---"
	@nix eval --impure --expr 'let buildGraphQLQuery = {}; in import ./github_graphql_parts/github_graphql_example_queries.nix { inherit buildGraphQLQuery; }'
	@echo "--- Evaluation Complete ---"

.PHONY: eval-unmath-owl
eval-unmath-owl:
	@echo "--- Evaluating 10/01/docs/theory/unmath.owl.nix ---"
	@nix eval --impure --expr 'import ./10/01/docs/theory/unmath.owl.nix'
	@echo "--- Evaluation Complete ---"

.PHONY: eval-github-graphql-part1
eval-github-graphql-part1:
	@echo "--- Evaluating github_graphql_parts/github_graphql_part1.nix ---"
	@nix eval --impure --expr 'let nixpkgsFlake = builtins.getFlake "nixpkgs"; in import ./github_graphql_parts/github_graphql_part1.nix { nixpkgs = nixpkgsFlake; }'
	@echo "--- Evaluation Complete ---"

.PHONY: eval-failure-derivation
eval-failure-derivation:
	@echo "--- Evaluating test-commit-check/failure-derivation.nix ---"
	@nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; in import ./test-commit-check/failure-derivation.nix { inherit pkgs; commitMsg = "test"; regex = ".*"; }'
	@echo "--- Evaluation Complete ---"

.PHONY: eval-31-mathematical-forms-prime-03
eval-31-mathematical-forms-prime-03:
	@echo "--- Evaluating theory/31-mathematical-forms-prime-03.nix ---"
	@nix eval --raw --impure --expr 'let pkgs = import (builtins.getFlake "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify").legacyPackages.aarch64-linux; lib = pkgs.lib; n = 31; in toString (import ./theory/31-mathematical-forms-prime-03.nix { inherit lib n; })."05-IsHappyNumber"'
	@echo "--- Evaluation Complete ---"

.PHONY: eval-31-mathematical-forms
eval-31-mathematical-forms:
	@echo "--- Evaluating theory/31-mathematical-forms.nix ---"
	@nix eval --impure --expr 'let lib = import <nixpkgs> {}.lib; in import ./theory/31-mathematical-forms.nix { inherit lib; }'
	@echo "--- Evaluation Complete ---"

.PHONY: eval-71-aspects-part-c
eval-71-aspects-part-c:
	@echo "--- Evaluating theory/71-aspects-part-c.nix ---"
	@nix eval --impure --expr 'let lib = import <nixpkgs> {}.lib; in import ./theory/71-aspects-part-c.nix { inherit lib; }'
	@echo "--- Evaluation Complete ---"

.PHONY: eval-github-graphql-get-repository-details
eval-github-graphql-get-repository-details:
	@echo "--- Evaluating github_graphql_modules/github_graphql_get_repository_details.nix ---"
	@nix eval --impure --expr 'let lib = import <nixpkgs> {}.lib; buildGraphQLQuery = {}; in import ./github_graphql_modules/github_graphql_get_repository_details.nix { inherit lib buildGraphQLQuery; }'
	@echo "--- Evaluation Complete ---"

.PHONY: eval-github-graphql-list-repository-issues
eval-github-graphql-list-repository-issues:
	@echo "--- Evaluating github_graphql_modules/github_graphql_list_repository_issues.nix ---"
	@nix eval --impure --expr 'let lib = import <nixpkgs> {}.lib; buildGraphQLQuery = {}; in import ./github_graphql_modules/github_graphql_list_repository_issues.nix { inherit lib buildGraphQLQuery; }'
	@echo "--- Evaluation Complete ---"

# Define PROJECT_ROOT relative to this Makefile's location
PROJECT_ROOT := $(shell pwd)

# Define SYNAPSE_SUBMODULE_PATH relative to PROJECT_ROOT
SYNAPSE_SUBMODULE_PATH := $(PROJECT_ROOT)/09/26/synapse-system

# Target to recover lost work in the synapse submodule
recover-synapse-work:
	@echo "[INFO] Attempting to recover lost work in the synapse submodule..."
	@echo "[INFO] Synapse Submodule Path: $(SYNAPSE_SUBMODULE_PATH)"
	@echo "[INFO] Reviewing Git history for potential lost commits in $(SYNAPSE_SUBMODULE_PATH)..."
	@echo "--------------------------------------------------------------------------------"
	@git -C $(SYNAPSE_SUBMODULE_PATH) log --oneline --graph --all --decorate
	@echo "--------------------------------------------------------------------------------"
	@echo "[INFO] To identify specific file changes, you can use 'git -C $(SYNAPSE_SUBMODULE_PATH) show <commit-hash>'."
	@echo "[INFO] Once filenames are identified, search telemetry logs for their content:"
	@echo "[INFO] Example: grep -F '<filename>' $(PROJECT_ROOT)/logs/telemetry.log"
	@echo "[INFO] Recovery process requires manual inspection of Git history and telemetry logs."

.PHONY: recover-synapse-work

.PHONY: setup-sops
setup-sops:
	@echo "--- Setting up SOPS for Secure Credential Handling ---"
	@echo "Step 1: Generate a GPG Key (if you don't have one)"
	@echo "  Run: gpg --full-generate-key"
	@echo "  Follow the prompts. Note down your GPG key ID (e.g., from 'gpg --list-secret-keys --keyid-format LONG')."
	@echo ""
	@echo "Step 2: Create a .sops.yaml Configuration File"
	@echo "  Create a file named .sops.yaml in the project root: $(PROJECT_ROOT)/.sops.yaml"
	@echo "  Add the following content, replacing YOUR_GPG_KEY_ID with your actual GPG key ID:"
	@echo ""
	@echo "    keys:"
	@echo "      - &main_key 0xYOUR_GPG_KEY_ID"
	@echo "    creation_rules:"
	@echo "      - path_regex: .*/sops-secrets/.*\\.json$$"
	@echo "        pgp: *main_key"
	@echo ""
	@echo "Step 3: Run the script to encrypt your Gemini CLI credentials"
	@echo "  This will read your ~/.gemini files, encrypt them, and generate secrets.nix."
	@echo "  Ensure you are in the directory where you want sops-secrets/ and secrets.nix to be created."
	@echo "  Running: $(PROJECT_ROOT)/scripts/create_gemini_sops_secrets.sh"
	@$(PROJECT_ROOT)/scripts/create_gemini_sops_secrets.sh
	@echo "--- SOPS Setup Complete (Manual GPG key creation/config required) ---"
