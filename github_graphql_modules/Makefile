include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./github_graphql_modules"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-github_graphql_common

test-github_graphql_common: github_graphql_common.nix
	@echo "--- Testing github_graphql_common.nix with nix eval ---"
	@nix eval --raw ./github_graphql_common.nix > github_graphql_common.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_common.nix. Check github_graphql_common.eval.log for details."
		cat github_graphql_common.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_common.nix test complete. Output in github_graphql_common.eval.log ---"



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



.PHONY: test-github_graphql_main

test-github_graphql_main: github_graphql_main.nix
	@echo "--- Testing github_graphql_main.nix with nix eval ---"
	@nix eval --raw ./github_graphql_main.nix > github_graphql_main.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_main.nix. Check github_graphql_main.eval.log for details."
		cat github_graphql_main.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_main.nix test complete. Output in github_graphql_main.eval.log ---"



.PHONY: test-github_graphql_execute_query-test

test-github_graphql_execute_query-test: github_graphql_execute_query-test.nix
	@echo "--- Testing github_graphql_execute_query-test.nix with nix eval ---"
	@nix eval --raw ./github_graphql_execute_query-test.nix > github_graphql_execute_query-test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_execute_query-test.nix. Check github_graphql_execute_query-test.eval.log for details."
		cat github_graphql_execute_query-test.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_execute_query-test.nix test complete. Output in github_graphql_execute_query-test.eval.log ---"



.PHONY: test-github_graphql_get_repository_details

test-github_graphql_get_repository_details: github_graphql_get_repository_details.nix
	@echo "--- Testing github_graphql_get_repository_details.nix with nix eval ---"
	@nix eval --raw ./github_graphql_get_repository_details.nix > github_graphql_get_repository_details.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_get_repository_details.nix. Check github_graphql_get_repository_details.eval.log for details."
		cat github_graphql_get_repository_details.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_get_repository_details.nix test complete. Output in github_graphql_get_repository_details.eval.log ---"



.PHONY: test-github_graphql_list_repository_issues

test-github_graphql_list_repository_issues: github_graphql_list_repository_issues.nix
	@echo "--- Testing github_graphql_list_repository_issues.nix with nix eval ---"
	@nix eval --raw ./github_graphql_list_repository_issues.nix > github_graphql_list_repository_issues.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github_graphql_list_repository_issues.nix. Check github_graphql_list_repository_issues.eval.log for details."
		cat github_graphql_list_repository_issues.eval.log; 		exit 1; 	}
	@echo "--- github_graphql_list_repository_issues.nix test complete. Output in github_graphql_list_repository_issues.eval.log ---"


