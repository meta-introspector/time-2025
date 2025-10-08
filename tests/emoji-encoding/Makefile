include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./tests/emoji-encoding"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-string-test

test-string-test: string-test.nix
	@echo "--- Testing string-test.nix with nix eval ---"
	@nix eval --raw ./string-test.nix > string-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for string-test.nix. Check string-test.eval.log for details."
		cat string-test.eval.log; 		exit 1; 	}
	@echo "--- string-test.nix test complete. Output in string-test.eval.log ---"



.PHONY: test-list-test

test-list-test: list-test.nix
	@echo "--- Testing list-test.nix with nix eval ---"
	@nix eval --raw ./list-test.nix > list-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for list-test.nix. Check list-test.eval.log for details."
		cat list-test.eval.log; 		exit 1; 	}
	@echo "--- list-test.nix test complete. Output in list-test.eval.log ---"



.PHONY: test-attrset-test

test-attrset-test: attrset-test.nix
	@echo "--- Testing attrset-test.nix with nix eval ---"
	@nix eval --raw ./attrset-test.nix > attrset-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for attrset-test.nix. Check attrset-test.eval.log for details."
		cat attrset-test.eval.log; 		exit 1; 	}
	@echo "--- attrset-test.nix test complete. Output in attrset-test.eval.log ---"



.PHONY: test-int-test

test-int-test: int-test.nix
	@echo "--- Testing int-test.nix with nix eval ---"
	@nix eval --raw ./int-test.nix > int-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for int-test.nix. Check int-test.eval.log for details."
		cat int-test.eval.log; 		exit 1; 	}
	@echo "--- int-test.nix test complete. Output in int-test.eval.log ---"



.PHONY: test-lambda-test

test-lambda-test: lambda-test.nix
	@echo "--- Testing lambda-test.nix with nix eval ---"
	@nix eval --raw ./lambda-test.nix > lambda-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for lambda-test.nix. Check lambda-test.eval.log for details."
		cat lambda-test.eval.log; 		exit 1; 	}
	@echo "--- lambda-test.nix test complete. Output in lambda-test.eval.log ---"



.PHONY: test-let-in-test

test-let-in-test: let-in-test.nix
	@echo "--- Testing let-in-test.nix with nix eval ---"
	@nix eval --raw ./let-in-test.nix > let-in-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for let-in-test.nix. Check let-in-test.eval.log for details."
		cat let-in-test.eval.log; 		exit 1; 	}
	@echo "--- let-in-test.nix test complete. Output in let-in-test.eval.log ---"



.PHONY: test-if-then-else-test

test-if-then-else-test: if-then-else-test.nix
	@echo "--- Testing if-then-else-test.nix with nix eval ---"
	@nix eval --raw ./if-then-else-test.nix > if-then-else-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for if-then-else-test.nix. Check if-then-else-test.eval.log for details."
		cat if-then-else-test.eval.log; 		exit 1; 	}
	@echo "--- if-then-else-test.nix test complete. Output in if-then-else-test.eval.log ---"


