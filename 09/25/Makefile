include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/25"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-prime_lattice

test-prime_lattice: prime_lattice.nix
	@echo "--- Testing prime_lattice.nix with nix eval ---"
	@nix eval --raw ./prime_lattice.nix > prime_lattice.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for prime_lattice.nix. Check prime_lattice.eval.log for details."
		cat prime_lattice.eval.log; 		exit 1; 	}
	@echo "--- prime_lattice.nix test complete. Output in prime_lattice.eval.log ---"



.PHONY: test-interpreter

test-interpreter: interpreter.nix
	@echo "--- Testing interpreter.nix with nix eval ---"
	@nix eval --raw ./interpreter.nix > interpreter.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for interpreter.nix. Check interpreter.eval.log for details."
		cat interpreter.eval.log; 		exit 1; 	}
	@echo "--- interpreter.nix test complete. Output in interpreter.eval.log ---"



.PHONY: test-test_prime_encoder

test-test_prime_encoder: test_prime_encoder.nix
	@echo "--- Testing test_prime_encoder.nix with nix eval ---"
	@nix eval --raw ./test_prime_encoder.nix > test_prime_encoder.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test_prime_encoder.nix. Check test_prime_encoder.eval.log for details."
		cat test_prime_encoder.eval.log; 		exit 1; 	}
	@echo "--- test_prime_encoder.nix test complete. Output in test_prime_encoder.eval.log ---"



.PHONY: test-gemini-prompt-derivation

test-gemini-prompt-derivation: gemini-prompt-derivation.nix
	@echo "--- Testing gemini-prompt-derivation.nix with nix eval ---"
	@nix eval --raw ./gemini-prompt-derivation.nix > gemini-prompt-derivation.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for gemini-prompt-derivation.nix. Check gemini-prompt-derivation.eval.log for details."
		cat gemini-prompt-derivation.eval.log; 		exit 1; 	}
	@echo "--- gemini-prompt-derivation.nix test complete. Output in gemini-prompt-derivation.eval.log ---"


