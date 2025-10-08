include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09"))')/nix_eval_module.mk


include /nix_eval_module.mk


DEFAULT_OWNERS = jmikedupont2,meta-introspector,h4ck3rm1k3

.PHONY: search-crq-sops init-flake update-flake-lock nar-day-content nar-all-days clean-nars gh-search-to-nar archive-repos-to-nar archive-named-repos generate-foaf-jsonld grow-seed

search-crq-sops:
	@echo "Searching for 'crq standard sop' in meta-introspector organization..."
	gh search code "crq standard sop" --org meta-introspector

# Target to initialize a new flake in a specified directory
# Usage: make init-flake DIR=my-new-flake-dir
init-flake:
	@if [ -z "$(DIR)" ]; then \
		echo "Error: DIR is not set. Usage: make init-flake DIR=my-new-flake-dir"; \
		exit 1; \
	fi
	@echo "Initializing new flake in $(DIR)..."
	mkdir -p $(DIR)
	cd $(DIR) && nix flake init

# Target to update the flake.lock file in the current directory
update-flake-lock:
	@echo "Updating flake.lock..."
	nix flake update

# Target to create a Nix Archive (NAR) of a specific day's content from the flake
# Usage: make nar-day-content DAY=15
nar-day-content:
	@if [ -z "$(DAY)" ]; then \
		echo "Error: DAY is not set. Usage: make nar-day-content DAY=15"; \
		exit 1; \
	fi
	@echo "Building flake output for day $(DAY) and creating NAR..."
	nix build .#dailyContent.day-$(DAY) --out-link result-day-$(DAY)
	nix-store --dump $(shell readlink result-day-$(DAY)) > day-$(DAY)-content.nar
	rm result-day-$(DAY)
	@echo "Nix Archive day-$(DAY)-content.nar created."
	@echo "day-$(DAY)-content.nar" >> generated_nars.txt

# List of existing day directories
DAYS = 15 18 19 22 23 24 25 26 27 28 30

# Target to create NARs for all existing day directories
nar-all-days:
	@echo "Creating NARs for all existing day directories..."
	@rm -f generated_nars.txt # Clear previous tracking file
	@for day in $(DAYS); do \
		$(MAKE) nar-day-content DAY=$$day; \
		done
	@echo "All day NARs created."
	@echo "List of generated NARs in generated_nars.txt"

# Target to clean up generated NAR files and the tracking file
clean-nars:
	@echo "Cleaning up generated NAR files..."
	@if [ -f generated_nars.txt ]; then \
		for nar_file in $$(cat generated_nars.txt); do \
			rm -f $$nar_file; \
			done; \
		rm -f generated_nars.txt; \
	else \
		echo "No generated_nars.txt found. Skipping cleanup."; \
	fi
	@echo "Cleanup complete."

# Target to run gh search and package results into a NAR
# Usage: make gh-search-to-nar QUERY="nix flake update" NAR_NAME="nix-flake-update-search"
gh-search-to-nar:
	@if [ -z "$(QUERY)" ]; then \
		echo "Error: QUERY is not set. Usage: make gh-search-to-nar QUERY=\"your search query\""; \
		exit 1; \
	fi
	@if [ -z "$(NAR_NAME)" ]; then \
		echo "Error: NAR_NAME is not set. Usage: make gh-search-to-nar NAR_NAME=\"your-nar-name\""; \
		exit 1; \
	fi
	@echo "Running gh search for \"$(QUERY)\" and packaging results into $(NAR_NAME).nar..."
	@TEMP_DIR=$$(mktemp -d -t gh-search-nar-XXXXXX)
	@echo "Temporary directory: $$TEMP_DIR"
gh search code "$(QUERY)" --owner meta-introspector --json path,repository,text > "$$TEMP_DIR/search_results.json"
	@echo "Search results saved to $$TEMP_DIR/search_results.json"
	# Optionally, create dummy files with snippets for easier browsing within the NAR
	@jq -r '.[] | .path + " " + .repository.name + " " + .text' "$$TEMP_DIR/search_results.json" | while read -r file_path repo_name snippet; do \
		mkdir -p "$$TEMP_DIR/$(repo_name)/$$(dirname "$$file_path")"; \
		echo "$$snippet" > "$$TEMP_DIR/$(repo_name)/$$file_path.snippet"; \
		done
	nix-store --dump "$$TEMP_DIR" > "$(NAR_NAME).nar"
	rm -rf "$$TEMP_DIR"
	@echo "Nix Archive $(NAR_NAME).nar created from search results."

