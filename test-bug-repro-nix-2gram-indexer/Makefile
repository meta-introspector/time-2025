test:
	nix flake check --extra-experimental-features impure-derivations --extra-experimental-features ca-derivations --show-trace -vv

build-dependencies:
	nix build --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --file inspect_indexer_output.nix

inspect-indexer-output: build-dependencies
	# The actual command to inspect the output will go here after the build
	# For now, we just rely on the build-dependencies target to build it.
	# We can then inspect the 'result' symlink manually.

inspect-derivation-output:
	nix build --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --file inspect_derivation_output.nix

build-vibe1:
	nix build --impure --expr '(import (builtins.getFlake ./. )).packages.aarch64-linux.vibe1 { projectRoot = "github:meta-introspector/time-2025?dir=test-bug-repro-nix-2gram-indexer"; }' --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' -o vibe1-output

test-flatten:
	nix --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' eval --raw --file test_flatten.nix

test-step1:
	nix build --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --file tests/test_step1_nix_file_index.nix

test-step2:
	nix --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' eval --raw --file tests/test_step2_indexed_files.nix

test-step3:
	nix --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' eval --raw --file tests/test_step3_all2gram_usages.nix

test-ngram-functions:
	nix --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' eval --raw --file tests/test_n_gram_generator_functions.nix