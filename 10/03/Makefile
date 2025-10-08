include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/03"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 19214(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 19214(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 19214(pwd). Check develop.log for details."; 		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 19214(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.


.PHONY: test-ooda

test-ooda: ooda.nix
	@echo "--- Testing ooda.nix with nix eval ---"
	@nix eval --raw ./ooda.nix > ooda.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for ooda.nix. Check ooda.eval.log for details."
		cat ooda.eval.log; 		exit 1; 	}
	@echo "--- ooda.nix test complete. Output in ooda.eval.log ---"



.PHONY: test-flake

test-flake: flake.nix
	@echo "--- Testing flake.nix with nix eval ---"
	@nix eval --raw ./flake.nix > flake.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for flake.nix. Check flake.eval.log for details."
		cat flake.eval.log; 		exit 1; 	}
	@echo "--- flake.nix test complete. Output in flake.eval.log ---"



.PHONY: test-hackathon_71_parts

test-hackathon_71_parts: hackathon_71_parts.nix
	@echo "--- Testing hackathon_71_parts.nix with nix eval ---"
	@nix eval --raw ./hackathon_71_parts.nix > hackathon_71_parts.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for hackathon_71_parts.nix. Check hackathon_71_parts.eval.log for details."
		cat hackathon_71_parts.eval.log; 		exit 1; 	}
	@echo "--- hackathon_71_parts.nix test complete. Output in hackathon_71_parts.eval.log ---"



.PHONY: test-uncommitted

test-uncommitted: uncommitted.nix
	@echo "--- Testing uncommitted.nix with nix eval ---"
	@nix eval --raw ./uncommitted.nix > uncommitted.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for uncommitted.nix. Check uncommitted.eval.log for details."
		cat uncommitted.eval.log; 		exit 1; 	}
	@echo "--- uncommitted.nix test complete. Output in uncommitted.eval.log ---"