# Target to archive repositories from specified owners into NARs
# Usage: make archive-repos-to-nar (uses DEFAULT_OWNERS)
archive-repos-to-nar:
	@echo "Archiving repositories for owners: $(DEFAULT_OWNERS) into NARs..."
	@OLDIFS=$$IFS; IFS=,; \
	for owner in $(DEFAULT_OWNERS); do \
		echo "Listing repositories for owner: $$owner..."; \
		gh repo list $$owner --json name,url --limit 100 | jq -c '.[]' | while read -r repo_json; do \
			repo_name=$$(echo $$repo_json | jq -r '.name'); \
			repo_url=$$(echo $$repo_json | jq -r '.url'); \
			repo_description=$$(echo $$repo_json | jq -r '.description'); \
			echo "Processing repository: $$repo_name (URL: $$repo_url)"; \
			NIX_PREFETCH_OUTPUT=$$(nix-prefetch-git --url $$repo_url --rev HEAD --quiet); \
			STORE_PATH=$$(echo $$NIX_PREFETCH_OUTPUT | grep 'path is' | awk '{print $$3}'); \
			if [ -z "$$STORE_PATH" ]; then \
				echo "Warning: Could not determine store path for $$repo_name. Skipping NAR creation."; \
				continue; \
			fi; \
			NAR_FILE="$$(echo $$repo_name | tr '/' '-')".nar; \
			echo "Creating NAR for $$repo_name at $$STORE_PATH -> $$NAR_FILE"; \
			nix-store --dump $$STORE_PATH > $$NAR_FILE; \
			echo "NAR created: $$NAR_FILE"; \
			done; \
		done; \
	IFS=$$OLDIFS
	@echo "All specified repositories archived as NARs."

# Target to archive specific named repositories into NARs
# This uses the archive-repos-to-nar target with predefined owners.
archive-named-repos:
	@echo "Archiving repositories for jmikedupont2, meta-introspector, and h4ck3rm1k3..."
	$(MAKE) archive-repos-to-nar
	@echo "Archiving of named repositories complete."

# Target to generate FOAF JSON-LD data for repositories from specified owners
# Usage: make generate-foaf-jsonld (uses DEFAULT_OWNERS)
generate-foaf-jsonld:
	@echo "Generating FOAF JSON-LD for repositories of owners: $(DEFAULT_OWNERS)..."
	@OLDIFS=$$IFS; IFS=,; \
		echo '{ "@context": "http://xmlns.com/foaf/0.1/", "@graph": [] }' > foaf.jsonld; \
	for owner in $(DEFAULT_OWNERS); do \
		echo "Processing owner: $$owner..."; \
		jq --arg owner "$$owner" '.@graph += [{ "@id": "http://github.com/" + $$owner, "@type": "Agent", "name": $$owner, "homepage": { "@id": "http://github.com/" + $$owner } }]' foaf.jsonld > foaf.jsonld.tmp && mv foaf.jsonld.tmp foaf.jsonld; \
		gh repo list $$owner --json name,url,description --limit 100 | jq -c '.[]' | while read -r repo_json; do \
			repo_name=$$(echo $$repo_json | jq -r '.name'); \
			repo_url=$$(echo $$repo_json | jq -r '.url'); \
			repo_description=$$(echo $$repo_json | jq -r '.description'); \
			echo "Adding repository: $$repo_name (URL: $$repo_url)"; \
			jq --arg repo_name "$$repo_name" \
			   --arg repo_url "$$repo_url" \
			   --arg repo_description "$$repo_description" \
			   --arg owner_id "http://github.com/$$owner" \
			   '.@graph += [{ \
			     "@id": $$repo_url, \
			     "@type": "Project", \
			     "name": $$repo_name, \
			     "homepage": { "@id": $$repo_url }, \
			     "description": $$repo_description, \
			     "maker": { "@id": $$owner_id } \
			   }]' foaf.jsonld > foaf.jsonld.tmp && mv foaf.jsonld.tmp foaf.jsonld; \
			done; \
		done; \
	IFS=$$OLDIFS
	@echo "FOAF JSON-LD data generated in foaf.jsonld."

