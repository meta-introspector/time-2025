test:
	nix flake check --extra-experimental-features impure-derivations --extra-experimental-features ca-derivations --show-trace -vv

inspect-indexer-output:
	nix build --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --file inspect_indexer_output.nix

inspect-derivation-output:
	nix build --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --file inspect_derivation_output.nix

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