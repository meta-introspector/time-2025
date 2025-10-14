
.PHONY: all update-all build-all rebuild-all clean

FLAKE_FILES := $(wildcard */flake.nix)
FLAKE_DIRS := $(patsubst %/flake.nix,%,$(FLAKE_FILES))

# Default target
all: build-all

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