# Target to grow the seed: update FOAF data and create a project snapshot...
grow-seed:
	@echo "Growing the seed: updating FOAF data and creating a project snapshot..."
	# Step 1: Update FOAF data (captures new repos)
	$(MAKE) generate-foaf-jsonld
	# Step 2: Create a NAR of the current streamofrandom/2025/09 directory
	@DATE_STR=$$(date +%Y-%m-%d); \
	echo "Creating project snapshot NAR for today ($$DATE_STR)..."; \
	nix-store --dump . > "streamofrandom-2025-09-snapshot-$$DATE_STR.nar"; \
	echo "Project snapshot NAR streamofrandom-2025-09-snapshot-$$DATE_STR.nar created."
	@echo "Seed grown successfully."

# Target to locate a local file given its GitHub URL
# Usage: make url2file-locate GITHUB_URL="https://github.com/owner/repo/blob/branch/path/to/file"
url2file-locate:
	@mkdir -p scripts # Ensure scripts directory exists
	@chmod +x scripts/url2file_locator.sh # Ensure script is executable
	@scripts/url2file_locator.sh "$(GITHUB_URL)"

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



.PHONY: test-github.owl

test-github.owl: github.owl.nix
	@echo "--- Testing github.owl.nix with nix eval ---"
	@nix eval --raw ./github.owl.nix > github.owl.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github.owl.nix. Check github.owl.eval.log for details."
		cat github.owl.eval.log; 		exit 1; 	}
	@echo "--- github.owl.nix test complete. Output in github.owl.eval.log ---"



.PHONY: test-foaf

test-foaf: foaf.nix
	@echo "--- Testing foaf.nix with nix eval ---"
	@nix eval --raw ./foaf.nix > foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for foaf.nix. Check foaf.eval.log for details."
		cat foaf.eval.log; 		exit 1; 	}
	@echo "--- foaf.nix test complete. Output in foaf.eval.log ---"



.PHONY: test-seed.foaf

test-seed.foaf: seed.foaf.nix
	@echo "--- Testing seed.foaf.nix with nix eval ---"
	@nix eval --raw ./seed.foaf.nix > seed.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for seed.foaf.nix. Check seed.foaf.eval.log for details."
		cat seed.foaf.eval.log; 		exit 1; 	}
	@echo "--- seed.foaf.nix test complete. Output in seed.foaf.eval.log ---"



.PHONY: test-crq-001.foaf

test-crq-001.foaf: crq-001.foaf.nix
	@echo "--- Testing crq-001.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-001.foaf.nix > crq-001.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-001.foaf.nix. Check crq-001.foaf.eval.log for details."
		cat crq-001.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-001.foaf.nix test complete. Output in crq-001.foaf.eval.log ---"



.PHONY: test-crq-007.foaf

test-crq-007.foaf: crq-007.foaf.nix
	@echo "--- Testing crq-007.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-007.foaf.nix > crq-007.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-007.foaf.nix. Check crq-007.foaf.eval.log for details."
		cat crq-007.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-007.foaf.nix test complete. Output in crq-007.foaf.eval.log ---"



.PHONY: test-crq-008.foaf

test-crq-008.foaf: crq-008.foaf.nix
	@echo "--- Testing crq-008.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-008.foaf.nix > crq-008.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-008.foaf.nix. Check crq-008.foaf.eval.log for details."
		cat crq-008.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-008.foaf.nix test complete. Output in crq-008.foaf.eval.log ---"



.PHONY: test-crq-009.foaf

test-crq-009.foaf: crq-009.foaf.nix
	@echo "--- Testing crq-009.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-009.foaf.nix > crq-009.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-009.foaf.nix. Check crq-009.foaf.eval.log for details."
		cat crq-009.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-009.foaf.nix test complete. Output in crq-009.foaf.eval.log ---"



.PHONY: test-crq-010.foaf

test-crq-010.foaf: crq-010.foaf.nix
	@echo "--- Testing crq-010.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-010.foaf.nix > crq-010.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-010.foaf.nix. Check crq-010.foaf.eval.log for details."
		cat crq-010.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-010.foaf.nix test complete. Output in crq-010.foaf.eval.log ---"



.PHONY: test-crq-011.foaf

