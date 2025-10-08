include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/07"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-nix-monster-encoding

test-nix-monster-encoding: nix-monster-encoding.nix
	@echo "--- Testing nix-monster-encoding.nix with nix eval ---"
	@nix eval --raw ./nix-monster-encoding.nix > nix-monster-encoding.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix-monster-encoding.nix. Check nix-monster-encoding.eval.log for details."
		cat nix-monster-encoding.eval.log; 		exit 1; 	}
	@echo "--- nix-monster-encoding.nix test complete. Output in nix-monster-encoding.eval.log ---"


