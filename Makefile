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

.PHONY: all pre-nix-check build-foaf-context install-hooks uninstall-pre-commit gc-pre-commit clean-pre-commit git-commit

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

.PHONY: debug-pkgs-writeShellScriptBin-type
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
	@echo "--- Debugging crq-document-check.nix evaluation ---"
	@nix eval --json --arg pkgs '${nixpkgs}' --argstr commitMsgFile "dummy_commit_msg.txt" --expr 'import ${./10/04/lib/crq-document-check.nix} { pkgs = import pkgs {}; commitMsgFile = commitMsgFile; }'
	@echo "--- Debugging crq-document-check.nix evaluation Complete ---"
