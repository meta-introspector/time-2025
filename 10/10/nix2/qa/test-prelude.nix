{ lib, pkgs }:

let
  # Import the prelude.nix
  prelude = import ../../prelude.nix {
    inherit lib pkgs;
    # firstReflection and urlExtractor are implicitly passed through prelude.nix's arguments
    # We need to ensure they are available in the context where prelude.nix is imported
    # For testing, we can mock them or ensure they are available in the test environment
    firstReflection = import ../lib/first-reflection.nix { inherit lib pkgs; };
    urlExtractor = import ../nix-url-extractor.nix;
  };

  # Test 1: Ensure parsedUrls is not empty
  testParsedUrlsNotEmpty = lib.assertMsg (lib.length prelude > 0) "Parsed URLs list should not be empty.";

  # Test 2: Ensure each parsed URL has expected components
  testParsedUrlComponents = lib.map
    (parsedUrl:
      lib.assertMsg (parsedUrl ? owner && parsedUrl ? repo && parsedUrl ? url)
        "Each parsed URL should have 'owner', 'repo', and 'url' components."
    )
    prelude;

  # Test 3: Ensure owner is meta-introspector or allowed (as per earlier requirement)
  testOwnerIsAllowed = lib.map
    (parsedUrl:
      lib.assertMsg (parsedUrl.owner == "meta-introspector")
        "Owner should be 'meta-introspector'."
    )
    prelude;

  # Test 4: Ensure external repos have corresponding meta-introspector forks
  testExternalReposHaveMetaIntrospectorForks =
    let
      externalRepos = lib.filter (parsedUrl: parsedUrl.owner != "meta-introspector") prelude;
      metaIntrospectorRepos = lib.filter (parsedUrl: parsedUrl.owner == "meta-introspector") prelude;

      checks = lib.map
        (externalRepo:
          let
            hasFork = lib.any (miRepo: miRepo.repo == externalRepo.repo) metaIntrospectorRepos;
          in
          lib.assertMsg hasFork "External repo '${externalRepo.url}' must have a corresponding 'meta-introspector' fork."
        )
        externalRepos;
    in
    lib.all (x: x) checks;

  # Test 5: Ensure meta-introspector forks are checked out and on the correct branch
  testMetaIntrospectorForksAreCheckedOutAndBranched =
    let
      metaIntrospectorRepos = lib.filter (parsedUrl: parsedUrl.owner == "meta-introspector") prelude;
      currentBranch = firstReflection.identityPrincipleSpec.currentBranchName; # Get the current branch name

      checks = lib.map
        (miRepo:
          let
            # Construct the expected path for the fork (this is a heuristic and might need refinement)
            # Assuming a convention like ./source/github/meta-introspector/repo-name
            expectedPath = toString (../../source/github/meta-introspector + "/${miRepo.repo}");
            isPathCheckedOut = builtins.pathExists expectedPath;

            # Check the branch name if checked out
            isBranchCorrect =
              if isPathCheckedOut then
                let
                  headContent = builtins.readFile "${expectedPath}/.git/HEAD";
                  # Extract branch name from "ref: refs/heads/branch-name"
                  branchMatch = lib.strings.match "ref: refs/heads/(.*)" headContent;
                  actualBranch = if branchMatch != null then lib.head branchMatch.captures else null;
                in
                actualBranch == currentBranch
              else
                false; # Not checked out, so branch is not correct
          in
          lib.assertMsg (isPathCheckedOut && isBranchCorrect)
            "Meta-introspector fork '${miRepo.url}' at '${expectedPath}' must be checked out and on branch '${currentBranch}'."
        )
        metaIntrospectorRepos;
    in
    lib.all (x: x) checks;

in
{
  # Expose test results
  testResults = {
    inherit testParsedUrlsNotEmpty testParsedUrlComponents testOwnerIsAllowed testExternalReposHaveMetaIntrospectorForks testMetaIntrospectorForksAreCheckedOutAndBranched;
  };
  # A simple check that combines all assertions
  allTestsPass = testParsedUrlsNotEmpty && (lib.all (x: x) testParsedUrlComponents) && (lib.all (x: x) testOwnerIsAllowed) && testExternalReposHaveMetaIntrospectorForks && testMetaIntrospectorForksAreCheckedOutAndBranched;
}