test-crq-011.foaf: crq-011.foaf.nix
	@echo "--- Testing crq-011.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-011.foaf.nix > crq-011.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-011.foaf.nix. Check crq-011.foaf.eval.log for details."
		cat crq-011.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-011.foaf.nix test complete. Output in crq-011.foaf.eval.log ---"



.PHONY: test-crq-012.foaf

test-crq-012.foaf: crq-012.foaf.nix
	@echo "--- Testing crq-012.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-012.foaf.nix > crq-012.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-012.foaf.nix. Check crq-012.foaf.eval.log for details."
		cat crq-012.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-012.foaf.nix test complete. Output in crq-012.foaf.eval.log ---"



.PHONY: test-crq-013.foaf

test-crq-013.foaf: crq-013.foaf.nix
	@echo "--- Testing crq-013.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-013.foaf.nix > crq-013.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-013.foaf.nix. Check crq-013.foaf.eval.log for details."
		cat crq-013.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-013.foaf.nix test complete. Output in crq-013.foaf.eval.log ---"



.PHONY: test-crqs.foaf

test-crqs.foaf: crqs.foaf.nix
	@echo "--- Testing crqs.foaf.nix with nix eval ---"
	@nix eval --raw ./crqs.foaf.nix > crqs.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crqs.foaf.nix. Check crqs.foaf.eval.log for details."
		cat crqs.foaf.eval.log; 		exit 1; 	}
	@echo "--- crqs.foaf.nix test complete. Output in crqs.foaf.eval.log ---"



.PHONY: test-owl

test-owl: owl.nix
	@echo "--- Testing owl.nix with nix eval ---"
	@nix eval --raw ./owl.nix > owl.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for owl.nix. Check owl.eval.log for details."
		cat owl.eval.log; 		exit 1; 	}
	@echo "--- owl.nix test complete. Output in owl.eval.log ---"



.PHONY: test-verify-foaf-owl

test-verify-foaf-owl: verify-foaf-owl.nix
	@echo "--- Testing verify-foaf-owl.nix with nix eval ---"
	@nix eval --raw ./verify-foaf-owl.nix > verify-foaf-owl.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for verify-foaf-owl.nix. Check verify-foaf-owl.eval.log for details."
		cat verify-foaf-owl.eval.log; 		exit 1; 	}
	@echo "--- verify-foaf-owl.nix test complete. Output in verify-foaf-owl.eval.log ---"



.PHONY: test-cwm

test-cwm: cwm.nix
	@echo "--- Testing cwm.nix with nix eval ---"
	@nix eval --raw ./cwm.nix > cwm.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for cwm.nix. Check cwm.eval.log for details."
		cat cwm.eval.log; 		exit 1; 	}
	@echo "--- cwm.nix test complete. Output in cwm.eval.log ---"



.PHONY: test-eval-cwm

test-eval-cwm: eval-cwm.nix
	@echo "--- Testing eval-cwm.nix with nix eval ---"
	@nix eval --raw ./eval-cwm.nix > eval-cwm.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for eval-cwm.nix. Check eval-cwm.eval.log for details."
		cat eval-cwm.eval.log; 		exit 1; 	}
	@echo "--- eval-cwm.nix test complete. Output in eval-cwm.eval.log ---"



.PHONY: test-test

test-test: test.nix
	@echo "--- Testing test.nix with nix eval ---"
	@nix eval --raw ./test.nix > test.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for test.nix. Check test.eval.log for details."
		cat test.eval.log; 		exit 1; 	}
	@echo "--- test.nix test complete. Output in test.eval.log ---"



.PHONY: test-batch-modify-crqs

test-batch-modify-crqs: batch-modify-crqs.nix
	@echo "--- Testing batch-modify-crqs.nix with nix eval ---"
	@nix eval --raw ./batch-modify-crqs.nix > batch-modify-crqs.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for batch-modify-crqs.nix. Check batch-modify-crqs.eval.log for details."
		cat batch-modify-crqs.eval.log; 		exit 1; 	}
	@echo "--- batch-modify-crqs.nix test complete. Output in batch-modify-crqs.eval.log ---"



.PHONY: test-fetch-github-data

test-fetch-github-data: fetch-github-data.nix
	@echo "--- Testing fetch-github-data.nix with nix eval ---"
	@nix eval --raw ./fetch-github-data.nix > fetch-github-data.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for fetch-github-data.nix. Check fetch-github-data.eval.log for details."
		cat fetch-github-data.eval.log; 		exit 1; 	}
	@echo "--- fetch-github-data.nix test complete. Output in fetch-github-data.eval.log ---"



