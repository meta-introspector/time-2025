include ../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/23/nix_concepts_and_facts/lib"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-ai-context

test-ai-context: ai-context.nix
	@echo "--- Testing ai-context.nix with nix eval ---"
	@nix eval --raw ./ai-context.nix > ai-context.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for ai-context.nix. Check ai-context.eval.log for details."
		cat ai-context.eval.log; 		exit 1; 	}
	@echo "--- ai-context.nix test complete. Output in ai-context.eval.log ---"



.PHONY: test-concepts

test-concepts: concepts.nix
	@echo "--- Testing concepts.nix with nix eval ---"
	@nix eval --raw ./concepts.nix > concepts.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for concepts.nix. Check concepts.eval.log for details."
		cat concepts.eval.log; 		exit 1; 	}
	@echo "--- concepts.nix test complete. Output in concepts.eval.log ---"



.PHONY: test-primes

test-primes: primes.nix
	@echo "--- Testing primes.nix with nix eval ---"
	@nix eval --raw ./primes.nix > primes.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for primes.nix. Check primes.eval.log for details."
		cat primes.eval.log; 		exit 1; 	}
	@echo "--- primes.nix test complete. Output in primes.eval.log ---"



.PHONY: test-zos

test-zos: zos.nix
	@echo "--- Testing zos.nix with nix eval ---"
	@nix eval --raw ./zos.nix > zos.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for zos.nix. Check zos.eval.log for details."
		cat zos.eval.log; 		exit 1; 	}
	@echo "--- zos.nix test complete. Output in zos.eval.log ---"


