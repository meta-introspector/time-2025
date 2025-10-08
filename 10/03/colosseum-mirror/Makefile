# This is a Makefile, a tool that helps automate tasks like building software.
# It defines a set of "targets" (like 'build', 'clean', 'shell', 'archive-daily')
# and the commands needed to achieve those targets.

# .PHONY declares targets that are not actual files. This prevents Make from
# getting confused if a file with the same name as a target exists.
.PHONY: all build clean shell archive-daily pre-nix-check

# Ensure no unstaged or uncommitted Nix files before running Nix commands.
# This helps maintain purity and prevents accidental builds from dirty working directories.
pre-nix-check:
	@echo "--- Running pre-Nix check: Ensuring no unstaged or uncommitted Nix files ---"
	@if git status --porcelain -- '*.nix' | grep -q .; then \
		echo "ERROR: Unstaged or uncommitted Nix files found. Please commit or stash them before proceeding."; \
		git status --porcelain -- '*.nix'; \
		exit 1; \
	fi
	@echo "--- Pre-Nix check passed. No unstaged or uncommitted Nix files found. ---"

# FLAKE_DIR is a variable that stores the absolute path to the directory
# where this Makefile is located. This makes the Makefile portable,
# so it works no matter where you put it.
# $(dir ...) extracts the directory part of a path.
# $(abspath ...) converts a path to its absolute form.
# $(lastword $(MAKEFILE_LIST)) gets the name of the current Makefile.
FLAKE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# The 'all' target is the default target. If you just type 'make' without
# specifying a target, it will run the 'all' target.
# In this case, 'all' simply depends on 'build', so it will run the 'build' target.
all: build

# The 'build' target is responsible for building our Nix derivation.
# A Nix derivation is like a recipe for creating a software package or a file.
build: pre-nix-check
	# @echo prints a message to the console. The '@' prevents Make from
	# printing the command itself before executing it, making the output cleaner.
	@echo "Building the Colosseum website mirror using Nix..."
	# nix build is the command to build a Nix flake.
	# $(FLAKE_DIR) tells Nix where to find our 'flake.nix' file, which contains
	# the instructions for mirroring the website.
	nix build $(FLAKE_DIR)
	# After a successful build, Nix creates a symbolic link (a shortcut) named 'result'
	# in the current directory. This 'result' link points to the actual mirrored
	# website content stored deep inside the Nix store (a special directory where Nix keeps everything).
	@echo "Mirror built. Access it via the 'result' symlink in $(FLAKE_DIR)"

# The 'clean' target is used to remove temporary files or build artifacts.
clean:
	@echo "Cleaning up build artifacts..."
	# rm -rf is a command to remove files or directories.
	# -r means "recursive" (remove directories and their contents).
	# -f means "force" (don't ask for confirmation).
	# We are removing the 'result' symlink that Nix creates after a build.
	@rm -rf $(FLAKE_DIR)/result
	@echo "Clean up complete."

# The 'shell' target provides a development environment.
# This is super useful because it gives you access to all the tools
# specified in your 'flake.nix' (like 'httrack') without installing them globally.
shell:
	@echo "Entering Nix development shell..."
	# nix develop is the command to enter a development shell defined by a flake.
	# Once inside this shell, you can run 'httrack' directly, even if it's not
	# installed on your main system.
	nix develop $(FLAKE_DIR)

# The 'archive-daily' target automates the process of creating a date-stamped
# archive of the Colosseum website mirror.
archive-daily:
	@echo "Creating daily archive of Colosseum website..."
	# $(MAKE) build tells Make to run the 'build' target first.
	# This ensures the website is mirrored before we try to archive it.
	$(MAKE) build
	# DATE_STR is a shell variable that will store the current date.
	# $(date +%Y-%m-%d) formats the date as YYYY-MM-DD (e.g., 2025-10-03).
	# The '$$' is important here: Make uses '$' for its own variables,
	# so '$$' tells Make to pass a single '$' to the shell command.
	@DATE_STR=$$(date +%Y-%m-%d)
	# DAILY_ARCHIVE_DIR defines the path where our daily archive will be stored.
	# It creates a subdirectory 'archives' inside our FLAKE_DIR, and then
	# another subdirectory named after the current date.
	@DAILY_ARCHIVE_DIR=$(FLAKE_DIR)/archives/$$DATE_STR
	# mkdir -p creates a directory.
	# -p means "parents" (create any necessary parent directories if they don't exist).
	@mkdir -p $$DAILY_ARCHIVE_DIR
	# cp -r copies files and directories.
	# -r means "recursive" (copy directories and their contents).
	# $(FLAKE_DIR)/result/. copies the *contents* of the 'result' symlink
	# (which is our mirrored website) into the DAILY_ARCHIVE_DIR.
	# The trailing '/' on $$DAILY_ARCHIVE_DIR/ ensures that the contents are copied *into* the directory.
	@cp -r $(FLAKE_DIR)/result/. $$DAILY_ARCHIVE_DIR/
	@echo "Daily archive created at $$DAILY_ARCHIVE_DIR"
	# $(MAKE) clean tells Make to run the 'clean' target.
	# This removes the 'result' symlink, leaving only the date-stamped archive.
	$(MAKE) clean
.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 19214(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 19214(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 19214(pwd). Check develop.log for details."; 		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 19214(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

