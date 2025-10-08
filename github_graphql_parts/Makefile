include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./github_graphql_parts"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-github_graphql_part1

test-github_graphql_part1: github_graphql_part1.nix
	@echo "--- Testing github_graphql_part1.nix with nix eval ---"
	@nix eval --raw ./github_graphql_part1.nix > github_graphql_part1.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_part1.nix. Check github_graphql_part1.eval.log for details."
		cat github_graphql_part1.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_part1.nix test complete. Output in github_graphql_part1.eval.log ---"



.PHONY: test-github_graphql_build_query

test-github_graphql_build_query: github_graphql_build_query.nix
	@echo "--- Testing github_graphql_build_query.nix with nix eval ---"
	@nix eval --raw ./github_graphql_build_query.nix > github_graphql_build_query.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_build_query.nix. Check github_graphql_build_query.eval.log for details."
		cat github_graphql_build_query.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_build_query.nix test complete. Output in github_graphql_build_query.eval.log ---"



.PHONY: test-github_graphql_execute_query

test-github_graphql_execute_query: github_graphql_execute_query.nix
	@echo "--- Testing github_graphql_execute_query.nix with nix eval ---"
	@nix eval --raw ./github_graphql_execute_query.nix > github_graphql_execute_query.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_execute_query.nix. Check github_graphql_execute_query.eval.log for details."
		cat github_graphql_execute_query.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_execute_query.nix test complete. Output in github_graphql_execute_query.eval.log ---"



.PHONY: test-github_graphql_example_queries

test-github_graphql_example_queries: github_graphql_example_queries.nix
	@echo "--- Testing github_graphql_example_queries.nix with nix eval ---"
	@nix eval --raw ./github_graphql_example_queries.nix > github_graphql_example_queries.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_example_queries.nix. Check github_graphql_example_queries.eval.log for details."
		cat github_graphql_example_queries.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_example_queries.nix test complete. Output in github_graphql_example_queries.eval.log ---"



.PHONY: test-github_graphql_footer

test-github_graphql_footer: github_graphql_footer.nix
	@echo "--- Testing github_graphql_footer.nix with nix eval ---"
	@nix eval --raw ./github_graphql_footer.nix > github_graphql_footer.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_footer.nix. Check github_graphql_footer.eval.log for details."
		cat github_graphql_footer.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_footer.nix test complete. Output in github_graphql_footer.eval.log ---"


