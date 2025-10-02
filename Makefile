NIX_FLAGS = --extra-experimental-features "impure-derivations ca-derivations"

.PHONY: build-step1-index clean-step1-index

build-step1-index:
	@echo "Instantiating Step 1 derivation..."
	@DRV_PATH=$$(nix-instantiate temp_step1_eval.nix $(NIX_FLAGS))
	@echo "Derivation path: $$DRV_PATH"
	@echo "Realizing Step 1 derivation..."
	@RESULT_PATH=$$(nix-store --realise $$DRV_PATH $(NIX_FLAGS))
	@echo "Output path: $$RESULT_PATH"
	@echo $$RESULT_PATH > .step1.outpath

clean-step1-index:
	@rm -f .step1.outpath
