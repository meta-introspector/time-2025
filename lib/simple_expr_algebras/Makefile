include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./lib/simple_expr_algebras"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-size_bvar

test-size_bvar: size_bvar.nix
	@echo "--- Testing size_bvar.nix with nix eval ---"
	@nix eval --raw ./size_bvar.nix > size_bvar.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for size_bvar.nix. Check size_bvar.eval.log for details."
		cat size_bvar.eval.log; 		exit 1; 	}
	@echo "--- size_bvar.nix test complete. Output in size_bvar.eval.log ---"



.PHONY: test-size_sort

test-size_sort: size_sort.nix
	@echo "--- Testing size_sort.nix with nix eval ---"
	@nix eval --raw ./size_sort.nix > size_sort.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for size_sort.nix. Check size_sort.eval.log for details."
		cat size_sort.eval.log; 		exit 1; 	}
	@echo "--- size_sort.nix test complete. Output in size_sort.eval.log ---"



.PHONY: test-size_const

test-size_const: size_const.nix
	@echo "--- Testing size_const.nix with nix eval ---"
	@nix eval --raw ./size_const.nix > size_const.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for size_const.nix. Check size_const.eval.log for details."
		cat size_const.eval.log; 		exit 1; 	}
	@echo "--- size_const.nix test complete. Output in size_const.eval.log ---"



.PHONY: test-size_app

test-size_app: size_app.nix
	@echo "--- Testing size_app.nix with nix eval ---"
	@nix eval --raw ./size_app.nix > size_app.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for size_app.nix. Check size_app.eval.log for details."
		cat size_app.eval.log; 		exit 1; 	}
	@echo "--- size_app.nix test complete. Output in size_app.eval.log ---"



.PHONY: test-size_lam

test-size_lam: size_lam.nix
	@echo "--- Testing size_lam.nix with nix eval ---"
	@nix eval --raw ./size_lam.nix > size_lam.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for size_lam.nix. Check size_lam.eval.log for details."
		cat size_lam.eval.log; 		exit 1; 	}
	@echo "--- size_lam.nix test complete. Output in size_lam.eval.log ---"



.PHONY: test-size_forallE

test-size_forallE: size_forallE.nix
	@echo "--- Testing size_forallE.nix with nix eval ---"
	@nix eval --raw ./size_forallE.nix > size_forallE.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for size_forallE.nix. Check size_forallE.eval.log for details."
		cat size_forallE.eval.log; 		exit 1; 	}
	@echo "--- size_forallE.nix test complete. Output in size_forallE.eval.log ---"



.PHONY: test-size_defaultAttr

test-size_defaultAttr: size_defaultAttr.nix
	@echo "--- Testing size_defaultAttr.nix with nix eval ---"
	@nix eval --raw ./size_defaultAttr.nix > size_defaultAttr.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for size_defaultAttr.nix. Check size_defaultAttr.eval.log for details."
		cat size_defaultAttr.eval.log; 		exit 1; 	}
	@echo "--- size_defaultAttr.nix test complete. Output in size_defaultAttr.eval.log ---"



.PHONY: test-size_defaultList

test-size_defaultList: size_defaultList.nix
	@echo "--- Testing size_defaultList.nix with nix eval ---"
	@nix eval --raw ./size_defaultList.nix > size_defaultList.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for size_defaultList.nix. Check size_defaultList.eval.log for details."
		cat size_defaultList.eval.log; 		exit 1; 	}
	@echo "--- size_defaultList.nix test complete. Output in size_defaultList.eval.log ---"



.PHONY: test-size_default

test-size_default: size_default.nix
	@echo "--- Testing size_default.nix with nix eval ---"
	@nix eval --raw ./size_default.nix > size_default.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for size_default.nix. Check size_default.eval.log for details."
		cat size_default.eval.log; 		exit 1; 	}
	@echo "--- size_default.nix test complete. Output in size_default.eval.log ---"



.PHONY: test-depth_bvar

