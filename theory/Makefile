include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./theory"))')/nix_eval_module.mk


include /nix_eval_module.mk


# Makefile for Leech Lattice (Λ₂₄) model

.PHONY: all leech-lattice-properties leech-lattice-dimensions leech-lattice-blade-17 monster-group-crqs unique-nix-terms build-mycology-workflow-puml pre-nix-check

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
	nix eval --impure --json --expr 'with import <nixpkgs> {}; let pipeline = import ./nix-indexer-pipeline.nix { inherit lib; }; in pipeline.uniqueTerms'
	@echo "--- Unique Nix Terms Displayed ---"

# Build the Hackathon Mycology Workflow C4-UML diagram.
build-mycology-workflow-puml: pre-nix-check
	@echo "--- Building Hackathon Mycology Workflow C4-UML Diagram ---"
	nix build --no-link --impure --expr 'with import <nixpkgs> {}; import ./generate_hackathon_uml.nix { inherit pkgs lib; umlData = import ./hackathon_uml_data.nix { inherit pkgs lib; formalTriad = import ./formal_triad_env.nix { inherit pkgs; }; }; }'
	@echo "--- Hackathon Mycology Workflow C4-UML Diagram Built ---"

all: leech-lattice-properties leech-lattice-dimensions leech-lattice-blade-17 monster-group-crqs unique-nix-terms build-mycology-workflow-puml

.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.


.PHONY: test-monster-group-71-vibe

test-monster-group-71-vibe: monster-group-71-vibe.nix
	@echo "--- Testing monster-group-71-vibe.nix with nix eval ---"
	@nix eval --raw ./monster-group-71-vibe.nix > monster-group-71-vibe.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for monster-group-71-vibe.nix. Check monster-group-71-vibe.eval.log for details."
		cat monster-group-71-vibe.eval.log; 		exit 1; 	}
	@echo "--- monster-group-71-vibe.nix test complete. Output in monster-group-71-vibe.eval.log ---"



.PHONY: test-71-aspects-part-a

test-71-aspects-part-a: 71-aspects-part-a.nix
	@echo "--- Testing 71-aspects-part-a.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-a.nix > 71-aspects-part-a.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-a.nix. Check 71-aspects-part-a.eval.log for details."
		cat 71-aspects-part-a.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-a.nix test complete. Output in 71-aspects-part-a.eval.log ---"



.PHONY: test-71-aspects-part-b

test-71-aspects-part-b: 71-aspects-part-b.nix
	@echo "--- Testing 71-aspects-part-b.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-b.nix > 71-aspects-part-b.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-b.nix. Check 71-aspects-part-b.eval.log for details."
		cat 71-aspects-part-b.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-b.nix test complete. Output in 71-aspects-part-b.eval.log ---"



.PHONY: test-71-aspects-part-c

test-71-aspects-part-c: 71-aspects-part-c.nix
	@echo "--- Testing 71-aspects-part-c.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-c.nix > 71-aspects-part-c.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-c.nix. Check 71-aspects-part-c.eval.log for details."
		cat 71-aspects-part-c.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-c.nix test complete. Output in 71-aspects-part-c.eval.log ---"



.PHONY: test-71-aspects-part-d

test-71-aspects-part-d: 71-aspects-part-d.nix
	@echo "--- Testing 71-aspects-part-d.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-d.nix > 71-aspects-part-d.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-d.nix. Check 71-aspects-part-d.eval.log for details."
		cat 71-aspects-part-d.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-d.nix test complete. Output in 71-aspects-part-d.eval.log ---"



.PHONY: test-71-aspects-part-e

test-71-aspects-part-e: 71-aspects-part-e.nix
	@echo "--- Testing 71-aspects-part-e.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-e.nix > 71-aspects-part-e.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-e.nix. Check 71-aspects-part-e.eval.log for details."
		cat 71-aspects-part-e.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-e.nix test complete. Output in 71-aspects-part-e.eval.log ---"



.PHONY: test-71-aspects-part-f

test-71-aspects-part-f: 71-aspects-part-f.nix
	@echo "--- Testing 71-aspects-part-f.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-f.nix > 71-aspects-part-f.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-f.nix. Check 71-aspects-part-f.eval.log for details."
		cat 71-aspects-part-f.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-f.nix test complete. Output in 71-aspects-part-f.eval.log ---"



