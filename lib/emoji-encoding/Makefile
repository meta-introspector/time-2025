include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./lib/emoji-encoding"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-string

test-string: string.nix
	@echo "--- Testing string.nix with nix eval ---"
	@nix eval --raw ./string.nix > string.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for string.nix. Check string.eval.log for details."
		cat string.eval.log; 		exit 1; 	}
	@echo "--- string.nix test complete. Output in string.eval.log ---"



.PHONY: test-list

test-list: list.nix
	@echo "--- Testing list.nix with nix eval ---"
	@nix eval --raw ./list.nix > list.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for list.nix. Check list.eval.log for details."
		cat list.eval.log; 		exit 1; 	}
	@echo "--- list.nix test complete. Output in list.eval.log ---"



.PHONY: test-attrset

test-attrset: attrset.nix
	@echo "--- Testing attrset.nix with nix eval ---"
	@nix eval --raw ./attrset.nix > attrset.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for attrset.nix. Check attrset.eval.log for details."
		cat attrset.eval.log; 		exit 1; 	}
	@echo "--- attrset.nix test complete. Output in attrset.eval.log ---"



.PHONY: test-int

test-int: int.nix
	@echo "--- Testing int.nix with nix eval ---"
	@nix eval --raw ./int.nix > int.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for int.nix. Check int.eval.log for details."
		cat int.eval.log; 		exit 1; 	}
	@echo "--- int.nix test complete. Output in int.eval.log ---"



.PHONY: test-lambda

test-lambda: lambda.nix
	@echo "--- Testing lambda.nix with nix eval ---"
	@nix eval --raw ./lambda.nix > lambda.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for lambda.nix. Check lambda.eval.log for details."
		cat lambda.eval.log; 		exit 1; 	}
	@echo "--- lambda.nix test complete. Output in lambda.eval.log ---"



.PHONY: test-let-in

test-let-in: let-in.nix
	@echo "--- Testing let-in.nix with nix eval ---"
	@nix eval --raw ./let-in.nix > let-in.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for let-in.nix. Check let-in.eval.log for details."
		cat let-in.eval.log; 		exit 1; 	}
	@echo "--- let-in.nix test complete. Output in let-in.eval.log ---"



.PHONY: test-if-then-else

test-if-then-else: if-then-else.nix
	@echo "--- Testing if-then-else.nix with nix eval ---"
	@nix eval --raw ./if-then-else.nix > if-then-else.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for if-then-else.nix. Check if-then-else.eval.log for details."
		cat if-then-else.eval.log; 		exit 1; 	}
	@echo "--- if-then-else.nix test complete. Output in if-then-else.eval.log ---"