.PHONY: test-github-to-foaf

test-github-to-foaf: github-to-foaf.nix
	@echo "--- Testing github-to-foaf.nix with nix eval ---"
	@nix eval --raw ./github-to-foaf.nix > github-to-foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github-to-foaf.nix. Check github-to-foaf.eval.log for details."
		cat github-to-foaf.eval.log; 		exit 1; 	}
	@echo "--- github-to-foaf.nix test complete. Output in github-to-foaf.eval.log ---"



.PHONY: test-github.foaf

test-github.foaf: github.foaf.nix
	@echo "--- Testing github.foaf.nix with nix eval ---"
	@nix eval --raw ./github.foaf.nix > github.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github.foaf.nix. Check github.foaf.eval.log for details."
		cat github.foaf.eval.log; 		exit 1; 	}
	@echo "--- github.foaf.nix test complete. Output in github.foaf.eval.log ---"



.PHONY: test-nixify-resource

test-nixify-resource: nixify-resource.nix
	@echo "--- Testing nixify-resource.nix with nix eval ---"
	@nix eval --raw ./nixify-resource.nix > nixify-resource.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nixify-resource.nix. Check nixify-resource.eval.log for details."
		cat nixify-resource.eval.log; 		exit 1; 	}
	@echo "--- nixify-resource.nix test complete. Output in nixify-resource.eval.log ---"



.PHONY: test-hello_world

test-hello_world: hello_world.nix
	@echo "--- Testing hello_world.nix with nix eval ---"
	@nix eval --raw ./hello_world.nix > hello_world.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for hello_world.nix. Check hello_world.eval.log for details."
		cat hello_world.eval.log; 		exit 1; 	}
	@echo "--- hello_world.nix test complete. Output in hello_world.eval.log ---"



.PHONY: test-temp_step2_eval

test-temp_step2_eval: temp_step2_eval.nix
	@echo "--- Testing temp_step2_eval.nix with nix eval ---"
	@nix eval --raw ./temp_step2_eval.nix > temp_step2_eval.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for temp_step2_eval.nix. Check temp_step2_eval.eval.log for details."
		cat temp_step2_eval.eval.log; 		exit 1; 	}
	@echo "--- temp_step2_eval.nix test complete. Output in temp_step2_eval.eval.log ---"



.PHONY: test-bug_repro

test-bug_repro: bug_repro.nix
	@echo "--- Testing bug_repro.nix with nix eval ---"
	@nix eval --raw ./bug_repro.nix > bug_repro.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for bug_repro.nix. Check bug_repro.eval.log for details."
		cat bug_repro.eval.log; 		exit 1; 	}
	@echo "--- bug_repro.nix test complete. Output in bug_repro.eval.log ---"



.PHONY: test-crq-041.foaf

test-crq-041.foaf: crq-041.foaf.nix
	@echo "--- Testing crq-041.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-041.foaf.nix > crq-041.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-041.foaf.nix. Check crq-041.foaf.eval.log for details."
		cat crq-041.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-041.foaf.nix test complete. Output in crq-041.foaf.eval.log ---"



.PHONY: test-poems

test-poems: poems.nix
	@echo "--- Testing poems.nix with nix eval ---"
	@nix eval --raw ./poems.nix > poems.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for poems.nix. Check poems.eval.log for details."
		cat poems.eval.log; 		exit 1; 	}
	@echo "--- poems.nix test complete. Output in poems.eval.log ---"



.PHONY: test-uncommitted

test-uncommitted: uncommitted.nix
	@echo "--- Testing uncommitted.nix with nix eval ---"
	@nix eval --raw ./uncommitted.nix > uncommitted.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for uncommitted.nix. Check uncommitted.eval.log for details."
		cat uncommitted.eval.log; 		exit 1; 	}
	@echo "--- uncommitted.nix test complete. Output in uncommitted.eval.log ---"



.PHONY: test-foaf_core_classes

test-foaf_core_classes: foaf_core_classes.nix
	@echo "--- Testing foaf_core_classes.nix with nix eval ---"
	@nix eval --raw ./foaf_core_classes.nix > foaf_core_classes.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for foaf_core_classes.nix. Check foaf_core_classes.eval.log for details."
		cat foaf_core_classes.eval.log; 		exit 1; 	}
	@echo "--- foaf_core_classes.nix test complete. Output in foaf_core_classes.eval.log ---"



