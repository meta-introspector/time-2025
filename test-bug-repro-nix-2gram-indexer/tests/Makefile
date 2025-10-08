include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./test-bug-repro-nix-2gram-indexer/tests"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-test_n_gram_generator_functions

test-test_n_gram_generator_functions: test_n_gram_generator_functions.nix
	@echo "--- Testing test_n_gram_generator_functions.nix with nix eval ---"
	@nix eval --raw ./test_n_gram_generator_functions.nix > test_n_gram_generator_functions.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test_n_gram_generator_functions.nix. Check test_n_gram_generator_functions.eval.log for details."
		cat test_n_gram_generator_functions.eval.log; 		exit 1; 	}
	@echo "--- test_n_gram_generator_functions.nix test complete. Output in test_n_gram_generator_functions.eval.log ---"



.PHONY: test-test_step1_nix_file_index

test-test_step1_nix_file_index: test_step1_nix_file_index.nix
	@echo "--- Testing test_step1_nix_file_index.nix with nix eval ---"
	@nix eval --raw ./test_step1_nix_file_index.nix > test_step1_nix_file_index.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test_step1_nix_file_index.nix. Check test_step1_nix_file_index.eval.log for details."
		cat test_step1_nix_file_index.eval.log; 		exit 1; 	}
	@echo "--- test_step1_nix_file_index.nix test complete. Output in test_step1_nix_file_index.eval.log ---"



.PHONY: test-test_step2_indexed_files

test-test_step2_indexed_files: test_step2_indexed_files.nix
	@echo "--- Testing test_step2_indexed_files.nix with nix eval ---"
	@nix eval --raw ./test_step2_indexed_files.nix > test_step2_indexed_files.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test_step2_indexed_files.nix. Check test_step2_indexed_files.eval.log for details."
		cat test_step2_indexed_files.eval.log; 		exit 1; 	}
	@echo "--- test_step2_indexed_files.nix test complete. Output in test_step2_indexed_files.eval.log ---"



.PHONY: test-test_step3_all2gram_usages

test-test_step3_all2gram_usages: test_step3_all2gram_usages.nix
	@echo "--- Testing test_step3_all2gram_usages.nix with nix eval ---"
	@nix eval --raw ./test_step3_all2gram_usages.nix > test_step3_all2gram_usages.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test_step3_all2gram_usages.nix. Check test_step3_all2gram_usages.eval.log for details."
		cat test_step3_all2gram_usages.eval.log; 		exit 1; 	}
	@echo "--- test_step3_all2gram_usages.nix test complete. Output in test_step3_all2gram_usages.eval.log ---"


