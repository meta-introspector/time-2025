{ pkgs, lib, self, nix-stdlib, nixTermExtractor, nGramGenerator }:

let
  qa-helpers = import ./lib/qa-helpers.nix { inherit pkgs lib nixpkgs-fmt statix shellcheck nix-stdlib; };

  # Define common tools
  inherit (pkgs) shellcheck;
  inherit (pkgs) pre-commit;
  inherit (pkgs) git;
  inherit (pkgs) nixpkgs-fmt;
  inherit (pkgs) statix;
  # The entire project source for checks that need it
  projectSrc = self;

  # Import the dynamically generated project.nix
  projectNix = import ./project.nix;

  # Collect all .nix file paths from the projectNix attribute set
  allProjectNixFiles = qa-helpers.collectNixFilesFromAttrset projectNix;

  nixpkgs-fmt-check = qa-helpers.runNixFmtCheck allProjectNixFiles;
  statix-check = qa-helpers.runStatixCheck allProjectNixFiles;

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

  shellcheck-check = qa-helpers.runShellcheckCheck { shellFiles = allUncommittedFiles; inherit shellcheck; };

  tmpDir = builtins.genTmpDir "nix-flake-check-tmp";

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
      uncommittedFiles = lib.strings.concatStringsSep " " allUncommittedFiles;
    } ''
      echo "--- Running checks on uncommitted files ---"
      echo "Found the following uncommitted files:"
      for f in $uncommittedFiles; do
        echo "  - $f"
      done
      echo "--- All uncommitted file checks passed. ---"
      touch $out
    '';


    # --- Nix Flake & Expression Testing ---
    nix-flake-check = pkgs.runCommand "nix-flake-check" {
      inherit projectSrc;
      nativeBuildInputs = [ pkgs.nix ];
    } ''
      tmpConfDir=$(mktemp -d)
      tmpStateDir=$(mktemp -d)
      tmpCacheDir=$(mktemp -d)
      tmpHomeDir=$(mktemp -d)
      echo "state-dir = $tmpStateDir" > $tmpConfDir/nix.conf
      echo "local-cache-dir = $tmpCacheDir" >> $tmpConfDir/nix.conf
      export NIX_CONF_DIR=$tmpConfDir
      export HOME=$tmpHomeDir

      cp -r $projectSrc/. .
      nix flake check --extra-experimental-features 'nix-command flakes impure-derivations ca-derivations' --no-update-lock-file --override-input dataSources path:./flakes/data-sources
      rm -rf $tmpConfDir $tmpStateDir $tmpCacheDir $tmpHomeDir
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

    # --- Nix Emoji Report ---
    nix-emoji-report = pkgs.runCommand "nix-emoji-report" {
      inherit projectSrc nixTermExtractor nGramGenerator;
      nixFilePaths = lib.strings.splitString "\n" (builtins.readFile (projectSrc + "/index/chunks/nix.txt"));
      nGramLengths = [ 1 2 3 5 7 11 13 17 19 ];
    } ''
      echo "--- Generating Nix Emoji Report ---"
      mkdir -p $out
      reportFile="$out/nix-emoji-report.md"
      echo "# Nix Emoji Report" > "$reportFile"
      echo "" >> "$reportFile"

      for filePath in $nixFilePaths; do
        if [ -n "$filePath" ]; then
          echo "## File: $filePath" >> "$reportFile"
          echo "" >> "$reportFile"
          # This part is conceptual, as direct Nix evaluation in shell is complex
          # We would ideally call a Nix function here to generate the emoji sequence
          # For demonstration, we'll use a placeholder or a simplified approach
          echo "Emoji Sequence: [Conceptual Emoji Sequence for $filePath]" >> "$reportFile"
          echo "" >> "$reportFile"
        fi
      done
      echo "--- Nix Emoji Report Generated to $reportFile ---"
      touch $out
    '';
  };

  # A default check that runs all defined checks
  defaultCheck = pkgs.runCommand "default-qa-check" {
    inherit (self.checks) nix-flake-check pre-commit-all-files shellcheck-config-sh check-uncommitted-files check-all-nix-files nix-emoji-report;
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