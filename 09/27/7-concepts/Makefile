.PHONY: build-telemetry-v3

build-telemetry-v3:
	LLM_API_KEY_FILE="/tmp/llm_api_key.txt" nix build \
		--extra-experimental-features "impure-derivations ca-derivations" \
		./6-qa-testing/tests/2025-01-27-gemini-telemetry-capture-v3#default
