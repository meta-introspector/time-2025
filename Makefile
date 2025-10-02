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

# Debugging the Aggregator Flake (TikTok Short: Isolating Flake Errors)
# This target directly evaluates the aggregator flake to pinpoint syntax issues.
# It bypasses the root flake to ensure the error is within the aggregator itself.
debug-aggregator-flake: pre-nix-check
	@echo "--- Debugging Aggregator Flake Directly ---"
	nix eval --json ./flakes/foaf/aggregator#foo
	@echo "--- Aggregator Flake Debug Complete ---"

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
