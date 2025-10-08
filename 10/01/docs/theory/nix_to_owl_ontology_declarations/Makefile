include ../../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/01/docs/theory/nix_to_owl_ontology_declarations"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-prefixes

test-prefixes: prefixes.nix
	@echo "--- Testing prefixes.nix with nix eval ---"
	@nix eval --raw ./prefixes.nix > prefixes.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for prefixes.nix. Check prefixes.eval.log for details."
		cat prefixes.eval.log; 		exit 1; 	}
	@echo "--- prefixes.nix test complete. Output in prefixes.eval.log ---"



.PHONY: test-nixToOwlMapper

test-nixToOwlMapper: nixToOwlMapper.nix
	@echo "--- Testing nixToOwlMapper.nix with nix eval ---"
	@nix eval --raw ./nixToOwlMapper.nix > nixToOwlMapper.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nixToOwlMapper.nix. Check nixToOwlMapper.eval.log for details."
		cat nixToOwlMapper.eval.log; 		exit 1; 	}
	@echo "--- nixToOwlMapper.nix test complete. Output in nixToOwlMapper.eval.log ---"


