include ../../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/08/hackathon/flakes/consolidated-impure-gemini-telemetry-modules"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 19214(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 19214(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 19214(pwd). Check develop.log for details."; 		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 19214(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.


.PHONY: test-apps-default

test-apps-default: apps-default.nix
	@echo "--- Testing apps-default.nix with nix eval ---"
	@nix eval --raw ./apps-default.nix > apps-default.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for apps-default.nix. Check apps-default.eval.log for details."
		cat apps-default.eval.log; 		exit 1; 	}
	@echo "--- apps-default.nix test complete. Output in apps-default.eval.log ---"



.PHONY: test-flake

test-flake: flake.nix
	@echo "--- Testing flake.nix with nix eval ---"
	@nix eval --raw ./flake.nix > flake.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for flake.nix. Check flake.eval.log for details."
		cat flake.eval.log; 		exit 1; 	}
	@echo "--- flake.nix test complete. Output in flake.eval.log ---"



.PHONY: test-impure-gemini-telemetry-derivation

test-impure-gemini-telemetry-derivation: impure-gemini-telemetry-derivation.nix
	@echo "--- Testing impure-gemini-telemetry-derivation.nix with nix eval ---"
	@nix eval --raw ./impure-gemini-telemetry-derivation.nix > impure-gemini-telemetry-derivation.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for impure-gemini-telemetry-derivation.nix. Check impure-gemini-telemetry-derivation.eval.log for details."
		cat impure-gemini-telemetry-derivation.eval.log; 		exit 1; 	}
	@echo "--- impure-gemini-telemetry-derivation.nix test complete. Output in impure-gemini-telemetry-derivation.eval.log ---"



.PHONY: test-inputs

test-inputs: inputs.nix
	@echo "--- Testing inputs.nix with nix eval ---"
	@nix eval --raw ./inputs.nix > inputs.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for inputs.nix. Check inputs.eval.log for details."
		cat inputs.eval.log; 		exit 1; 	}
	@echo "--- inputs.nix test complete. Output in inputs.eval.log ---"



.PHONY: test-lib-run-telemetry

test-lib-run-telemetry: lib-run-telemetry.nix
	@echo "--- Testing lib-run-telemetry.nix with nix eval ---"
	@nix eval --raw ./lib-run-telemetry.nix > lib-run-telemetry.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for lib-run-telemetry.nix. Check lib-run-telemetry.eval.log for details."
		cat lib-run-telemetry.eval.log; 		exit 1; 	}
	@echo "--- lib-run-telemetry.nix test complete. Output in lib-run-telemetry.eval.log ---"



.PHONY: test-outputs-header

test-outputs-header: outputs-header.nix
	@echo "--- Testing outputs-header.nix with nix eval ---"
	@nix eval --raw ./outputs-header.nix > outputs-header.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for outputs-header.nix. Check outputs-header.eval.log for details."
		cat outputs-header.eval.log; 		exit 1; 	}
	@echo "--- outputs-header.nix test complete. Output in outputs-header.eval.log ---"



.PHONY: test-packages-default

test-packages-default: packages-default.nix
	@echo "--- Testing packages-default.nix with nix eval ---"
	@nix eval --raw ./packages-default.nix > packages-default.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for packages-default.nix. Check packages-default.eval.log for details."
		cat packages-default.eval.log; 		exit 1; 	}
	@echo "--- packages-default.nix test complete. Output in packages-default.eval.log ---"


