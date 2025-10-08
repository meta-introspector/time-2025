include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./docs"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-uncommitted

test-uncommitted: uncommitted.nix
	@echo "--- Testing uncommitted.nix with nix eval ---"
	@nix eval --raw ./uncommitted.nix > uncommitted.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for uncommitted.nix. Check uncommitted.eval.log for details."
		cat uncommitted.eval.log; 		exit 1; 	}
	@echo "--- uncommitted.nix test complete. Output in uncommitted.eval.log ---"



.PHONY: test-NixOSI_Vision

test-NixOSI_Vision: NixOSI_Vision.nix
	@echo "--- Testing NixOSI_Vision.nix with nix eval ---"
	@nix eval --raw ./NixOSI_Vision.nix > NixOSI_Vision.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for NixOSI_Vision.nix. Check NixOSI_Vision.eval.log for details."
		cat NixOSI_Vision.eval.log; 		exit 1; 	}
	@echo "--- NixOSI_Vision.nix test complete. Output in NixOSI_Vision.eval.log ---"


