.PHONY: all test build run clean export-nar inspect-nar publish-nar

all: build

test:
	@echo "Running nix flake check..."
	nix flake check --extra-experimental-features "impure-derivations ca-derivations"
build:
	@echo "Building the buildTimeTelemetry derivation (verbose output in nix_build_output.log)..."
	nix build --print-build-logs --print-out-paths --json  --keep-failed \
	--extra-sandbox-paths  "/creds/google_accounts.json=/data/data/com.termux.nix/files/home/.gemini/google_accounts.json" \
	--extra-sandbox-paths  "/creds/google_accounts.json=/data/data/com.termux.nix/files/home/.gemini/oauth_creds.json" \
	--extra-sandbox-paths  "/creds/google_accounts.json=/data/data/com.termux.nix/files/home/.gemini/settings.json" \
	.#packages.aarch64-linux.default -v --impure --extra-experimental-features "nix-command flakes impure-derivations ca-derivations"
#> nix_build_output.log 2>&1

run: build
	@echo "Build complete. To inspect the telemetry, find the output path of the 'buildTimeTelemetry' derivation and check its 'logs/build-time-capture.log' and 'telemetry/build-time.json' files."

clean:
	@echo "Cleaning up Nix build results..."
	nix store gc --json | jq -r '.[] | select(.references | contains(["/nix/store/$(shell nix-instantiate --eval --json -E 'builtins.storePath (builtins.getFlake "path:.").packages.x86_64-linux.buildTimeTelemetry')"])) | .path' | xargs -r nix store delete
	@echo "Nix garbage collection for this flake's outputs might require manual intervention."
	@echo "Consider 'nix-collect-garbage -d' if you want to aggressively clean up."

export-nar: build
	@echo "Exporting NAR file for buildTimeTelemetry..."
	NIX_STORE_PATH=$$(nix-store --query ./result) && \
	NIX_HASH=$$(basename $$NIX_STORE_PATH) && \
	nix-store --export $$NIX_STORE_PATH > $$NIX_HASH.nar

inspect-nar:
	@echo "Inspecting NAR file: build-time-gemini-telemetry.nar"
	TMP_DIR=$$(mktemp -d) && \
	nix-store --restore-path --hash-type sha256 --sri-path $$(nix-hash --flat --base32 --type sha256 build-time-gemini-telemetry.nar) > $$TMP_DIR/restored_path_file && \
	RESTORED_PATH=$$(cat $$TMP_DIR/restored_path_file) && \
	echo "Restored to: $$RESTORED_PATH" && \
	ls -lR $$RESTORED_PATH && \
	rm -rf $$TMP_DIR

publish-nar: export-nar
	@echo "Publishing NAR file to binstore Git repository..."
	NIX_STORE_PATH=$$(nix-store --query ./result) && \
	NIX_HASH=$$(basename $$NIX_STORE_PATH) && \
	NAR_FILE="$$NIX_HASH.nar" && \
	BINSTORE_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/current-month/22/crq-binstore" && \
	mv $$NAR_FILE $$BINSTORE_PATH$$NAR_FILE && \
	(cd $$BINSTORE_PATH && git add *.nar) && \
	(cd $$BINSTORE_PATH && git commit -m "feat: Add $$NAR_FILE to binstore") && \
	(cd $$BINSTORE_PATH && git push)
