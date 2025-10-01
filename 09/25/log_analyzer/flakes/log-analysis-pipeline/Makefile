# Makefile for Nix-driven DevOps Pipeline

.PHONY: all build-local build-docker deploy-cloudformation deploy-aws-codebuild deploy-aarch-server deploy-laptop deploy-android ci-github-actions build-impure-logs build-nar-logs index-nix-code build-2gram-index generate-2gram-report

FLAKE_DIR := .

all: build-local build-impure-logs build-nar-logs index-nix-code build-2gram-index generate-2gram-report

# ------------------------------------------------------------------------------
# Local Development & Build Targets
# ------------------------------------------------------------------------------

build-local:
	@echo "Building local Nix flake outputs..."
	nix build $(FLAKE_DIR)#default --extra-experimental-features "impure-derivations ca-derivations"

build-impure-logs:
	@echo "Building impure log analysis (reading from host filesystem)..."
	@if [ -z "$(LOG_FILE_PATH)" ]; then \
		echo "Error: LOG_FILE_PATH is not set. Usage: make build-impure-logs LOG_FILE_PATH=/path/to/your/log.log"; \
		exit 1; \
	fi
	nix build $(FLAKE_DIR)#analyzeImpureLogsToStore --argstr logFilePath "$(LOG_FILE_PATH)" --extra-experimental-features "impure-derivations ca-derivations"

build-nar-logs:
	@echo "Building NAR log analysis (fetching from URL)..."
	@if [ -z "$(NAR_URL)" ]; then \
		echo "Error: NAR_URL is not set. Usage: make build-nar-logs NAR_URL=https://example.com/logs.nar NAR_HASH=sha256-..."; \
		exit 1; \
	fi
	@if [ -z "$(NAR_HASH)" ]; then \
		echo "Error: NAR_HASH is not set. Usage: make build-nar-logs NAR_URL=https://example.com/logs.nar NAR_HASH=sha256-..."; \
		exit 1; \
	fi
	nix build $(FLAKE_DIR)#analyzeNarLogsToStore --argstr narUrl "$(NAR_URL)" --argstr narHash "$(NAR_HASH)" --extra-experimental-features "impure-derivations ca-derivations"

build-docker:
	@echo "Building Docker container image with Nix..."
	# Conceptual: Nix expression to build a Docker image
	# nix build $(FLAKE_DIR)#dockerImage
	@echo "To load the image: docker load < result"

index-nix-code: $(shell find $(FLAKE_DIR) -name "*.nix")
	@echo "Indexing Nix code and generating cache module..."
	# Conceptual: Call the indexer and cache generator from the flake
	# This assumes the flake exposes these functions as packages or apps.
	# For now, we'll just build the cache module directly.
	nix build $(FLKE_DIR)#lib.nixCodeIndexer.generateCacheModule --out-link nix-index-cache --extra-experimental-features "impure-derivations ca-derivations"
	@echo "Nix code indexed and cache module generated at nix-index-cache/default.nix"

build-2gram-index:
	@echo "Building the 2-gram index..."
	nix build $(FLAKE_DIR)#build2GramIndex --out-link 2gram-index --extra-experimental-features "impure-derivations ca-derivations"
	@echo "2-gram index built to 2gram-index/nix-2gram-index.json"

generate-2gram-report: build-2gram-index
	@echo "Generating the 2-gram report..."
	nix build $(FLAKE_DIR)#generate2GramReport --out-link 2gram-report --extra-experimental-features "impure-derivations ca-derivations"
	@echo "2-gram report generated to 2gram-report/2gram-report.txt"
	@cat 2gram-report/2gram-report.txt

# ------------------------------------------------------------------------------
# Infrastructure as Code (IaC) & Cloud Deployment Targets
# ------------------------------------------------------------------------------

deploy-cloudformation:
	@echo "Generating CloudFormation from Nix/Terraform and deploying..."
	# Conceptual: Nix expression that generates CloudFormation JSON/YAML
	# nix build $(FLAKE_DIR)#cloudformationTemplate
	# aws cloudformation deploy --template-file result --stack-name my-nix-stack --capabilities CAPABILITY_IAM
	@echo "CloudFormation deployment conceptualized."

deploy-aws-codebuild:
	@echo "Triggering AWS CodeBuild pipeline via Nix..."
	# Conceptual: Nix expression to define/trigger CodeBuild project
	# nix run $(FLAKE_DIR)#codebuildTrigger -- --project-name my-nix-codebuild-project
	@echo "AWS CodeBuild deployment conceptualized."

# ------------------------------------------------------------------------------
# Cross-Platform Deployment Targets
# ------------------------------------------------------------------------------

deploy-aarch-server:
	@echo "Deploying to AArch64 server via NixOS/NixOps..."
	# Conceptual: NixOps deployment or ssh nixos-rebuild
	# nixops deploy -d my-aarch-server $(FLAKE_DIR)#nixosConfigurations.aarchServer
	@echo "AArch64 server deployment conceptualized."

deploy-laptop:
	@echo "Deploying configuration to local laptop (NixOS/home-manager)..."
	# Conceptual: home-manager switch or nixos-rebuild switch
	# nixos-rebuild switch --flake $(FLAKE_DIR)#homeConfigurations.myUser
	@echo "Laptop deployment conceptualized."

deploy-android:
	@echo "Deploying to Nix on Android (Termux/Nix-on-Droid)..."
	# Conceptual: Specific commands for Nix-on-Droid environment
	# nix-on-droid deploy $(FLAKE_DIR)#androidConfigurations.myPhone
	@echo "Android deployment conceptualized."

# ------------------------------------------------------------------------------
# Continuous Integration (CI) Targets
# ------------------------------------------------------------------------------

ci-github-actions:
	@echo "Running GitHub Actions CI locally (conceptual)..."
	# Conceptual: Use act or similar tool to simulate GitHub Actions locally
	# act --container-architecture linux/amd64 -W .github/workflows/main.yml
	@echo "GitHub Actions CI conceptualized."

# ------------------------------------------------------------------------------
# Clean Target
# ------------------------------------------------------------------------------

clean:
	@echo "Cleaning Nix build results..."
	rm -f result
	@echo "Nix build results cleaned."