.PHONY: test-71-aspects-part-g

test-71-aspects-part-g: 71-aspects-part-g.nix
	@echo "--- Testing 71-aspects-part-g.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-g.nix > 71-aspects-part-g.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-g.nix. Check 71-aspects-part-g.eval.log for details."
		cat 71-aspects-part-g.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-g.nix test complete. Output in 71-aspects-part-g.eval.log ---"



.PHONY: test-31-aspects-of-31

test-31-aspects-of-31: 31-aspects-of-31.nix
	@echo "--- Testing 31-aspects-of-31.nix with nix eval ---"
	@nix eval --raw ./31-aspects-of-31.nix > 31-aspects-of-31.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-aspects-of-31.nix. Check 31-aspects-of-31.eval.log for details."
		cat 31-aspects-of-31.eval.log; 		exit 1; 	}
	@echo "--- 31-aspects-of-31.nix test complete. Output in 31-aspects-of-31.eval.log ---"



.PHONY: test-31-mathematical-forms

test-31-mathematical-forms: 31-mathematical-forms.nix
	@echo "--- Testing 31-mathematical-forms.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms.nix > 31-mathematical-forms.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms.nix. Check 31-mathematical-forms.eval.log for details."
		cat 31-mathematical-forms.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms.nix test complete. Output in 31-mathematical-forms.eval.log ---"



.PHONY: test-leech-lattice-24d

test-leech-lattice-24d: leech-lattice-24d.nix
	@echo "--- Testing leech-lattice-24d.nix with nix eval ---"
	@nix eval --raw ./leech-lattice-24d.nix > leech-lattice-24d.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for leech-lattice-24d.nix. Check leech-lattice-24d.eval.log for details."
		cat leech-lattice-24d.eval.log; 		exit 1; 	}
	@echo "--- leech-lattice-24d.nix test complete. Output in leech-lattice-24d.eval.log ---"



.PHONY: test-leech-lattice-blade-instance

test-leech-lattice-blade-instance: leech-lattice-blade-instance.nix
	@echo "--- Testing leech-lattice-blade-instance.nix with nix eval ---"
	@nix eval --raw ./leech-lattice-blade-instance.nix > leech-lattice-blade-instance.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for leech-lattice-blade-instance.nix. Check leech-lattice-blade-instance.eval.log for details."
		cat leech-lattice-blade-instance.eval.log; 		exit 1; 	}
	@echo "--- leech-lattice-blade-instance.nix test complete. Output in leech-lattice-blade-instance.eval.log ---"



.PHONY: test-monster-group-crqs

test-monster-group-crqs: monster-group-crqs.nix
	@echo "--- Testing monster-group-crqs.nix with nix eval ---"
	@nix eval --raw ./monster-group-crqs.nix > monster-group-crqs.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for monster-group-crqs.nix. Check monster-group-crqs.eval.log for details."
		cat monster-group-crqs.eval.log; 		exit 1; 	}
	@echo "--- monster-group-crqs.nix test complete. Output in monster-group-crqs.eval.log ---"



.PHONY: test-nix-indexer-pipeline

test-nix-indexer-pipeline: nix-indexer-pipeline.nix
	@echo "--- Testing nix-indexer-pipeline.nix with nix eval ---"
	@nix eval --raw ./nix-indexer-pipeline.nix > nix-indexer-pipeline.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix-indexer-pipeline.nix. Check nix-indexer-pipeline.eval.log for details."
		cat nix-indexer-pipeline.eval.log; 		exit 1; 	}
	@echo "--- nix-indexer-pipeline.nix test complete. Output in nix-indexer-pipeline.eval.log ---"



.PHONY: test-monster_genome_data

test-monster_genome_data: monster_genome_data.nix
	@echo "--- Testing monster_genome_data.nix with nix eval ---"
	@nix eval --raw ./monster_genome_data.nix > monster_genome_data.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for monster_genome_data.nix. Check monster_genome_data.eval.log for details."
		cat monster_genome_data.eval.log; 		exit 1; 	}
	@echo "--- monster_genome_data.nix test complete. Output in monster_genome_data.eval.log ---"



.PHONY: test-formal_triad_env

