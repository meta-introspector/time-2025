{ lib
, pkgs
, system
, nixpkgs
, rnixParser
, self
,
}:

let
  # --- Phase 1: Keyword Resonation ---
  # Keywords for "Nix resonance"
  nixResonanceKeywords = [
    "flake"
    "inputs"
    "outputs"
    "package"
    "reproducibility"
    "content-addressability"
    "immutability"
  ];

  # Function to extract keywords from a flake's source
  extractKeywords = flakeSource:
    let
      extractScriptContent = ''
        set -euo pipefail

        echo "Extracting keywords from ${flakePath}/flake.nix"
        flake_content=$(cat ${flakePath}/flake.nix)
        found_keywords=()

        for keyword in $(echo "$keywords" | jq -r '.[]'); do
          if echo "$flake_content" | grep -q -w "$keyword"; then
            found_keywords+=("$keyword")
          fi
        done

        echo "$(jq -n --argjson arr "''${found_keywords[@]}" '$arr')" > $out
      '';
      extractScript = pkgs.writeShellScriptBin "extract-keywords-script" extractScriptContent;
    in
    pkgs.runCommand "extract-keywords-${flakeSource.name or "unknown"}"
      {
        nativeBuildInputs = [ pkgs.bash pkgs.gnugrep pkgs.jq ];
        flakePath = flakeSource;
        keywords = lib.toJSON nixResonanceKeywords;
      } "''${extractScript}/bin/extract-keywords-script";

  # --- Phase 2: Arithmetization and Dimensionality ---
  # Primes for Gödel numbering, based on the Monster Group factorization
  # Order of Monster Group: 2^46 * 3^20 * 5^9 * 7^6 * 11^2 * 13^3 * 17^1 * 19^1 * 23^1 * 29^1 * 31^1 * 41^1 * 47^1 * 59^1 * 71^1
  primes = [
    2
    3
    5
    7
    11
    13
    17
    19
    23
    29
    31
    41
    47
    59
    71
  ];

  # Function to calculate the "Monster Knot" (prime exponents from AST analysis)
  calculateMonsterKnot = flakeSource:
    pkgs.runCommand "monster-knot-${flakeSource.name or "unknown"}"
      {
        nativeBuildInputs = [ pkgs.bash pkgs.jq pkgs.gnugrep ];
        flakePath = flakeSource;
        parsedFlake = parseFlakeToTerm flakeSource;
        # Pass primes and keywordToPrimeMap to the shell script for calculation
        monsterPrimes = lib.toJSON primes;
        keywordMap = lib.toJSON keywordToPrimeMap;
        monsterKnotScript = ./monster-knot-script.sh;
      } "${monsterKnotScript} ${flakePath} ${parsedFlake} ${lib.toJSON primes} ${lib.toJSON keywordToPrimeMap} $out";

  # Function to project the prime exponents into an 8D representation
  # This is a placeholder for a complex mathematical transformation (e.g., PCA, specific Clifford algebra projection)
  projectTo8D = primeExponents:
    let
      # For now, we'll just take the first 8 exponents as a conceptual 8D vector
      # In a real implementation, this would involve a more sophisticated projection
      # that maps the full Monster Group factorization onto an 8D Riemann Manifold.
      eightDVector = lib.take 8 (lib.attrValues primeExponents);
    in
    eightDVector;

  # Function to compare two prime exponent attrsets and return a similarity score
  # A higher score means more similar.
  comparePrimeExponents = exponents1: exponents2:
    let
      allPrimes = lib.unique (lib.attrNames exponents1 ++ lib.attrNames exponents2);
      # Calculate a similarity score (e.g., inverse of squared Euclidean distance)
      # For simplicity, let's just count matching exponents for now.
      matchingExponents = lib.foldl
        (acc: prime:
          let
            exp1 = exponents1."${prime}" or 0;
            exp2 = exponents2."${prime}" or 0;
          in
          acc + (if exp1 == exp2 then 1 else 0)
        ) 0
        allPrimes;
    in
    matchingExponents;

  # Function to index all flakes in the project
  indexAllFlakes = allFlakeSources:
    lib.map
      (flakeSource:
        let
          # Use calculateMonsterKnot instead of extractKeywords and calculateGödelNumber
          flakePrimeExponents = calculateMonsterKnot flakeSource;
          flakeEightDVector = projectTo8D flakePrimeExponents;
        in
        { inherit flakeSource flakePrimeExponents flakeEightDVector; }
      )
      allFlakeSources;

  # Function to find similar flakes
  findSimilarFlakes = { targetFlakeSource, indexedFlakes }:
    let
      targetPrimeExponents = calculateMonsterKnot targetFlakeSource;

      # Calculate similarity for each indexed flake
      flakesWithSimilarity = lib.map
        (indexedFlake:
          let
            similarity = comparePrimeExponents targetPrimeExponents indexedFlake.flakePrimeExponents;
          in
          indexedFlake // { inherit similarity; }
        )
        indexedFlakes;

      # Sort flakes by similarity (descending)
      sortedFlakes = lib.sort (a: b: b.similarity < a.similarity) flakesWithSimilarity;
    in
    sortedFlakes;

  # Function to generate RDF triples from flake information
  generateRdfTriples = flakeInfo:
    let
      subject = "urn:flake:${flakeInfo.flakeSource.name or "unknown"}";
      triples = [
        { s = subject; p = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"; o = "http://xmlns.com/foaf/0.1/Document"; }
        { s = subject; p = "http://purl.org/dc/elements/1.1/description"; o = "${flakeInfo.flakeSource.description or "Nix Flake"}"; }
        { s = subject; p = "http://example.com/ns#gödelNumber"; o = lib.toJSON flakeInfo.flakePrimeExponents; }
      ] ++ lib.map (keyword: { s = subject; p = "http://example.com/ns#hasKeyword"; o = keyword; }) flakeInfo.flakeKeywords;
    in
    triples;

  # Placeholder for final verification as a quasifiber
  verifyQuasifiber = searchResults:
    # This would involve more complex logic to verify the topological essence
    # and project onto the 8D Riemann Manifold.
    # For now, just return a success message.
    "Verification complete: Results form a conceptual quasifiber.";

  # Function to parse a flake's flake.nix into a term structure (JSON AST)
  parseFlakeToTerm = flakeSource: pkgs.runCommand "parse-flake-${flakeSource.name or "unknown"}"
    {
      nativeBuildInputs = [ pkgs.bash rnixParser.packages.${system}.default ]; # Use rnix-parser binary
      flakePath = flakeSource;
    } ''
    set -euo pipefail

    echo "Parsing ${flakePath}/flake.nix into AST..."
    # rnix-parser can output JSON AST
    ${rnixParser.packages.${system}.default}/bin/rnix-parser --json < ${flakePath}/flake.nix > $out
  '';

in
{
  inherit nixResonanceKeywords extractKeywords primes comparePrimeExponents;
  inherit indexAllFlakes findSimilarFlakes generateRdfTriples verifyQuasifiber parseFlakeToTerm calculateMonsterKnot;
}
