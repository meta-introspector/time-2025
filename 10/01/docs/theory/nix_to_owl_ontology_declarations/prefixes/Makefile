include ../../../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/01/docs/theory/nix_to_owl_ontology_declarations/prefixes"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-nixOntologyPrefix

test-nixOntologyPrefix: nixOntologyPrefix.nix
	@echo "--- Testing nixOntologyPrefix.nix with nix eval ---"
	@nix eval --raw ./nixOntologyPrefix.nix > nixOntologyPrefix.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nixOntologyPrefix.nix. Check nixOntologyPrefix.eval.log for details."
		cat nixOntologyPrefix.eval.log; 		exit 1; 	}
	@echo "--- nixOntologyPrefix.nix test complete. Output in nixOntologyPrefix.eval.log ---"



.PHONY: test-owlPrefix

test-owlPrefix: owlPrefix.nix
	@echo "--- Testing owlPrefix.nix with nix eval ---"
	@nix eval --raw ./owlPrefix.nix > owlPrefix.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for owlPrefix.nix. Check owlPrefix.eval.log for details."
		cat owlPrefix.eval.log; 		exit 1; 	}
	@echo "--- owlPrefix.nix test complete. Output in owlPrefix.eval.log ---"



.PHONY: test-rdfPrefix

test-rdfPrefix: rdfPrefix.nix
	@echo "--- Testing rdfPrefix.nix with nix eval ---"
	@nix eval --raw ./rdfPrefix.nix > rdfPrefix.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for rdfPrefix.nix. Check rdfPrefix.eval.log for details."
		cat rdfPrefix.eval.log; 		exit 1; 	}
	@echo "--- rdfPrefix.nix test complete. Output in rdfPrefix.eval.log ---"



.PHONY: test-rdfsPrefix

test-rdfsPrefix: rdfsPrefix.nix
	@echo "--- Testing rdfsPrefix.nix with nix eval ---"
	@nix eval --raw ./rdfsPrefix.nix > rdfsPrefix.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for rdfsPrefix.nix. Check rdfsPrefix.eval.log for details."
		cat rdfsPrefix.eval.log; 		exit 1; 	}
	@echo "--- rdfsPrefix.nix test complete. Output in rdfsPrefix.eval.log ---"



.PHONY: test-xsdPrefix

test-xsdPrefix: xsdPrefix.nix
	@echo "--- Testing xsdPrefix.nix with nix eval ---"
	@nix eval --raw ./xsdPrefix.nix > xsdPrefix.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for xsdPrefix.nix. Check xsdPrefix.eval.log for details."
		cat xsdPrefix.eval.log; 		exit 1; 	}
	@echo "--- xsdPrefix.nix test complete. Output in xsdPrefix.eval.log ---"


