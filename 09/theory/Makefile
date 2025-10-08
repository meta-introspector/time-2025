include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/theory"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-nix_code_indexer

test-nix_code_indexer: nix_code_indexer.nix
	@echo "--- Testing nix_code_indexer.nix with nix eval ---"
	@nix eval --raw ./nix_code_indexer.nix > nix_code_indexer.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_code_indexer.nix. Check nix_code_indexer.eval.log for details."
		cat nix_code_indexer.eval.log; 		exit 1; 	}
	@echo "--- nix_code_indexer.nix test complete. Output in nix_code_indexer.eval.log ---"



.PHONY: test-n_gram_generator

test-n_gram_generator: n_gram_generator.nix
	@echo "--- Testing n_gram_generator.nix with nix eval ---"
	@nix eval --raw ./n_gram_generator.nix > n_gram_generator.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for n_gram_generator.nix. Check n_gram_generator.eval.log for details."
		cat n_gram_generator.eval.log; 		exit 1; 	}
	@echo "--- n_gram_generator.nix test complete. Output in n_gram_generator.eval.log ---"



.PHONY: test-nix_2gram_indexer_step1

test-nix_2gram_indexer_step1: nix_2gram_indexer_step1.nix
	@echo "--- Testing nix_2gram_indexer_step1.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step1.nix > nix_2gram_indexer_step1.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step1.nix. Check nix_2gram_indexer_step1.eval.log for details."
		cat nix_2gram_indexer_step1.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step1.nix test complete. Output in nix_2gram_indexer_step1.eval.log ---"



.PHONY: test-nix_2gram_indexer_step2

test-nix_2gram_indexer_step2: nix_2gram_indexer_step2.nix
	@echo "--- Testing nix_2gram_indexer_step2.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step2.nix > nix_2gram_indexer_step2.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step2.nix. Check nix_2gram_indexer_step2.eval.log for details."
		cat nix_2gram_indexer_step2.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step2.nix test complete. Output in nix_2gram_indexer_step2.eval.log ---"


