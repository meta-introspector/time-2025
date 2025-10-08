include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./lib/generate-project-nix"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-evaluateNixFile

test-evaluateNixFile: evaluateNixFile.nix
	@echo "--- Testing evaluateNixFile.nix with nix eval ---"
	@nix eval --raw ./evaluateNixFile.nix > evaluateNixFile.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for evaluateNixFile.nix. Check evaluateNixFile.eval.log for details."
		cat evaluateNixFile.eval.log; 		exit 1; 	}
	@echo "--- evaluateNixFile.nix test complete. Output in evaluateNixFile.eval.log ---"



.PHONY: test-generate

test-generate: generate.nix
	@echo "--- Testing generate.nix with nix eval ---"
	@nix eval --raw ./generate.nix > generate.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for generate.nix. Check generate.eval.log for details."
		cat generate.eval.log; 		exit 1; 	}
	@echo "--- generate.nix test complete. Output in generate.eval.log ---"



.PHONY: test-processEntry

test-processEntry: processEntry.nix
	@echo "--- Testing processEntry.nix with nix eval ---"
	@nix eval --raw ./processEntry.nix > processEntry.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for processEntry.nix. Check processEntry.eval.log for details."
		cat processEntry.eval.log; 		exit 1; 	}
	@echo "--- processEntry.nix test complete. Output in processEntry.eval.log ---"



.PHONY: test-tryEval

test-tryEval: tryEval.nix
	@echo "--- Testing tryEval.nix with nix eval ---"
	@nix eval --raw ./tryEval.nix > tryEval.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for tryEval.nix. Check tryEval.eval.log for details."
		cat tryEval.eval.log; 		exit 1; 	}
	@echo "--- tryEval.nix test complete. Output in tryEval.eval.log ---"


