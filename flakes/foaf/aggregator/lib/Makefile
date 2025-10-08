include ../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./flakes/foaf/aggregator/lib"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-default

test-default: default.nix
	@echo "--- Testing default.nix with nix eval ---"
	@nix eval --raw ./default.nix > default.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for default.nix. Check default.eval.log for details."
		cat default.eval.log; 		exit 1; 	}
	@echo "--- default.nix test complete. Output in default.eval.log ---"



.PHONY: test-get-foaf-context

test-get-foaf-context: get-foaf-context.nix
	@echo "--- Testing get-foaf-context.nix with nix eval ---"
	@nix eval --raw ./get-foaf-context.nix > get-foaf-context.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for get-foaf-context.nix. Check get-foaf-context.eval.log for details."
		cat get-foaf-context.eval.log; 		exit 1; 	}
	@echo "--- get-foaf-context.nix test complete. Output in get-foaf-context.eval.log ---"



.PHONY: test-get-seed-graph

test-get-seed-graph: get-seed-graph.nix
	@echo "--- Testing get-seed-graph.nix with nix eval ---"
	@nix eval --raw ./get-seed-graph.nix > get-seed-graph.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for get-seed-graph.nix. Check get-seed-graph.eval.log for details."
		cat get-seed-graph.eval.log; 		exit 1; 	}
	@echo "--- get-seed-graph.nix test complete. Output in get-seed-graph.eval.log ---"



.PHONY: test-combine-full-graph

test-combine-full-graph: combine-full-graph.nix
	@echo "--- Testing combine-full-graph.nix with nix eval ---"
	@nix eval --raw ./combine-full-graph.nix > combine-full-graph.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for combine-full-graph.nix. Check combine-full-graph.eval.log for details."
		cat combine-full-graph.eval.log; 		exit 1; 	}
	@echo "--- combine-full-graph.nix test complete. Output in combine-full-graph.eval.log ---"


