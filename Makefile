.PHONY: all update-all build-all rebuild-all clean

FLAKE_DIRS := $(shell find . -name flake.nix -print0 | xargs -0 -n1 dirname)

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

# Template for individual flake targets
$(FLAKE_DIRS)/update:
	@echo "Updating flake.lock in $(@D)..."
	@cd $(@D) && nix flake update

$(FLAKE_DIRS)/build:
	@echo "Building flake in $(@D)..."
	@cd $(@D) && nix build

$(FLAKE_DIRS)/rebuild:
	@echo "Rebuilding flake in $(@D)..."
	@cd $(@D) && nix build --rebuild

# Specific dependency for 002c_collected_locks_derivation on 001_collect_locks
/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/12/audit-flakes/002c_collected_locks_derivation/build: /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/12/audit-flakes/001_collect_locks/build