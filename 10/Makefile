include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-crq-text-extractor

test-crq-text-extractor: crq-text-extractor.nix
	@echo "--- Testing crq-text-extractor.nix with nix eval ---"
	@nix eval --raw ./crq-text-extractor.nix > crq-text-extractor.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-text-extractor.nix. Check crq-text-extractor.eval.log for details."
		cat crq-text-extractor.eval.log; 		exit 1; 	}
	@echo "--- crq-text-extractor.nix test complete. Output in crq-text-extractor.eval.log ---"



.PHONY: test-crq-bigram-generator

test-crq-bigram-generator: crq-bigram-generator.nix
	@echo "--- Testing crq-bigram-generator.nix with nix eval ---"
	@nix eval --raw ./crq-bigram-generator.nix > crq-bigram-generator.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-bigram-generator.nix. Check crq-bigram-generator.eval.log for details."
		cat crq-bigram-generator.eval.log; 		exit 1; 	}
	@echo "--- crq-bigram-generator.nix test complete. Output in crq-bigram-generator.eval.log ---"



.PHONY: test-similarity-matrix

test-similarity-matrix: similarity-matrix.nix
	@echo "--- Testing similarity-matrix.nix with nix eval ---"
	@nix eval --raw ./similarity-matrix.nix > similarity-matrix.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for similarity-matrix.nix. Check similarity-matrix.eval.log for details."
		cat similarity-matrix.eval.log; 		exit 1; 	}
	@echo "--- similarity-matrix.nix test complete. Output in similarity-matrix.eval.log ---"


