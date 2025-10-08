include ../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/27/7-concepts/2-gemini-integration"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-nix-store-bundle-test

test-nix-store-bundle-test: nix-store-bundle-test.nix
	@echo "--- Testing nix-store-bundle-test.nix with nix eval ---"
	@nix eval --raw ./nix-store-bundle-test.nix > nix-store-bundle-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix-store-bundle-test.nix. Check nix-store-bundle-test.eval.log for details."
		cat nix-store-bundle-test.eval.log; 		exit 1; 	}
	@echo "--- nix-store-bundle-test.nix test complete. Output in nix-store-bundle-test.eval.log ---"



.PHONY: test-test-github-gemini

test-test-github-gemini: test-github-gemini.nix
	@echo "--- Testing test-github-gemini.nix with nix eval ---"
	@nix eval --raw ./test-github-gemini.nix > test-github-gemini.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test-github-gemini.nix. Check test-github-gemini.eval.log for details."
		cat test-github-gemini.eval.log; 		exit 1; 	}
	@echo "--- test-github-gemini.nix test complete. Output in test-github-gemini.eval.log ---"



.PHONY: test-working-nix-store-gemini

test-working-nix-store-gemini: working-nix-store-gemini.nix
	@echo "--- Testing working-nix-store-gemini.nix with nix eval ---"
	@nix eval --raw ./working-nix-store-gemini.nix > working-nix-store-gemini.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for working-nix-store-gemini.nix. Check working-nix-store-gemini.eval.log for details."
		cat working-nix-store-gemini.eval.log; 		exit 1; 	}
	@echo "--- working-nix-store-gemini.nix test complete. Output in working-nix-store-gemini.eval.log ---"