test-formal_triad_env: formal_triad_env.nix
	@echo "--- Testing formal_triad_env.nix with nix eval ---"
	@nix eval --raw ./formal_triad_env.nix > formal_triad_env.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for formal_triad_env.nix. Check formal_triad_env.eval.log for details."
		cat formal_triad_env.eval.log; 		exit 1; 	}
	@echo "--- formal_triad_env.nix test complete. Output in formal_triad_env.eval.log ---"



.PHONY: test-hackathon_uml_data

test-hackathon_uml_data: hackathon_uml_data.nix
	@echo "--- Testing hackathon_uml_data.nix with nix eval ---"
	@nix eval --raw ./hackathon_uml_data.nix > hackathon_uml_data.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for hackathon_uml_data.nix. Check hackathon_uml_data.eval.log for details."
		cat hackathon_uml_data.eval.log; 		exit 1; 	}
	@echo "--- hackathon_uml_data.nix test complete. Output in hackathon_uml_data.eval.log ---"



.PHONY: test-generate_hackathon_uml

test-generate_hackathon_uml: generate_hackathon_uml.nix
	@echo "--- Testing generate_hackathon_uml.nix with nix eval ---"
	@nix eval --raw ./generate_hackathon_uml.nix > generate_hackathon_uml.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for generate_hackathon_uml.nix. Check generate_hackathon_uml.eval.log for details."
		cat generate_hackathon_uml.eval.log; 		exit 1; 	}
	@echo "--- generate_hackathon_uml.nix test complete. Output in generate_hackathon_uml.eval.log ---"



.PHONY: test-71-aspects-part-c-error-fix-01

test-71-aspects-part-c-error-fix-01: 71-aspects-part-c-error-fix-01.nix
	@echo "--- Testing 71-aspects-part-c-error-fix-01.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-c-error-fix-01.nix > 71-aspects-part-c-error-fix-01.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-c-error-fix-01.nix. Check 71-aspects-part-c-error-fix-01.eval.log for details."
		cat 71-aspects-part-c-error-fix-01.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-c-error-fix-01.nix test complete. Output in 71-aspects-part-c-error-fix-01.eval.log ---"



.PHONY: test-31-mathematical-forms-cube-number-check-fix

test-31-mathematical-forms-cube-number-check-fix: 31-mathematical-forms-cube-number-check-fix.nix
	@echo "--- Testing 31-mathematical-forms-cube-number-check-fix.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms-cube-number-check-fix.nix > 31-mathematical-forms-cube-number-check-fix.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms-cube-number-check-fix.nix. Check 31-mathematical-forms-cube-number-check-fix.eval.log for details."
		cat 31-mathematical-forms-cube-number-check-fix.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms-cube-number-check-fix.nix test complete. Output in 31-mathematical-forms-cube-number-check-fix.eval.log ---"



.PHONY: test-71-aspects-part-c-aspect-29-otel-event-trace

test-71-aspects-part-c-aspect-29-otel-event-trace: 71-aspects-part-c-aspect-29-otel-event-trace.nix
	@echo "--- Testing 71-aspects-part-c-aspect-29-otel-event-trace.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-c-aspect-29-otel-event-trace.nix > 71-aspects-part-c-aspect-29-otel-event-trace.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-c-aspect-29-otel-event-trace.nix. Check 71-aspects-part-c-aspect-29-otel-event-trace.eval.log for details."
		cat 71-aspects-part-c-aspect-29-otel-event-trace.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-c-aspect-29-otel-event-trace.nix test complete. Output in 71-aspects-part-c-aspect-29-otel-event-trace.eval.log ---"



.PHONY: test-71-aspects-part-c-list-test-single-element

test-71-aspects-part-c-list-test-single-element: 71-aspects-part-c-list-test-single-element.nix
	@echo "--- Testing 71-aspects-part-c-list-test-single-element.nix with nix eval ---"
	@nix eval --raw ./71-aspects-part-c-list-test-single-element.nix > 71-aspects-part-c-list-test-single-element.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 71-aspects-part-c-list-test-single-element.nix. Check 71-aspects-part-c-list-test-single-element.eval.log for details."
		cat 71-aspects-part-c-list-test-single-element.eval.log; 		exit 1; 	}
	@echo "--- 71-aspects-part-c-list-test-single-element.nix test complete. Output in 71-aspects-part-c-list-test-single-element.eval.log ---"



.PHONY: test-31-mathematical-forms-prime-02

