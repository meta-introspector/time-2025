{ lib, pkgs, ... }:

let
  # Function to extract Nix store paths from a single string (log line)
  extractNixStorePathsFromLine = logLine:
    let
      extractorDerivation = pkgs.runCommand "nix-path-extractor-line"
        {
          buildInputs = [ pkgs.gnugrep pkgs.jq ];
        } ''
        echo "$logLine" > line.txt
        grep -oP "/nix/store/[a-z0-9]{32}-[a-zA-Z0-9_.-]+" line.txt | \
          jq -R -s '[split("\n")[] | select(length > 0)]' > $out
      '';
    in
    builtins.fromJSON (builtins.readFile extractorDerivation);

  # Function to extract Nix store paths from a list of log lines
  extractNixStorePathsFromLog = logLines:
    lib.unique (lib.flatten (map extractNixStorePathsFromLine logLines));

in
{
  inherit extractNixStorePathsFromLog extractNixStorePathsFromLine;
}