.PHONY: test-schema_core_classes

test-schema_core_classes: schema_core_classes.nix
	@echo "--- Testing schema_core_classes.nix with nix eval ---"
	@nix eval --raw ./schema_core_classes.nix > schema_core_classes.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for schema_core_classes.nix. Check schema_core_classes.eval.log for details."
		cat schema_core_classes.eval.log; 		exit 1; 	}
	@echo "--- schema_core_classes.nix test complete. Output in schema_core_classes.eval.log ---"



.PHONY: test-dcterms_core_classes

test-dcterms_core_classes: dcterms_core_classes.nix
	@echo "--- Testing dcterms_core_classes.nix with nix eval ---"
	@nix eval --raw ./dcterms_core_classes.nix > dcterms_core_classes.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for dcterms_core_classes.nix. Check dcterms_core_classes.eval.log for details."
		cat dcterms_core_classes.eval.log; 		exit 1; 	}
	@echo "--- dcterms_core_classes.nix test complete. Output in dcterms_core_classes.eval.log ---"



.PHONY: test-foaf_core_properties

test-foaf_core_properties: foaf_core_properties.nix
	@echo "--- Testing foaf_core_properties.nix with nix eval ---"
	@nix eval --raw ./foaf_core_properties.nix > foaf_core_properties.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for foaf_core_properties.nix. Check foaf_core_properties.eval.log for details."
		cat foaf_core_properties.eval.log; 		exit 1; 	}
	@echo "--- foaf_core_properties.nix test complete. Output in foaf_core_properties.eval.log ---"



.PHONY: test-dcterms_core_properties

test-dcterms_core_properties: dcterms_core_properties.nix
	@echo "--- Testing dcterms_core_properties.nix with nix eval ---"
	@nix eval --raw ./dcterms_core_properties.nix > dcterms_core_properties.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for dcterms_core_properties.nix. Check dcterms_core_properties.eval.log for details."
		cat dcterms_core_properties.eval.log; 		exit 1; 	}
	@echo "--- dcterms_core_properties.nix test complete. Output in dcterms_core_properties.eval.log ---"



.PHONY: test-schema_core_properties

test-schema_core_properties: schema_core_properties.nix
	@echo "--- Testing schema_core_properties.nix with nix eval ---"
	@nix eval --raw ./schema_core_properties.nix > schema_core_properties.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for schema_core_properties.nix. Check schema_core_properties.eval.log for details."
		cat schema_core_properties.eval.log; 		exit 1; 	}
	@echo "--- schema_core_properties.nix test complete. Output in schema_core_properties.eval.log ---"



.PHONY: test-crq-042.foaf

test-crq-042.foaf: crq-042.foaf.nix
	@echo "--- Testing crq-042.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-042.foaf.nix > crq-042.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-042.foaf.nix. Check crq-042.foaf.eval.log for details."
		cat crq-042.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-042.foaf.nix test complete. Output in crq-042.foaf.eval.log ---"



.PHONY: test-crq-043.foaf

test-crq-043.foaf: crq-043.foaf.nix
	@echo "--- Testing crq-043.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-043.foaf.nix > crq-043.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-043.foaf.nix. Check crq-043.foaf.eval.log for details."
		cat crq-043.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-043.foaf.nix test complete. Output in crq-043.foaf.eval.log ---"



.PHONY: test-crq-044.foaf

test-crq-044.foaf: crq-044.foaf.nix
	@echo "--- Testing crq-044.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-044.foaf.nix > crq-044.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-044.foaf.nix. Check crq-044.foaf.eval.log for details."
		cat crq-044.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-044.foaf.nix test complete. Output in crq-044.foaf.eval.log ---"



.PHONY: test-crq-045.foaf

test-crq-045.foaf: crq-045.foaf.nix
	@echo "--- Testing crq-045.foaf.nix with nix eval ---"
	@nix eval --raw ./crq-045.foaf.nix > crq-045.foaf.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for crq-045.foaf.nix. Check crq-045.foaf.eval.log for details."
		cat crq-045.foaf.eval.log; 		exit 1; 	}
	@echo "--- crq-045.foaf.nix test complete. Output in crq-045.foaf.eval.log ---"


