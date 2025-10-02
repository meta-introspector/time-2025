NIX_FLAGS = --extra-experimental-features "impure-derivations ca-derivations"

.PHONY: build-step1-index clean-step1-index build-step2-index clean-step2-index reproduce-bug build-hello-world

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

build-step2-index:
	@echo "Instantiating Step 2 derivation..."
	@DRV_PATH=$$(nix-instantiate temp_step2_eval.nix $(NIX_FLAGS))
	@echo "Derivation path: $$DRV_PATH"
	@echo "Realizing Step 2 derivation..."
	@RESULT_PATH=$$(nix-store --realise $$DRV_PATH $(NIX_FLAGS))
	@echo "Output path: $$RESULT_PATH"
	@echo $$RESULT_PATH > .step2.outpath

clean-step2-index:
	@rm -f .step2.outpath

reproduce-bug:
	@echo "Attempting to reproduce nix-build assertion failure. Strace logs will be in bug_repro_strace.log"
	-strace -o bug_repro_strace.log nix-build bug_repro.nix $(NIX_FLAGS) > bug_repro_output.txt 2>&1
	@echo "Bug reproduction attempt complete. Check bug_repro_output.txt and bug_repro_strace.log for details."

build-hello-world:
	nix-build hello_world.nix $(NIX_FLAGS)
