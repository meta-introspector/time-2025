include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./dummy_project"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-test

test-test: test.nix
	@echo "--- Testing test.nix with nix eval ---"
	@nix eval --raw ./test.nix > test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test.nix. Check test.eval.log for details."
		cat test.eval.log; 		exit 1; 	}
	@echo "--- test.nix test complete. Output in test.eval.log ---"


