
.PHONY: all update-all build-all rebuild-all clean

FLAKE_FILES := $(wildcard */flake.nix)
FLAKE_DIRS := $(patsubst %/flake.nix,%,$(FLAKE_FILES))

# Default target
FLAKE_AUDITOR_PATH := /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/14/flake_auditor

all: build-all

# Audit all flake.lock files
audit-all-flakes: $(addsuffix /audit,$(FLAKE_DIRS))

# Generic audit rule
%/audit: %/update
	@echo "Auditing flake.lock in $(@D)..."
	@nix build $(FLAKE_AUDITOR_PATH)#flake-auditor --out-link $(@D)/result-flake-auditor
	@$(@D)/result-flake-auditor $(@D)/flake.lock
	@rm $(@D)/result-flake-auditor

# Update all flake.lock files
update-all: $(addsuffix /update,$(FLAKE_DIRS))

# Update all flake.lock files
update-all: $(addsuffix /update,$(FLAKE_DIRS))

# Build all flakes
build-all: $(addsuffix /build,$(FLAKE_DIRS))

# Rebuild all flakes (force rebuild)
rebuild-all: clean update-all $(addsuffix /rebuild,$(FLAKE_DIRS))

# Clean all flake results
clean:
	@echo "Cleaning all flake results..."
	@find . -depth -name "result" -exec rm -rf {} +
	@find . -depth -name "result-*" -exec rm -rf {} +
	@echo "Clean complete."

# Generic update rule
%/update:
	@echo "Updating flake.lock in $(@D)..."
	@cd $(@D) && nix flake update

# Generic build rule (tries to build default package)
%/build:
	@echo "Building default package for $(@D)..."
	@cd $(@D) && nix build

# Generic rebuild rule
%/rebuild:
	@echo "Rebuilding flake in $(@D)..."
	@cd $(@D) && nix build --rebuild

# Specific build rule for 001_collect_locks
001_collect_locks/build:
	@echo "Building checks.allLockFilePackageNames for 001_collect_locks..."
	@cd 001_collect_locks && nix build .#checks.aarch64-linux.allLockFilePackageNames

# Specific build rule for 002c_collected_locks_derivation
002c_collected_locks_derivation/build: 001_collect_locks/build
	@echo "Building default package for 002c_collected_locks_derivation..."
	@cd 002c_collected_locks_derivation && nix build .#default

# Specific build rule for 003_generate_bow_histogram
003_generate_bow_histogram/build: 001_collect_locks/build
	@echo "Building default package for 003_generate_bow_histogram..."
	@cd 003_generate_bow_histogram && nix build .#default

# New report target
report: 002c_collected_locks_derivation/build
	@echo "Running audit report generation script..."
	@"$(FLAKE_BASE_DIR)/scripts/generate_audit_report.sh"

.PHONY: collect-locks-pickupnix
collect-locks-pickupnix:
	nix build ../001_collect_locks#packages.aarch64-linux.lock-file-0 --override-input project 'github:meta-introspector/pick-up-nix?ref=feature/CRQ-016-nixify' --extra-experimental-features 'nix-command flakes'

.PHONY: collect-locks-streamofrandom
collect-locks-streamofrandom:
	nix build ../001_collect_locks#packages.aarch64-linux.lock-file-0 --override-input project 'github:meta-introspector/streamofrandom?ref=feature/aimyc-003-cultivation' --extra-experimental-features 'nix-command flakes'

.PHONY: get-lock-info-current-project
get-lock-info-current-project:
	@echo "Collecting lock info for current project..."
	@derivation_path=$$(nix build ../001_collect_locks#packages.aarch64-linux.lock-file-0 --extra-experimental-features 'nix-command flakes' --no-link --print-out-paths)
	@output_path=$$(nix-store -q --outputs $$derivation_path)
	@jq -r '.nixFilePath, .lockFilePath' "$$output_path/lock-file-info.json" | paste -sd ',' -

.PHONY: get-lock-info-pickupnix
get-lock-info-pickupnix:
	@echo "Collecting lock info for pickupnix..."
	@derivation_path=$$(nix build ../001_collect_locks#packages.aarch64-linux.lock-file-0 --override-input project 'github:meta-introspector/pick-up-nix?ref=feature/CRQ-016-nixify' --extra-experimental-features 'nix-command flakes' --no-link --print-out-paths)
	@output_path=$$(nix-store -q --outputs $$derivation_path)
	@jq -r '.nixFilePath, .lockFilePath' "$$output_path/lock-file-info.json" | paste -sd ',' -

.PHONY: get-lock-info-streamofrandom
get-lock-info-streamofrandom:
	@echo "Collecting lock info for streamofrandom..."
	@derivation_path=$$(nix build ../001_collect_locks#packages.aarch64-linux.lock-file-0 --override-input project 'github:meta-introspector/streamofrandom?ref=feature/foaf' --extra-experimental-features 'nix-command flakes' --no-link --print-out-paths)
	@output_path=$$(nix-store -q --outputs $$derivation_path)
	@jq -r '.nixFilePath, .lockFilePath' "$$output_path/lock-file-info.json" | paste -sd ',' -

.PHONY: summarize-lock-files
summarize-lock-files:
	@echo "Project,Nix File Path,Lock File Path"
	@echo -n "Current Project," && $(MAKE) get-lock-info-current-project
	@echo -n "pickupnix," && $(MAKE) get-lock-info-pickupnix
	@echo -n "streamofrandom," && $(MAKE) get-lock-info-streamofrandom
