# Function to analyze derivations of a Nix file (flake)
# Usage: $(call nix-derivation-analyze-file, <NIX_FILE_PATH>)
define nix-derivation-analyze-file
$(eval NIX_FILE_TO_ANALYZE := $(1))
$(eval NIX_FILE_BASENAME := $(notdir $(NIX_FILE_TO_ANALYZE)))
$(eval NIX_FILE_NAME_WITHOUT_EXT := $(basename $(NIX_FILE_BASENAME)))
$(eval NIX_FILE_DIR := $(dir $(NIX_FILE_TO_ANALYZE)))

nix-derivation-analyze-file-$(NIX_FILE_NAME_WITHOUT_EXT):
	@echo "--- Analyzing derivations for $(NIX_FILE_TO_ANALYZE) ---"
	@if [ "$(NIX_FILE_BASENAME)" = "flake.nix" ]; then \
		FLAKE_DIR="$(NIX_FILE_DIR)"; \
		REPORT_FILE="$(FLAKE_DIR)/$(NIX_FILE_NAME_WITHOUT_EXT).derivation_report.json"; \
		DERIVATION_PATHS=(); \
		NIX_FLAKE_SHOW_OUTPUT=$$(nix flake show --json "$$FLAKE_DIR" 2>/dev/null || true); \
		if [ -n "$$NIX_FLAKE_SHOW_OUTPUT" ]; then \
			mapfile -t PKG_DRV_PATHS < <(echo "$$NIX_FLAKE_SHOW_OUTPUT" | jq -r '.packages."x86_64-linux" | to_entries[] | .value.drvPath // empty' 2>/dev/null || true); \
			DERIVATION_PATHS+=("$$PKG_DRV_PATHS"); \
			mapfile -t SHELL_DRV_PATHS < <(echo "$$NIX_FLAKE_SHOW_OUTPUT" | jq -r '.devShells."x86_64-linux" | to_entries[] | .value.drvPath // empty' 2>/dev/null || true); \
			DERIVATION_PATHS+=("$$SHELL_DRV_PATHS"); \
		fi; \
		if [ $${#DERIVATION_PATHS[@]} -eq 0 ]; then \
			echo "No derivations found for flake: $$FLAKE_DIR"; \
		else \
			CURRENT_FLAKE_DERIVATION_RESULTS=(); \
			for drv_path in "$${DERIVATION_PATHS[@]}"; do \
				DRV_SHOW_RESULT=$$(nix derivation show "$$drv_path" 2>/dev/null || true); \
				CURRENT_FLAKE_DERIVATION_RESULTS+=("$$DRV_SHOW_RESULT"); \
			done; \
							jq -n \
								--arg flake_path "$$FLAKE_DIR" \
								--arg timestamp "$$(date -Iseconds)" \
								--argjson results "$$(printf '%s\n' "$${CURRENT_FLAKE_DERIVATION_RESULTS[@]}" | jq -s .)" \
								'{ "flake_path": $$flake_path, "timestamp": $$timestamp, "derivation_results": $$results }' > "$$REPORT_FILE"; \
						NUM_DERIVATIONS=$$(jq '.derivation_results | length' "$$REPORT_FILE"); \
						echo "Generated derivation report for $$FLAKE_DIR: $$REPORT_FILE ($$NUM_DERIVATIONS derivations found)."; \		fi; \
	else \
		echo "Skipping derivation analysis for non-flake file: $(NIX_FILE_TO_ANALYZE)"; \
	fi
	@echo "--- Derivation analysis for $(NIX_FILE_TO_ANALYZE) complete ---"

endef

# New PHONY target for running derivation analysis on all flakes in the current directory
.PHONY: analyze-derivations
analyze-derivations:
	@echo "--- Running derivation analysis for all flakes in $(CURDIR) ---"
	$(foreach nix_file,$(wildcard *.nix),$(if $(filter flake.nix,$(notdir $(nix_file))),$(call nix-derivation-analyze-file,$(nix_file))))
	@echo "--- All derivation analyses complete ---"
