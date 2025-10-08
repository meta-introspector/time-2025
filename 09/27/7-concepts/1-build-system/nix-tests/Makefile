include ../../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/27/7-concepts/1-build-system/nix-tests"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-default

test-default: default.nix
	@echo "--- Testing default.nix with nix eval ---"
	@nix eval --raw ./default.nix > default.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for default.nix. Check default.eval.log for details."
		cat default.eval.log; 		exit 1; 	}
	@echo "--- default.nix test complete. Output in default.eval.log ---"



.PHONY: test-default-test

test-default-test: default-test.nix
	@echo "--- Testing default-test.nix with nix eval ---"
	@nix eval --raw ./default-test.nix > default-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for default-test.nix. Check default-test.eval.log for details."
		cat default-test.eval.log; 		exit 1; 	}
	@echo "--- default-test.nix test complete. Output in default-test.eval.log ---"


