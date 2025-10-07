{ lib, pkgs, builtins }: {
  generateNGrams = { text, n ? 2, name ? "n-gram-output" }:
    pkgs.runCommand name {
      inherit text n;
      nativeBuildInputs = [ pkgs.gnused pkgs.gnugrep ];
    }
    ''
      echo "${text}" | sed -E 's/[^a-zA-Z0-9 ]+/ /g' | tr '[:upper:]' '[:lower:]' | \
      tr -s ' ' '\n' | grep -v '^$' | \
      awk -v n="${n}" '{ 
        for (i = 1; i <= NF - n + 1; i++) {
          line = $i;
          for (j = 1; j < n; j++) {
            line = line " " $(i + j);
          }
          print line;
        }
      }' > $out/ngrams.txt
    '';
}
