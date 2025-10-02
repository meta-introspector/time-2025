.PHONY: debug-nix-eval

debug-nix-eval:
	@echo "Checking for unstaged or uncommitted Nix files..."
	@if git status --porcelain -- "*.nix" | grep -q .; then \
		echo "Error: Unstaged or uncommitted Nix files found. Please commit or stash them before running Nix commands."; \
		exit 1; \
	fi
	@echo "Running nix eval to debug flake issue..."
	nix eval --raw --impure .#devShell.aarch64-linux