include ../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/30/monster_experiment/rust_knowledge_extractor"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: generate-lockfile generate-cargo-lockfile

generate-lockfile:
	nix develop .#rust-knowledge-extractor --command bash -c "cargo generate-lockfile"

generate-cargo-lockfile:
	nix develop /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/#default --command bash -c "cargo generate-lockfile"

.PHONY: test-creds-build
test-creds-build:
	nix build --extra-experimental-features impure-derivations --extra-experimental-features ca-derivations /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/7-concepts/6-qa-testing/tests/2025-01-27-build-time-gemini-capture/#default

.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.


.PHONY: test-flake

test-flake: flake.nix
	@echo "--- Testing flake.nix with nix eval ---"
	@nix eval --raw ./flake.nix > flake.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for flake.nix. Check flake.eval.log for details."
		cat flake.eval.log; 		exit 1; 	}
	@echo "--- flake.nix test complete. Output in flake.eval.log ---"



.PHONY: test-secrets

test-secrets: secrets.nix
	@echo "--- Testing secrets.nix with nix eval ---"
	@nix eval --raw ./secrets.nix > secrets.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for secrets.nix. Check secrets.eval.log for details."
		cat secrets.eval.log; 		exit 1; 	}
	@echo "--- secrets.nix test complete. Output in secrets.eval.log ---"


