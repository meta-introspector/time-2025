.PHONY: all build-mycology-workflow build-data-sources

all: build-mycology-workflow build-data-sources

# Target to build the mycology-workflow flake.
build-mycology-workflow:
	@echo "--- Building Mycology Workflow Flake (from flakes/Makefile) ---"
	@nix build .#mycology-workflow --extra-experimental-features "nix-command flakes impure-derivations ca-derivations"
	@echo "--- Mycology Workflow Flake Built (from flakes/Makefile) ---"

# Target to build the data-sources flake.
build-data-sources:
	@echo "--- Building Data Sources Flake (from flakes/Makefile) ---"
	@nix build .#data-sources --extra-experimental-features "nix-command flakes impure-derivations ca-derivations"
	@echo "--- Data Sources Flake Built (from flakes/Makefile) ---"