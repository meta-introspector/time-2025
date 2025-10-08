include ../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/04/lib"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-error-constructor

test-error-constructor: error-constructor.nix
	@echo "--- Testing error-constructor.nix with nix eval ---"
	@nix eval --raw ./error-constructor.nix > error-constructor.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for error-constructor.nix. Check error-constructor.eval.log for details."
		cat error-constructor.eval.log; 		exit 1; 	}
	@echo "--- error-constructor.nix test complete. Output in error-constructor.eval.log ---"



.PHONY: test-error-isolation

test-error-isolation: error-isolation.nix
	@echo "--- Testing error-isolation.nix with nix eval ---"
	@nix eval --raw ./error-isolation.nix > error-isolation.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for error-isolation.nix. Check error-isolation.eval.log for details."
		cat error-isolation.eval.log; 		exit 1; 	}
	@echo "--- error-isolation.nix test complete. Output in error-isolation.eval.log ---"



.PHONY: test-fold-accumulator

test-fold-accumulator: fold-accumulator.nix
	@echo "--- Testing fold-accumulator.nix with nix eval ---"
	@nix eval --raw ./fold-accumulator.nix > fold-accumulator.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for fold-accumulator.nix. Check fold-accumulator.eval.log for details."
		cat fold-accumulator.eval.log; 		exit 1; 	}
	@echo "--- fold-accumulator.nix test complete. Output in fold-accumulator.eval.log ---"



.PHONY: test-wrapEval

test-wrapEval: wrapEval.nix
	@echo "--- Testing wrapEval.nix with nix eval ---"
	@nix eval --raw ./wrapEval.nix > wrapEval.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for wrapEval.nix. Check wrapEval.eval.log for details."
		cat wrapEval.eval.log; 		exit 1; 	}
	@echo "--- wrapEval.nix test complete. Output in wrapEval.eval.log ---"



.PHONY: test-crq-document-check

test-crq-document-check: crq-document-check.nix
	@echo "--- Testing crq-document-check.nix with nix eval ---"
	@nix eval --raw ./crq-document-check.nix > crq-document-check.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-document-check.nix. Check crq-document-check.eval.log for details."
		cat crq-document-check.eval.log; 		exit 1; 	}
	@echo "--- crq-document-check.nix test complete. Output in crq-document-check.eval.log ---"



.PHONY: test-dump-pkgs-env

test-dump-pkgs-env: dump-pkgs-env.nix
	@echo "--- Testing dump-pkgs-env.nix with nix eval ---"
	@nix eval --raw ./dump-pkgs-env.nix > dump-pkgs-env.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for dump-pkgs-env.nix. Check dump-pkgs-env.eval.log for details."
		cat dump-pkgs-env.eval.log; 		exit 1; 	}
	@echo "--- dump-pkgs-env.nix test complete. Output in dump-pkgs-env.eval.log ---"



.PHONY: test-simplified-pkgs-dump

test-simplified-pkgs-dump: simplified-pkgs-dump.nix
	@echo "--- Testing simplified-pkgs-dump.nix with nix eval ---"
	@nix eval --raw ./simplified-pkgs-dump.nix > simplified-pkgs-dump.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for simplified-pkgs-dump.nix. Check simplified-pkgs-dump.eval.log for details."
		cat simplified-pkgs-dump.eval.log; 		exit 1; 	}
	@echo "--- simplified-pkgs-dump.nix test complete. Output in simplified-pkgs-dump.eval.log ---"



.PHONY: test-nix-stdlib-integration-test

test-nix-stdlib-integration-test: nix-stdlib-integration-test.nix
	@echo "--- Testing nix-stdlib-integration-test.nix with nix eval ---"
	@nix eval --raw ./nix-stdlib-integration-test.nix > nix-stdlib-integration-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix-stdlib-integration-test.nix. Check nix-stdlib-integration-test.eval.log for details."
		cat nix-stdlib-integration-test.eval.log; 		exit 1; 	}
	@echo "--- nix-stdlib-integration-test.nix test complete. Output in nix-stdlib-integration-test.eval.log ---"



.PHONY: test-crq-search

test-crq-search: crq-search.nix
	@echo "--- Testing crq-search.nix with nix eval ---"
	@nix eval --raw ./crq-search.nix > crq-search.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-search.nix. Check crq-search.eval.log for details."
		cat crq-search.eval.log; 		exit 1; 	}
	@echo "--- crq-search.nix test complete. Output in crq-search.eval.log ---"


