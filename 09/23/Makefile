include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/23"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-analyze_ngrams

test-analyze_ngrams: analyze_ngrams.nix
	@echo "--- Testing analyze_ngrams.nix with nix eval ---"
	@nix eval --raw ./analyze_ngrams.nix > analyze_ngrams.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for analyze_ngrams.nix. Check analyze_ngrams.eval.log for details."
		cat analyze_ngrams.eval.log; 		exit 1; 	}
	@echo "--- analyze_ngrams.nix test complete. Output in analyze_ngrams.eval.log ---"



.PHONY: test-count_lines

test-count_lines: count_lines.nix
	@echo "--- Testing count_lines.nix with nix eval ---"
	@nix eval --raw ./count_lines.nix > count_lines.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for count_lines.nix. Check count_lines.eval.log for details."
		cat count_lines.eval.log; 		exit 1; 	}
	@echo "--- count_lines.nix test complete. Output in count_lines.eval.log ---"



.PHONY: test-debug_repair

test-debug_repair: debug_repair.nix
	@echo "--- Testing debug_repair.nix with nix eval ---"
	@nix eval --raw ./debug_repair.nix > debug_repair.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for debug_repair.nix. Check debug_repair.eval.log for details."
		cat debug_repair.eval.log; 		exit 1; 	}
	@echo "--- debug_repair.nix test complete. Output in debug_repair.eval.log ---"



.PHONY: test-repair_and_parse

test-repair_and_parse: repair_and_parse.nix
	@echo "--- Testing repair_and_parse.nix with nix eval ---"
	@nix eval --raw ./repair_and_parse.nix > repair_and_parse.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for repair_and_parse.nix. Check repair_and_parse.eval.log for details."
		cat repair_and_parse.eval.log; 		exit 1; 	}
	@echo "--- repair_and_parse.nix test complete. Output in repair_and_parse.eval.log ---"



.PHONY: test-uncommitted

test-uncommitted: uncommitted.nix
	@echo "--- Testing uncommitted.nix with nix eval ---"
	@nix eval --raw ./uncommitted.nix > uncommitted.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for uncommitted.nix. Check uncommitted.eval.log for details."
		cat uncommitted.eval.log; 		exit 1; 	}
	@echo "--- uncommitted.nix test complete. Output in uncommitted.eval.log ---"


