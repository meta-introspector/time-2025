{ pkgs, flakeSelf, nixLib } @ args:

let
  mkNumber = num: pkgs.runCommand "number-${builtins.toString num}" {
    script = pkgs.runCommand "number-script" { } ''
      cp ${flakeSelf}/scripts/number.sh $out
      chmod +x $out
    '';
  } ''
    $script $out "${builtins.toString num}"
  '';

  is-prime-script = pkgs.writeText "is-prime.sh" ''
    #!/usr/bin/env bash
    set -euo pipefail

    number="$1"
    if (( number < 2 )); then
      echo "false"
      exit 0
    fi
    for ((i=2; i*i<=number; i++)); do
      if (( number % i == 0 )); then
        echo "false"
        exit 0
      fi
    done
    echo "true"
  '';

  is-prime-23 = pkgs.runCommand "is-prime-23" {
    script = ./scripts/is-prime-check.sh;
  } ''
    $script $out ${is-prime-script} "23"
  '';

  fact-23-oracle = pkgs.runCommand "fact-23-oracle" { }''
    set -x
    mkdir -p $out
    cp ${flakeSelf}/facts/fact_about_23.txt $out/fact
  '';
in
{
  inherit mkNumber is-prime-23 fact-23-oracle;
  inherit is-prime-script; # Also expose the script if needed elsewhere
}