include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./test-bug-repro-nix-2gram-indexer"))')/nix_eval_module.mk


include /nix_eval_module.mk


test:
	nix flake check --extra-experimental-features impure-derivations --extra-experimental-features ca-derivations --show-trace -vv

build-dependencies:
	nix build --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --file inspect_indexer_output.nix

inspect-indexer-output: build-dependencies
	# The actual command to inspect the output will go here after the build
	# For now, we just rely on the build-dependencies target to build it.
	# We can then inspect the 'result' symlink manually.

inspect-derivation-output:
	nix build --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --file inspect_derivation_output.nix

build-vibe1:
	nix build --impure --expr '(import (builtins.getFlake ./. )).packages.aarch64-linux.vibe1 { projectRoot = "github:meta-introspector/time-2025?dir=test-bug-repro-nix-2gram-indexer"; }' --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' -o vibe1-output

test-flatten:
	nix --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' eval --raw --file test_flatten.nix

test-step1:
	nix build --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --file tests/test_step1_nix_file_index.nix

test-step2:
	nix --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' eval --raw --file tests/test_step2_indexed_files.nix

test-step3:
	nix --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' eval --raw --file tests/test_step3_all2gram_usages.nix

test-ngram-functions:
	nix --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' eval --raw --file tests/test_n_gram_generator_functions.nix
.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.


.PHONY: test-flake

test-flake: flake.nix
	@echo "--- Testing flake.nix with nix eval ---"
	@nix eval --raw ./flake.nix > flake.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for flake.nix. Check flake.eval.log for details."
		cat flake.eval.log; 		exit 1; 	}
	@echo "--- flake.nix test complete. Output in flake.eval.log ---"



.PHONY: test-inspect_derivation_output

test-inspect_derivation_output: inspect_derivation_output.nix
	@echo "--- Testing inspect_derivation_output.nix with nix eval ---"
	@nix eval --raw ./inspect_derivation_output.nix > inspect_derivation_output.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for inspect_derivation_output.nix. Check inspect_derivation_output.eval.log for details."
		cat inspect_derivation_output.eval.log; 		exit 1; 	}
	@echo "--- inspect_derivation_output.nix test complete. Output in inspect_derivation_output.eval.log ---"



.PHONY: test-inspect_indexer_output

test-inspect_indexer_output: inspect_indexer_output.nix
	@echo "--- Testing inspect_indexer_output.nix with nix eval ---"
	@nix eval --raw ./inspect_indexer_output.nix > inspect_indexer_output.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for inspect_indexer_output.nix. Check inspect_indexer_output.eval.log for details."
		cat inspect_indexer_output.eval.log; 		exit 1; 	}
	@echo "--- inspect_indexer_output.nix test complete. Output in inspect_indexer_output.eval.log ---"



.PHONY: test-test_flatten

test-test_flatten: test_flatten.nix
	@echo "--- Testing test_flatten.nix with nix eval ---"
	@nix eval --raw ./test_flatten.nix > test_flatten.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test_flatten.nix. Check test_flatten.eval.log for details."
		cat test_flatten.eval.log; 		exit 1; 	}
	@echo "--- test_flatten.nix test complete. Output in test_flatten.eval.log ---"


