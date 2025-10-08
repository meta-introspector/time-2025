include ../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/04/gemini-prompt-flake"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 19214(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 19214(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 19214(pwd). Check develop.log for details."; 		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 19214(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.


.PHONY: test-flake

test-flake: flake.nix
	@echo "--- Testing flake.nix with nix eval ---"
	@nix eval --raw ./flake.nix > flake.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for flake.nix. Check flake.eval.log for details."
		cat flake.eval.log; 		exit 1; 	}
	@echo "--- flake.nix test complete. Output in flake.eval.log ---"



.PHONY: test-gemini-prompt-derivation

test-gemini-prompt-derivation: gemini-prompt-derivation.nix
	@echo "--- Testing gemini-prompt-derivation.nix with nix eval ---"
	@nix eval --raw ./gemini-prompt-derivation.nix > gemini-prompt-derivation.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for gemini-prompt-derivation.nix. Check gemini-prompt-derivation.eval.log for details."
		cat gemini-prompt-derivation.eval.log; 		exit 1; 	}
	@echo "--- gemini-prompt-derivation.nix test complete. Output in gemini-prompt-derivation.eval.log ---"



.PHONY: test-default-prompt

test-default-prompt: default-prompt.nix
	@echo "--- Testing default-prompt.nix with nix eval ---"
	@nix eval --raw ./default-prompt.nix > default-prompt.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for default-prompt.nix. Check default-prompt.eval.log for details."
		cat default-prompt.eval.log; 		exit 1; 	}
	@echo "--- default-prompt.nix test complete. Output in default-prompt.eval.log ---"



.PHONY: test-secrets

test-secrets: secrets.nix
	@echo "--- Testing secrets.nix with nix eval ---"
	@nix eval --raw ./secrets.nix > secrets.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for secrets.nix. Check secrets.eval.log for details."
		cat secrets.eval.log; 		exit 1; 	}
	@echo "--- secrets.nix test complete. Output in secrets.eval.log ---"