test-depth_bvar: depth_bvar.nix
	@echo "--- Testing depth_bvar.nix with nix eval ---"
	@nix eval --raw ./depth_bvar.nix > depth_bvar.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for depth_bvar.nix. Check depth_bvar.eval.log for details."
		cat depth_bvar.eval.log; 		exit 1; 	}
	@echo "--- depth_bvar.nix test complete. Output in depth_bvar.eval.log ---"



.PHONY: test-depth_sort

test-depth_sort: depth_sort.nix
	@echo "--- Testing depth_sort.nix with nix eval ---"
	@nix eval --raw ./depth_sort.nix > depth_sort.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for depth_sort.nix. Check depth_sort.eval.log for details."
		cat depth_sort.eval.log; 		exit 1; 	}
	@echo "--- depth_sort.nix test complete. Output in depth_sort.eval.log ---"



.PHONY: test-depth_const

test-depth_const: depth_const.nix
	@echo "--- Testing depth_const.nix with nix eval ---"
	@nix eval --raw ./depth_const.nix > depth_const.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for depth_const.nix. Check depth_const.eval.log for details."
		cat depth_const.eval.log; 		exit 1; 	}
	@echo "--- depth_const.nix test complete. Output in depth_const.eval.log ---"



.PHONY: test-depth_app

test-depth_app: depth_app.nix
	@echo "--- Testing depth_app.nix with nix eval ---"
	@nix eval --raw ./depth_app.nix > depth_app.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for depth_app.nix. Check depth_app.eval.log for details."
		cat depth_app.eval.log; 		exit 1; 	}
	@echo "--- depth_app.nix test complete. Output in depth_app.eval.log ---"



.PHONY: test-depth_lam

test-depth_lam: depth_lam.nix
	@echo "--- Testing depth_lam.nix with nix eval ---"
	@nix eval --raw ./depth_lam.nix > depth_lam.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for depth_lam.nix. Check depth_lam.eval.log for details."
		cat depth_lam.eval.log; 		exit 1; 	}
	@echo "--- depth_lam.nix test complete. Output in depth_lam.eval.log ---"



.PHONY: test-depth_forallE

test-depth_forallE: depth_forallE.nix
	@echo "--- Testing depth_forallE.nix with nix eval ---"
	@nix eval --raw ./depth_forallE.nix > depth_forallE.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for depth_forallE.nix. Check depth_forallE.eval.log for details."
		cat depth_forallE.eval.log; 		exit 1; 	}
	@echo "--- depth_forallE.nix test complete. Output in depth_forallE.eval.log ---"



.PHONY: test-depth_defaultAttr

test-depth_defaultAttr: depth_defaultAttr.nix
	@echo "--- Testing depth_defaultAttr.nix with nix eval ---"
	@nix eval --raw ./depth_defaultAttr.nix > depth_defaultAttr.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for depth_defaultAttr.nix. Check depth_defaultAttr.eval.log for details."
		cat depth_defaultAttr.eval.log; 		exit 1; 	}
	@echo "--- depth_defaultAttr.nix test complete. Output in depth_defaultAttr.eval.log ---"



.PHONY: test-depth_defaultList

test-depth_defaultList: depth_defaultList.nix
	@echo "--- Testing depth_defaultList.nix with nix eval ---"
	@nix eval --raw ./depth_defaultList.nix > depth_defaultList.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for depth_defaultList.nix. Check depth_defaultList.eval.log for details."
		cat depth_defaultList.eval.log; 		exit 1; 	}
	@echo "--- depth_defaultList.nix test complete. Output in depth_defaultList.eval.log ---"



.PHONY: test-depth_default

test-depth_default: depth_default.nix
	@echo "--- Testing depth_default.nix with nix eval ---"
	@nix eval --raw ./depth_default.nix > depth_default.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for depth_default.nix. Check depth_default.eval.log for details."
		cat depth_default.eval.log; 		exit 1; 	}
	@echo "--- depth_default.nix test complete. Output in depth_default.eval.log ---"


