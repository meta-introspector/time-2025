# nix_eval_module.mk
# A generic Makefile module for evaluating, checking, developing, and building Nix files.

.PHONY: nix-eval-file nix-check-file nix-develop-file nix-build-file

# Function to evaluate a Nix file.
# Usage: $(call nix-eval-file, <NIX_FILE_PATH>)
define nix-eval-file
$(eval NIX_FILE_TO_EVAL := $(1))
$(eval NIX_FILE_BASENAME := $(notdir $(NIX_FILE_TO_EVAL)))
$(eval NIX_FILE_NAME_WITHOUT_EXT := $(basename $(NIX_FILE_BASENAME)))

nix-eval-file-$(NIX_FILE_NAME_WITHOUT_EXT):
	@echo "--- Evaluating $(NIX_FILE_TO_EVAL) with nix-instantiate --eval --json --strict --read-write-mode --expr 'import $(NIX_FILE_TO_EVAL)' --"
	nix-instantiate --eval --json --strict --read-write-mode --expr 'import $(NIX_FILE_TO_EVAL)' > $(NIX_FILE_NAME_WITHOUT_EXT).eval.log 2>&1 || { \
		echo "ERROR: nix-instantiate --eval failed for $(NIX_FILE_TO_EVAL). Check $(NIX_FILE_NAME_WITHOUT_EXT).eval.log for details."; \
		cat $(NIX_FILE_NAME_WITHOUT_EXT).eval.log; \
		exit 1; \
	}
	@echo "--- $(NIX_FILE_TO_EVAL) evaluation complete. Output in $(NIX_FILE_NAME_WITHOUT_EXT).eval.log ---"

endef

# Function to check a Nix file with statix and optionally nix flake check.
# Usage: $(call nix-check-file, <NIX_FILE_PATH>)
define nix-check-file
$(eval NIX_FILE_TO_CHECK := $(1))
$(eval NIX_FILE_BASENAME := $(notdir $(NIX_FILE_TO_CHECK)))
$(eval NIX_FILE_NAME_WITHOUT_EXT := $(basename $(NIX_FILE_BASENAME)))
$(eval NIX_FILE_DIR := $(dir $(NIX_FILE_TO_CHECK)))

nix-check-file-$(NIX_FILE_NAME_WITHOUT_EXT):
	@echo "--- Running statix check on $(NIX_FILE_TO_CHECK) ---"
	@nix develop --command bash -c "statix check $(NIX_FILE_TO_CHECK)" > $(NIX_FILE_NAME_WITHOUT_EXT).statix.log 2>&1 || { \
		echo "ERROR: statix check failed for $(NIX_FILE_TO_CHECK). Check $(NIX_FILE_NAME_WITHOUT_EXT).statix.log for details."; \
		cat $(NIX_FILE_NAME_WITHOUT_EXT).statix.log; \
		exit 1; \
	}
	@echo "--- statix check for $(NIX_FILE_TO_CHECK) complete. Output in $(NIX_FILE_NAME_WITHOUT_EXT).statix.log ---"

ifeq ($(NIX_FILE_BASENAME),flake.nix)
	@echo "--- Running nix flake check on $(NIX_FILE_TO_CHECK) ---"
	@(cd $(NIX_FILE_DIR) && nix flake check) > $(NIX_FILE_NAME_WITHOUT_EXT).flake-check.log 2>&1 || { \
		echo "ERROR: nix flake check failed for $(NIX_FILE_TO_CHECK). Check $(NIX_FILE_NAME_WITHOUT_EXT).flake-check.log for details."; \
		cat $(NIX_FILE_NAME_WITHOUT_EXT).flake-check.log; \
		exit 1; \
	}
	@echo "--- nix flake check for $(NIX_FILE_TO_CHECK) complete. Output in $(NIX_FILE_NAME_WITHOUT_EXT).flake-check.log ---"
endif

endef

# Function to enter a Nix development shell for a Nix file.
# Usage: $(call nix-develop-file, <NIX_FILE_PATH>)
define nix-develop-file
$(eval NIX_FILE_TO_DEVELOP := $(1))
$(eval NIX_FILE_BASENAME := $(notdir $(NIX_FILE_TO_DEVELOP)))
$(eval NIX_FILE_NAME_WITHOUT_EXT := $(basename $(NIX_FILE_BASENAME)))
$(eval NIX_FILE_DIR := $(dir $(NIX_FILE_TO_DEVELOP)))

nix-develop-file-$(NIX_FILE_NAME_WITHOUT_EXT):
	@echo "--- Entering Nix develop shell for $(NIX_FILE_TO_DEVELOP) ---"
	@(cd $(NIX_FILE_DIR) && nix develop --command bash)
	@echo "--- Exited Nix develop shell for $(NIX_FILE_TO_DEVELOP) ---"

endef

# Function to build a Nix file.
# Usage: $(call nix-build-file, <NIX_FILE_PATH>)
define nix-build-file
$(eval NIX_FILE_TO_BUILD := $(1))
$(eval NIX_FILE_BASENAME := $(notdir $(NIX_FILE_TO_BUILD)))
$(eval NIX_FILE_NAME_WITHOUT_EXT := $(basename $(NIX_FILE_BASENAME)))
$(eval NIX_FILE_DIR := $(dir $(NIX_FILE_TO_BUILD)))

nix-build-file-$(NIX_FILE_NAME_WITHOUT_EXT):
	@echo "--- Building $(NIX_FILE_TO_BUILD) with nix build ---"
	@(cd $(NIX_FILE_DIR) && nix build .#$(NIX_FILE_NAME_WITHOUT_EXT)) > $(NIX_FILE_NAME_WITHOUT_EXT).build.log 2>&1 || { \
		echo "ERROR: nix build failed for $(NIX_FILE_TO_BUILD). Check $(NIX_FILE_NAME_WITHOUT_EXT).build.log for details."; \
		cat $(NIX_FILE_NAME_WITHOUT_EXT).build.log; \
		exit 1; \
	}
	@echo "--- $(NIX_FILE_TO_BUILD) build complete. Output in $(NIX_FILE_NAME_WITHOUT_EXT).build.log ---"

endef
