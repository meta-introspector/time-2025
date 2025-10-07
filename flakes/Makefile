.PHONY: all build-mycology-workflow build-data-sources eval-mycology-workflow

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

# Target to evaluate the mycology-workflow flake.
# This checks for syntax errors and argument issues without performing a full build.
# It uses --impure because the flake imports local files.
.PHONY: eval-mycology-workflow
eval-mycology-workflow:
	@echo "--- Evaluating Mycology Workflow Flake ---"
	@nix eval .#mycologyWorkflowPuml --extra-experimental-features "nix-command flakes" --impure
	@echo "--- Mycology Workflow Flake Evaluation Complete ---"