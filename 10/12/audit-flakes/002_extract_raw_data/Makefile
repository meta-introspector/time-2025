.PHONY: all raw-lock-data extracted-data test clean inspect

all: test

raw-lock-data:
	@echo "Building raw lock data check..."
	nix build .#checks.rawLockData --no-link
	@echo "Raw lock data check built. Output in ./result-raw-lock-data"
	@echo "To inspect: ls -l ./result-raw-lock-data"

extracted-data:
	@echo "Building extracted data check..."
	nix build .#checks.extractedData --no-link
	@echo "Extracted data check built. Output in ./result-extracted-data"
	@echo "To inspect: cat ./result-extracted-data/extracted-data.json | jq ."

test: raw-lock-data extracted-data
	@echo "All checks passed."

inspect:
	@echo "To inspect raw lock data: ls -l ./result-raw-lock-data"
	@echo "To inspect extracted data: cat ./result-extracted-data/extracted-data.json | jq ."

clean:
	@echo "Cleaning up results..."
	rm -rf result*