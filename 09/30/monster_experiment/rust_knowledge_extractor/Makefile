.PHONY: generate-lockfile generate-cargo-lockfile

generate-lockfile:
	nix develop .#rust-knowledge-extractor --command bash -c "cargo generate-lockfile"

generate-cargo-lockfile:
	nix develop /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/#default --command bash -c "cargo generate-lockfile"

.PHONY: test-creds-build
test-creds-build:
	nix build --extra-experimental-features impure-derivations --extra-experimental-features ca-derivations /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/7-concepts/6-qa-testing/tests/2025-01-27-build-time-gemini-capture/#default
