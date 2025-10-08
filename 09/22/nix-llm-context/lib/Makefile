include ../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/22/nix-llm-context/lib"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-prime-sieve

test-prime-sieve: prime-sieve.nix
	@echo "--- Testing prime-sieve.nix with nix eval ---"
	@nix eval --raw ./prime-sieve.nix > prime-sieve.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for prime-sieve.nix. Check prime-sieve.eval.log for details."
		cat prime-sieve.eval.log; 		exit 1; 	}
	@echo "--- prime-sieve.nix test complete. Output in prime-sieve.eval.log ---"


