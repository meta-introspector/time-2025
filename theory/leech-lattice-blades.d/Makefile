include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./theory/leech-lattice-blades.d"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-d17

test-d17: d17.nix
	@echo "--- Testing d17.nix with nix eval ---"
	@nix eval --raw ./d17.nix > d17.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for d17.nix. Check d17.eval.log for details."
		cat d17.eval.log; 		exit 1; 	}
	@echo "--- d17.nix test complete. Output in d17.eval.log ---"


