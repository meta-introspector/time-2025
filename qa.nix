let
  # Import QA helper functions
  qa-helpers = import ./lib/qa-helpers.nix { inherit pkgs lib; };

  # Define common tools
  shellcheck = pkgs.shellcheck;
  pre-commit = pkgs.pre-commit;
  git = pkgs.git;
  nixpkgs-fmt = pkgs.nixpkgs-fmt;
  statix = pkgs.statix;
  # The entire project source for checks that need it
  projectSrc = self;

  # Import the dynamically generated project.nix
  projectNix = import ./project.nix { inherit pkgs; };

  # Collect all .nix file paths from the projectNix attribute set
  allProjectNixFiles = qa-helpers.collectNixFilesFromAttrset projectNix;

  # Function to find all files named uncommitted.nix recursively
  findUncommittedNixFiles = dir:
    let
      entries = builtins.readDir dir;
      files = pkgs.lib.attrsets.mapAttrsToList (name: type:
        if type == "regular" && name == "uncommitted.nix" then
          [ (dir + "/" + name) ]
        else
          []
      ) entries;
      dirs = pkgs.lib.attrsets.mapAttrsToList (name: type:
        if type == "directory" then
          findUncommittedNixFiles (dir + "/" + name)
        else
          []
      ) entries;
    in
    pkgs.lib.lists.flatten (files ++ dirs);

  # Find all uncommitted.nix files in the project source
  uncommittedNixFiles = findUncommittedNixFiles projectSrc;

  # Import all uncommitted.nix files and merge their uncommittedFiles lists
  allUncommittedFiles = pkgs.lib.lists.flatten (pkgs.lib.lists.map (file: (import file).uncommittedFiles) uncommittedNixFiles);

in
{
  checks = {
    # --- Check All Nix Files (Formatting and Static Analysis) ---
    check-all-nix-files = pkgs.runCommand "check-all-nix-files" {
      inherit allProjectNixFiles;
      nixpkgs-fmt-check = qa-helpers.runNixFmtCheck allProjectNixFiles;
      statix-check = qa-helpers.runStatixCheck allProjectNixFiles;
    } ''
      echo "--- Running checks on all .nix files ---"
      ${nixpkgs-fmt-check}
      ${statix-check}
      echo "--- All .nix file checks passed. ---"
      touch $out
    '';

    # --- Check Uncommitted Files ---
    check-uncommitted-files = pkgs.runCommand "check-uncommitted-files" {
      uncommittedFiles = allUncommittedFiles;
      shellcheck-check = qa-helpers.runShellcheckCheck allUncommittedFiles; # Assuming uncommitted files can be shell scripts
    } ''
      echo "--- Running checks on uncommitted files ---"
      echo "Found the following uncommitted files:"
      for f in $uncommittedFiles; do
        echo "  - $f"
      done
      ${shellcheck-check}
      echo "--- All uncommitted file checks passed. ---"
      touch $out
    '';

    # --- Check Uncommitted Files ---
    check-uncommitted-files = pkgs.runCommand "check-uncommitted-files" {
      uncommittedFiles = allUncommittedFiles;
    } ''
      echo "Checking uncommitted files..."
      echo "Found the following uncommitted files:"
      for f in $uncommittedFiles; do
        echo "  - $f"
      done
      touch $out
    '';

    # --- Nix Flake & Expression Testing ---
    nix-flake-check = pkgs.runCommand "nix-flake-check" {
      inherit projectSrc;
    } ''
      echo "Running nix flake check..."
      # Copy project source to a temporary directory to avoid modifying the original
      cp -r $projectSrc/. .
      nix flake check --extra-experimental-features 'nix-command flakes'
      touch $out
    '';

    # --- Pre-commit Hook Testing ---
    pre-commit-all-files = pkgs.runCommand "pre-commit-all-files" {
      inherit pre-commit git;
      inherit projectSrc;
    } ''
      echo "Running pre-commit hooks on all files..."
      # Copy project source to a temporary directory
      cp -r $projectSrc/. .
      # Initialize a dummy git repository for pre-commit to work
      ${git}/bin/git init
      ${git}/bin/git add .
      # Run pre-commit on all files
      ${pre-commit}/bin/pre-commit run --all-files
      touch $out
    '';

    # --- Script Testing (explicit shellcheck for config.sh) ---
    # This check is specifically for config.sh to ensure the disable comments work
    shellcheck-config-sh = pkgs.runCommand "shellcheck-config-sh" {
      inherit shellcheck;
      inherit projectSrc;
    } ''
      echo "Running shellcheck on scripts/test-commit-checker/config.sh..."
      cp -r $projectSrc/. .
      ${shellcheck}/bin/shellcheck -x scripts/test-commit-checker/config.sh
      touch $out
    '';

    # Add more checks here as needed, following the QA plan categories
    # e.g., statix, nix-url-check, specific build tests for other flakes
  };

  # A default check that runs all defined checks
  defaultCheck = pkgs.runCommand "default-qa-check" {
    inherit (self.checks) nix-flake-check pre-commit-all-files shellcheck-config-sh check-uncommitted-files check-all-nix-files;
  } ''
    echo "--- Running all default QA checks ---"
    # Ensure all dependencies are built by referencing their outputs
    ${self.checks.nix-flake-check}
    ${self.checks.pre-commit-all-files}
    ${self.checks.shellcheck-config-sh}
    ${self.checks.check-uncommitted-files}
    ${self.checks.check-all-nix-files}
    echo "--- All default QA checks passed. ---"
    touch $out
  '';
}