include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./flakes/gemini-feature-lattice"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-credential-setup

test-credential-setup: credential-setup.nix
	@echo "--- Testing credential-setup.nix with nix eval ---"
	@nix eval --raw ./credential-setup.nix > credential-setup.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for credential-setup.nix. Check credential-setup.eval.log for details."
		cat credential-setup.eval.log; 		exit 1; 	}
	@echo "--- credential-setup.nix test complete. Output in credential-setup.eval.log ---"


