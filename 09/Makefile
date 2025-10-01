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
