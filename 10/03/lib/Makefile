include ../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/03/lib"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-plantuml_generator

test-plantuml_generator: plantuml_generator.nix
	@echo "--- Testing plantuml_generator.nix with nix eval ---"
	@nix eval --raw ./plantuml_generator.nix > plantuml_generator.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for plantuml_generator.nix. Check plantuml_generator.eval.log for details."
		cat plantuml_generator.eval.log; 		exit 1; 	}
	@echo "--- plantuml_generator.nix test complete. Output in plantuml_generator.eval.log ---"


