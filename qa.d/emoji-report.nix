{ lib, pkgs, projectInfo, nixTermExtractor, nGramGeneratorModule }:

let
  generateEmojiSequence = { filePath, nGramLengths, nGramGeneratorModule }:
    let
      pathTokens = nGramGeneratorModule.tokenizePath filePath;
      nGrams = nGramGeneratorModule.generateNGrams { tokens = pathTokens; inherit nGramLengths; };
    in
    lib.strings.concatStringsSep " " nGrams;

  nix-emoji-report = pkgs.runCommand "nix-emoji-report"
    {
      inherit (projectInfo) projectSrc;
      inherit nixTermExtractor nGramGeneratorModule;
      nixFilePaths = lib.strings.splitString "\n" (builtins.readFile (projectInfo.projectSrc + "/index/chunks/nix.txt"));
      nGramLengths = [ 1 2 3 5 7 11 13 17 19 ];
      generateEmojiSequenceScript = pkgs.writeText "generate-emoji-sequence.nix" ''
        { lib, nGramGeneratorModule, filePath, nGramLengths }:
        let
          pathTokens = nGramGeneratorModule.tokenizePath filePath;
          nGrams = nGramGeneratorModule.generateNGrams { tokens = pathTokens; inherit nGramLengths; };
        in
        lib.strings.concatStringsSep " " nGrams
      '';
    }
    ''
    echo "--- Generating Nix Emoji Report ---"
    mkdir -p $out
    reportFile="$out/nix-emoji-report.md"
    echo "# Nix Emoji Report" > "$reportFile"
    echo "" >> "$reportFile"

    for filePath in $nixFilePaths; do
      if [ -n "$filePath" ]; then
        echo "## File: $filePath" >> "$reportFile"
        echo "" >> "$reportFile"

        emojiSequence=$(nix eval --raw --expr '(
          let
            lib = import ${pkgs.path}/lib;
            nGramGeneratorModule = ${nGramGeneratorModule};
            filePath = "${filePath}";
            nGramLengths = ${builtins.toJSON nGramLengths};
          in
          (import ${generateEmojiSequenceScript} { inherit lib nGramGeneratorModule filePath nGramLengths; })
        )')

        echo "Emoji Sequence: $emojiSequence" >> "$reportFile"
        echo "" >> "$reportFile"
      fi
    done
    echo "--- Nix Emoji Report Generated to $reportFile ---"
    touch $out
  '';
in
{
  inherit nix-emoji-report;
}
