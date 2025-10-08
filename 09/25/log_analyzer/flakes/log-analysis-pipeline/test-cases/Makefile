include ../../../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/25/log_analyzer/flakes/log-analysis-pipeline/test-cases"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-bug-repro-build-time-gemini-capture

test-bug-repro-build-time-gemini-capture: bug-repro-build-time-gemini-capture.nix
	@echo "--- Testing bug-repro-build-time-gemini-capture.nix with nix eval ---"
	@nix eval --raw ./bug-repro-build-time-gemini-capture.nix > bug-repro-build-time-gemini-capture.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for bug-repro-build-time-gemini-capture.nix. Check bug-repro-build-time-gemini-capture.eval.log for details."
		cat bug-repro-build-time-gemini-capture.eval.log; 		exit 1; 	}
	@echo "--- bug-repro-build-time-gemini-capture.nix test complete. Output in bug-repro-build-time-gemini-capture.eval.log ---"


