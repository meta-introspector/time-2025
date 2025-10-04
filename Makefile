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

.PHONY: all pre-nix-check build-foaf-context install-hooks git-commit

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
