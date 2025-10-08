include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./solvers"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-run-prime-mapping-solver

test-run-prime-mapping-solver: run-prime-mapping-solver.nix
	@echo "--- Testing run-prime-mapping-solver.nix with nix eval ---"
	@nix eval --raw ./run-prime-mapping-solver.nix > run-prime-mapping-solver.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for run-prime-mapping-solver.nix. Check run-prime-mapping-solver.eval.log for details."
		cat run-prime-mapping-solver.eval.log; 		exit 1; 	}
	@echo "--- run-prime-mapping-solver.nix test complete. Output in run-prime-mapping-solver.eval.log ---"



.PHONY: test-generate-mzn-model

test-generate-mzn-model: generate-mzn-model.nix
	@echo "--- Testing generate-mzn-model.nix with nix eval ---"
	@nix eval --raw ./generate-mzn-model.nix > generate-mzn-model.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for generate-mzn-model.nix. Check generate-mzn-model.eval.log for details."
		cat generate-mzn-model.eval.log; 		exit 1; 	}
	@echo "--- generate-mzn-model.nix test complete. Output in generate-mzn-model.eval.log ---"



.PHONY: test-generate-dzn-data

test-generate-dzn-data: generate-dzn-data.nix
	@echo "--- Testing generate-dzn-data.nix with nix eval ---"
	@nix eval --raw ./generate-dzn-data.nix > generate-dzn-data.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for generate-dzn-data.nix. Check generate-dzn-data.eval.log for details."
		cat generate-dzn-data.eval.log; 		exit 1; 	}
	@echo "--- generate-dzn-data.nix test complete. Output in generate-dzn-data.eval.log ---"



.PHONY: test-generate-oeis-dzn

test-generate-oeis-dzn: generate-oeis-dzn.nix
	@echo "--- Testing generate-oeis-dzn.nix with nix eval ---"
	@nix eval --raw ./generate-oeis-dzn.nix > generate-oeis-dzn.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for generate-oeis-dzn.nix. Check generate-oeis-dzn.eval.log for details."
		cat generate-oeis-dzn.eval.log; 		exit 1; 	}
	@echo "--- generate-oeis-dzn.nix test complete. Output in generate-oeis-dzn.eval.log ---"



.PHONY: test-run-oeis-solver

test-run-oeis-solver: run-oeis-solver.nix
	@echo "--- Testing run-oeis-solver.nix with nix eval ---"
	@nix eval --raw ./run-oeis-solver.nix > run-oeis-solver.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for run-oeis-solver.nix. Check run-oeis-solver.eval.log for details."
		cat run-oeis-solver.eval.log; 		exit 1; 	}
	@echo "--- run-oeis-solver.nix test complete. Output in run-oeis-solver.eval.log ---"


