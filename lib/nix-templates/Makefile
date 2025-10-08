include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./lib/nix-templates"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-safe-eval

test-safe-eval: safe-eval.nix
	@echo "--- Testing safe-eval.nix with nix eval ---"
	@nix eval --raw ./safe-eval.nix > safe-eval.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for safe-eval.nix. Check safe-eval.eval.log for details."
		cat safe-eval.eval.log; 		exit 1; 	}
	@echo "--- safe-eval.nix test complete. Output in safe-eval.eval.log ---"



.PHONY: test-error-constructors

test-error-constructors: error-constructors.nix
	@echo "--- Testing error-constructors.nix with nix eval ---"
	@nix eval --raw ./error-constructors.nix > error-constructors.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for error-constructors.nix. Check error-constructors.eval.log for details."
		cat error-constructors.eval.log; 		exit 1; 	}
	@echo "--- error-constructors.nix test complete. Output in error-constructors.eval.log ---"



.PHONY: test-fold-accumulator

test-fold-accumulator: fold-accumulator.nix
	@echo "--- Testing fold-accumulator.nix with nix eval ---"
	@nix eval --raw ./fold-accumulator.nix > fold-accumulator.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for fold-accumulator.nix. Check fold-accumulator.eval.log for details."
		cat fold-accumulator.eval.log; 		exit 1; 	}
	@echo "--- fold-accumulator.nix test complete. Output in fold-accumulator.eval.log ---"



.PHONY: test-recursive-scanner

test-recursive-scanner: recursive-scanner.nix
	@echo "--- Testing recursive-scanner.nix with nix eval ---"
	@nix eval --raw ./recursive-scanner.nix > recursive-scanner.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for recursive-scanner.nix. Check recursive-scanner.eval.log for details."
		cat recursive-scanner.eval.log; 		exit 1; 	}
	@echo "--- recursive-scanner.nix test complete. Output in recursive-scanner.eval.log ---"


