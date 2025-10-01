.PHONY: all build log-analyzer-build log-analyzer-generate-lockfile

ROOT_DIR := /data/data/com.termux.nix/files/home/pick-up-nix2
LOG_ANALYZER_CRATE_DIR := $(ROOT_DIR)/crates/log_analyzer

all: build

build:
	@echo "Building the log-analysis-pipeline flake..."
	nix build --print-build-logs
	@echo "Nix build completed. Inspecting result..."
	ls -l result
	@echo "Content of analysis-result.txt:"
	cat result/analysis-result.txt

log-analyzer-build:
	@echo "Building the log_analyzer crate..."
	nix build $(ROOT_DIR)#log-analyzer

log-analyzer-generate-lockfile:
	@echo "Generating Cargo.lock for log_analyzer..."
	nix develop $(ROOT_DIR) --command bash -c "cd $(LOG_ANALYZER_CRATE_DIR) && cargo generate-lockfile"