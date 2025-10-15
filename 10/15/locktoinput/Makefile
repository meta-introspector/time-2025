NIX_EXPERIMENTAL_FEATURES = "nix-command flakes impure-derivations ca-derivations"

.PHONY: all check run build

all: check run build

check:
	nix flake check . --extra-experimental-features $(NIX_EXPERIMENTAL_FEATURES)

run:
	nix run .#default --extra-experimental-features "$(NIX_EXPERIMENTAL_FEATURES)"

build:
	nix build .#default --extra-experimental-features "$(NIX_EXPERIMENTAL_FEATURES)"

clean:
	rm -f flake.lock
	rm -rf result
