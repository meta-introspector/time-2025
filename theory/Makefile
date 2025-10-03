# Makefile for Leech Lattice (Λ₂₄) model

.PHONY: all leech-lattice-properties leech-lattice-dimensions leech-lattice-blade-17 monster-group-crqs unique-nix-terms pre-nix-check

# Ensure no unstaged or uncommitted Nix files before running Nix commands.
# This helps maintain purity and prevents accidental builds from dirty working directories.
pre-nix-check:
	@echo "--- Running pre-Nix check: Ensuring no unstaged or uncommitted Nix files ---"
	@if git status --porcelain -- '*.nix' | grep -q .; then \
		echo "ERROR: Unstaged or uncommitted Nix files found. Please commit or stash them before proceeding."; \
		exit 1; \
	fi
	@echo "--- Pre-Nix check passed. No unstaged or uncommitted Nix files found. ---"

# Display all properties of the Leech lattice.
leech-lattice-properties: pre-nix-check
	@echo "--- Displaying Leech Lattice Properties ---"
	nix eval --impure --json --expr 'with import <nixpkgs> {}; import ./leech-lattice-24d.nix { inherit lib; }'
	@echo "--- Leech Lattice Properties Displayed ---"

# Display the 24 dimensions/blades of the Leech lattice.
leech-lattice-dimensions: pre-nix-check
	@echo "--- Displaying Leech Lattice Dimensions ---"
	nix eval --impure --raw --expr 'with import <nixpkgs> {}; let leech = import ./leech-lattice-24d.nix { inherit lib; }; in builtins.toJSON leech.dimensionsList'
	@echo "--- Leech Lattice Dimensions Displayed ---"

# Display the properties of the 17th blade (d17).
leech-lattice-blade-17: pre-nix-check
	@echo "--- Displaying Leech Lattice Blade 17 ---"
	nix eval --impure --json --expr 'with import <nixpkgs> {}; import ./leech-lattice-blade-instance.nix { inherit lib; }'
	@echo "--- Leech Lattice Blade 17 Displayed ---"

# Display the Monster Group related CRQs.
monster-group-crqs: pre-nix-check
	@echo "--- Displaying Monster Group CRQs ---"
	nix eval --impure --json --expr 'with import <nixpkgs> {}; import ./monster-group-crqs.nix { inherit lib; }'
	@echo "--- Monster Group CRQs Displayed ---"

# Display the unique terms extracted from Nix paths and metadata.
unique-nix-terms: pre-nix-check
	@echo "--- Displaying Unique Nix Terms ---"
	nix eval --impure --json --expr 'with import <nixpkgs> {}; import ./nix-indexer-pipeline.nix { inherit lib; } .uniqueTerms'
	@echo "--- Unique Nix Terms Displayed ---"

all: leech-lattice-properties leech-lattice-dimensions leech-lattice-blade-17 monster-group-crqs unique-nix-terms