test-31-mathematical-forms-prime-02: 31-mathematical-forms-prime-02.nix
	@echo "--- Testing 31-mathematical-forms-prime-02.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms-prime-02.nix > 31-mathematical-forms-prime-02.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms-prime-02.nix. Check 31-mathematical-forms-prime-02.eval.log for details."
		cat 31-mathematical-forms-prime-02.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms-prime-02.nix test complete. Output in 31-mathematical-forms-prime-02.eval.log ---"



.PHONY: test-31-mathematical-forms-prime-03

test-31-mathematical-forms-prime-03: 31-mathematical-forms-prime-03.nix
	@echo "--- Testing 31-mathematical-forms-prime-03.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms-prime-03.nix > 31-mathematical-forms-prime-03.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms-prime-03.nix. Check 31-mathematical-forms-prime-03.eval.log for details."
		cat 31-mathematical-forms-prime-03.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms-prime-03.nix test complete. Output in 31-mathematical-forms-prime-03.eval.log ---"



.PHONY: test-31-mathematical-forms-prime-05

test-31-mathematical-forms-prime-05: 31-mathematical-forms-prime-05.nix
	@echo "--- Testing 31-mathematical-forms-prime-05.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms-prime-05.nix > 31-mathematical-forms-prime-05.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms-prime-05.nix. Check 31-mathematical-forms-prime-05.eval.log for details."
		cat 31-mathematical-forms-prime-05.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms-prime-05.nix test complete. Output in 31-mathematical-forms-prime-05.eval.log ---"



.PHONY: test-31-mathematical-forms-prime-07

test-31-mathematical-forms-prime-07: 31-mathematical-forms-prime-07.nix
	@echo "--- Testing 31-mathematical-forms-prime-07.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms-prime-07.nix > 31-mathematical-forms-prime-07.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms-prime-07.nix. Check 31-mathematical-forms-prime-07.eval.log for details."
		cat 31-mathematical-forms-prime-07.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms-prime-07.nix test complete. Output in 31-mathematical-forms-prime-07.eval.log ---"



.PHONY: test-31-mathematical-forms-prime-11

test-31-mathematical-forms-prime-11: 31-mathematical-forms-prime-11.nix
	@echo "--- Testing 31-mathematical-forms-prime-11.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms-prime-11.nix > 31-mathematical-forms-prime-11.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms-prime-11.nix. Check 31-mathematical-forms-prime-11.eval.log for details."
		cat 31-mathematical-forms-prime-11.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms-prime-11.nix test complete. Output in 31-mathematical-forms-prime-11.eval.log ---"



.PHONY: test-31-mathematical-forms-prime-13

test-31-mathematical-forms-prime-13: 31-mathematical-forms-prime-13.nix
	@echo "--- Testing 31-mathematical-forms-prime-13.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms-prime-13.nix > 31-mathematical-forms-prime-13.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms-prime-13.nix. Check 31-mathematical-forms-prime-13.eval.log for details."
		cat 31-mathematical-forms-prime-13.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms-prime-13.nix test complete. Output in 31-mathematical-forms-prime-13.eval.log ---"



.PHONY: test-31-mathematical-forms-prime-17

test-31-mathematical-forms-prime-17: 31-mathematical-forms-prime-17.nix
	@echo "--- Testing 31-mathematical-forms-prime-17.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms-prime-17.nix > 31-mathematical-forms-prime-17.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms-prime-17.nix. Check 31-mathematical-forms-prime-17.eval.log for details."
		cat 31-mathematical-forms-prime-17.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms-prime-17.nix test complete. Output in 31-mathematical-forms-prime-17.eval.log ---"



.PHONY: test-31-mathematical-forms-prime-19

test-31-mathematical-forms-prime-19: 31-mathematical-forms-prime-19.nix
	@echo "--- Testing 31-mathematical-forms-prime-19.nix with nix eval ---"
	@nix eval --raw ./31-mathematical-forms-prime-19.nix > 31-mathematical-forms-prime-19.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-mathematical-forms-prime-19.nix. Check 31-mathematical-forms-prime-19.eval.log for details."
		cat 31-mathematical-forms-prime-19.eval.log; 		exit 1; 	}
	@echo "--- 31-mathematical-forms-prime-19.nix test complete. Output in 31-mathematical-forms-prime-19.eval.log ---"


