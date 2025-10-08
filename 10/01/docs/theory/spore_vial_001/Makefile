include ../../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/01/docs/theory/spore_vial_001"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-metacoq_graphql_meme

test-metacoq_graphql_meme: metacoq_graphql_meme.nix
	@echo "--- Testing metacoq_graphql_meme.nix with nix eval ---"
	@nix eval --raw ./metacoq_graphql_meme.nix > metacoq_graphql_meme.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for metacoq_graphql_meme.nix. Check metacoq_graphql_meme.eval.log for details."
		cat metacoq_graphql_meme.eval.log; 		exit 1; 	}
	@echo "--- metacoq_graphql_meme.nix test complete. Output in metacoq_graphql_meme.eval.log ---"


