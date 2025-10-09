# Makefile for colosseum-mirror flake

.PHONY: build clean shell archive-daily

# Build the colosseum-mirror package
build:
	nix build .#colosseum-mirror

# Clean up build artifacts
clean:
	nix store gc

# Enter the development shell
shell:
	nix develop

# Archive the Colosseum website daily
# This target will build the flake, which in turn fetches the website.
# In a more advanced scenario, this could use httrack or other mirroring tools.
archive-daily:
	nix build .#colosseum-mirror
	@echo "Colosseum website archived. The output path contains index.html."