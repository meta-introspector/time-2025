include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./lib/simple_expr_traversal_handlers"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-bvar

test-bvar: bvar.nix
	@echo "--- Testing bvar.nix with nix eval ---"
	@nix eval --raw ./bvar.nix > bvar.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for bvar.nix. Check bvar.eval.log for details."
		cat bvar.eval.log; 		exit 1; 	}
	@echo "--- bvar.nix test complete. Output in bvar.eval.log ---"



.PHONY: test-sort

test-sort: sort.nix
	@echo "--- Testing sort.nix with nix eval ---"
	@nix eval --raw ./sort.nix > sort.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for sort.nix. Check sort.eval.log for details."
		cat sort.eval.log; 		exit 1; 	}
	@echo "--- sort.nix test complete. Output in sort.eval.log ---"



.PHONY: test-const

test-const: const.nix
	@echo "--- Testing const.nix with nix eval ---"
	@nix eval --raw ./const.nix > const.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for const.nix. Check const.eval.log for details."
		cat const.eval.log; 		exit 1; 	}
	@echo "--- const.nix test complete. Output in const.eval.log ---"



.PHONY: test-app

test-app: app.nix
	@echo "--- Testing app.nix with nix eval ---"
	@nix eval --raw ./app.nix > app.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for app.nix. Check app.eval.log for details."
		cat app.eval.log; 		exit 1; 	}
	@echo "--- app.nix test complete. Output in app.eval.log ---"



.PHONY: test-lam

test-lam: lam.nix
	@echo "--- Testing lam.nix with nix eval ---"
	@nix eval --raw ./lam.nix > lam.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for lam.nix. Check lam.eval.log for details."
		cat lam.eval.log; 		exit 1; 	}
	@echo "--- lam.nix test complete. Output in lam.eval.log ---"



.PHONY: test-forallE

test-forallE: forallE.nix
	@echo "--- Testing forallE.nix with nix eval ---"
	@nix eval --raw ./forallE.nix > forallE.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for forallE.nix. Check forallE.eval.log for details."
		cat forallE.eval.log; 		exit 1; 	}
	@echo "--- forallE.nix test complete. Output in forallE.eval.log ---"



.PHONY: test-defaultAttr

test-defaultAttr: defaultAttr.nix
	@echo "--- Testing defaultAttr.nix with nix eval ---"
	@nix eval --raw ./defaultAttr.nix > defaultAttr.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for defaultAttr.nix. Check defaultAttr.eval.log for details."
		cat defaultAttr.eval.log; 		exit 1; 	}
	@echo "--- defaultAttr.nix test complete. Output in defaultAttr.eval.log ---"



.PHONY: test-defaultList

test-defaultList: defaultList.nix
	@echo "--- Testing defaultList.nix with nix eval ---"
	@nix eval --raw ./defaultList.nix > defaultList.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for defaultList.nix. Check defaultList.eval.log for details."
		cat defaultList.eval.log; 		exit 1; 	}
	@echo "--- defaultList.nix test complete. Output in defaultList.eval.log ---"



.PHONY: test-default

test-default: default.nix
	@echo "--- Testing default.nix with nix eval ---"
	@nix eval --raw ./default.nix > default.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for default.nix. Check default.eval.log for details."
		cat default.eval.log; 		exit 1; 	}
	@echo "--- default.nix test complete. Output in default.eval.log ---"


