.PHONY: all clean \
        build-build-system test-build-system-devshell \
        build-test-secrets-sops-fail build-test-secrets-sops-pass \
        test-gemini-hello-world build-gemini-build-time-capture \
        build-consolidated-impure-gemini-telemetry \
        build-gemini-integration inspect-gemini-build-telemetry run-gemini-prompt \
        build-streamofrandom-cli build-ai-workflow

# Default target: build all consolidated flakes
all: build-build-system \
     build-test-secrets-sops-pass \
     test-gemini-hello-world \
     build-gemini-build-time-capture \
     build-consolidated-impure-gemini-telemetry \
     build-gemini-integration \
     build-streamofrandom-cli \
     build-ai-workflow

# --- Core Infrastructure & Tooling ---

# Builds the default package of the 1-build-system flake.
# This package provides development tools and pre-commit hooks.
build-build-system:
	nix build ./1-build-system

# Enters the devShell of the 1-build-system flake and runs pre-commit and nixpkgs-fmt version commands.
# This verifies that the development environment provides the expected tools.
test-build-system-devshell:
	nix develop ./1-build-system --command bash -c "pre-commit --version && nixpkgs-fmt --version"

# Builds the default package of the test-secrets-sops flake without setting BUILD_SECRET_HELLO.
# This is expected to fail, demonstrating the secure handling of secrets.
build-test-secrets-sops-fail:
	nix build ./test-secrets-sops --impure --extra-experimental-features impure-derivations

# Builds the default package of the test-secrets-sops flake with a dummy BUILD_SECRET_HELLO.
# This is expected to pass, demonstrating successful (though insecure for real secrets) access.
build-test-secrets-sops-pass:
	BUILD_SECRET_HELLO="my-impure-secret" nix build ./test-secrets-sops --impure --extra-experimental-features impure-derivations

# --- Gemini CLI Interaction & Testing ---

# Builds and runs the primary functional test for the Gemini CLI.
# This verifies basic CLI commands and includes diagnostic checks.
test-gemini-hello-world:
	nix run ./6-qa-testing/tests/2025-01-27-gemini-hello-world

# Builds the build-time Gemini telemetry capture flake.
# This flake demonstrates and tests interaction with the Gemini API during a Nix build.
build-gemini-build-time-capture:
	nix build ./6-qa-testing/tests/2025-01-27-build-time-gemini-capture --impure --extra-experimental-features "impure-derivations ca-derivations"

# Builds the consolidated impure Gemini CLI telemetry and credential testing flake.
# This verifies impure telemetry and credential handling.
build-consolidated-impure-gemini-telemetry:
	nix build ./6-qa-testing/tests/consolidated-impure-gemini-telemetry --impure --extra-experimental-features impure-derivations

# Builds the consolidated Gemini API/CLI integration flake.
# This flake provides a flexible development environment and applications for various interaction methods.
build-gemini-integration:
	nix build ./2-gemini-integration/gemini-integration

# Inspects the telemetry output of the build-time Gemini telemetry capture.
# This target first builds the telemetry flake (if not already built),
# then extracts the output path and displays the captured logs and JSON.
inspect-gemini-build-telemetry: build-gemini-build-time-capture
	@echo "=== Inspecting Build-Time Gemini Telemetry ==="
	@if [ -L result ]; then \
		RESULT_PATH=$$(readlink -f result); \
		echo "Telemetry captured at: $$RESULT_PATH"; \
		echo ""; \
		echo "--- build-time-capture.log ---"; \
		cat "$$RESULT_PATH/logs/build-time-capture.log"; \
		echo ""; \
		echo "--- build-time.json ---"; \
		cat "$$RESULT_PATH/telemetry/build-time.json"; \
	else \
		echo "Error: 'result' symlink not found. Please run 'make build-gemini-build-time-capture' first."; \
	fi

# --- StreamOfRandom CLI Development ---

# Builds the consolidated streamofrandom_cli application.
# This includes all subcommands: today, packet-craft, github-search, and nar-process.
build-streamofrandom-cli:
	nix build ./3-response-artifacts/response-007-cli-nar-output

# --- AI/LLM Workflows ---

# Builds the consolidated AI/LLM workflow flake.
# This flake provides functions and examples for AI/LLM workflows.
build-ai-workflow:
	nix build ./ai-workflow

# --- General Commands ---

# Cleans up Nix build results (symlinks in the current directory).
clean:
	rm -f result result-*
