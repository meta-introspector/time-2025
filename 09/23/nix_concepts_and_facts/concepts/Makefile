include ../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/23/nix_concepts_and_facts/concepts"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-fact_23_oracle

test-fact_23_oracle: fact_23_oracle.nix
	@echo "--- Testing fact_23_oracle.nix with nix eval ---"
	@nix eval --raw ./fact_23_oracle.nix > fact_23_oracle.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for fact_23_oracle.nix. Check fact_23_oracle.eval.log for details."
		cat fact_23_oracle.eval.log; 		exit 1; 	}
	@echo "--- fact_23_oracle.nix test complete. Output in fact_23_oracle.eval.log ---"



.PHONY: test-is_prime

test-is_prime: is_prime.nix
	@echo "--- Testing is_prime.nix with nix eval ---"
	@nix eval --raw ./is_prime.nix > is_prime.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for is_prime.nix. Check is_prime.eval.log for details."
		cat is_prime.eval.log; 		exit 1; 	}
	@echo "--- is_prime.nix test complete. Output in is_prime.eval.log ---"



.PHONY: test-number_23

test-number_23: number_23.nix
	@echo "--- Testing number_23.nix with nix eval ---"
	@nix eval --raw ./number_23.nix > number_23.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for number_23.nix. Check number_23.eval.log for details."
		cat number_23.eval.log; 		exit 1; 	}
	@echo "--- number_23.nix test complete. Output in number_23.eval.log ---"


