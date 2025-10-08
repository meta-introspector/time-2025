include ../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/23/nix_concepts_and_facts"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 19214(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 19214(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 19214(pwd). Check develop.log for details."; 		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 19214(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.


.PHONY: test-ai_context

test-ai_context: ai_context.nix
	@echo "--- Testing ai_context.nix with nix eval ---"
	@nix eval --raw ./ai_context.nix > ai_context.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for ai_context.nix. Check ai_context.eval.log for details."
		cat ai_context.eval.log; 		exit 1; 	}
	@echo "--- ai_context.nix test complete. Output in ai_context.eval.log ---"



.PHONY: test-flake

test-flake: flake.nix
	@echo "--- Testing flake.nix with nix eval ---"
	@nix eval --raw ./flake.nix > flake.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for flake.nix. Check flake.eval.log for details."
		cat flake.eval.log; 		exit 1; 	}
	@echo "--- flake.nix test complete. Output in flake.eval.log ---"



.PHONY: test-test-ai-context

test-test-ai-context: test-ai-context.nix
	@echo "--- Testing test-ai-context.nix with nix eval ---"
	@nix eval --raw ./test-ai-context.nix > test-ai-context.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test-ai-context.nix. Check test-ai-context.eval.log for details."
		cat test-ai-context.eval.log; 		exit 1; 	}
	@echo "--- test-ai-context.nix test complete. Output in test-ai-context.eval.log ---"



.PHONY: test-test-zos-primes-links

test-test-zos-primes-links: test-zos-primes-links.nix
	@echo "--- Testing test-zos-primes-links.nix with nix eval ---"
	@nix eval --raw ./test-zos-primes-links.nix > test-zos-primes-links.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test-zos-primes-links.nix. Check test-zos-primes-links.eval.log for details."
		cat test-zos-primes-links.eval.log; 		exit 1; 	}
	@echo "--- test-zos-primes-links.nix test complete. Output in test-zos-primes-links.eval.log ---"


