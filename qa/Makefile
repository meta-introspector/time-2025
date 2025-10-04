# Makefile for the Pure Nix Quality System

# This Makefile provides a user-friendly interface for the development workflow:
# nix develop -> make -> nix -> shell

.PHONY: all add-new-files gen-uncommitted check-uncommitted gen-project-nix check-nix

# Default target: run the full QA process for uncommitted files
all: gen-uncommitted add-new-files gen-project-nix check-uncommitted check-nix

# Target to add all new and generated files to the git index
add-new-files:
	@echo "Adding new files to the git index..."
	git add qa.nix docs/GLOSSARY.md docs/crqs/CRQ_017_Topological_Graph_Explanation.md docs/crqs/CRQ_023_Pure_Nix_Quality_System.md docs/crqs/CRQ_072_Pure_Nix_Quality_System_Conceptual_Flake.md docs/crqs/CRQ_073_Debugging_Project_Nix_Generation.md docs/crqs/CRQ_074_Nix_Twin_Indexing_and_Integration.md scripts/generate-uncommitted-nix.sh scripts/generate-project-nix.sh project.nix
	git add docs/memes/10/03/uncommitted.nix scripts/uncommitted.nix test-commit-check/uncommitted.nix 09/26/jobs/vendor/uncommitted.nix docs/qa/uncommitted.nix 10/03/uncommitted.nix uncommitted.nix 10/03/colosseum-mirror/uncommitted.nix 09/26/uncommitted.nix docs/uncommitted.nix scripts/test-commit-checker/uncommitted.nix 09/uncommitted.nix docs/crqs/uncommitted.nix

# Target to generate the uncommitted.nix files
gen-uncommitted:
	@echo "Generating uncommitted.nix files..."
	./scripts/generate-uncommitted-nix.sh

# Target to generate the project.nix file
gen-project-nix:
	@echo "Generating project.nix file..."
	./scripts/generate-project-nix.sh

# Target to run the QA check for uncommitted files
check-uncommitted:
	@echo "Running QA check for uncommitted files..."
	nix build .#checks.aarch64-linux.check-uncommitted-files

# Target to run the QA check for all Nix files
check-nix:
	@echo "Running QA check for all Nix files..."
	nix build .#checks.aarch64-linux.check-all-nix-files