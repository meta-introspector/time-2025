{ pkgs ? import <nixpkgs> { } }:

let
  is-prime-script = pkgs.writeText "is-prime-script" ''
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
in

pkgs.runCommand "is-prime-23" { } ''
  ${is-prime-script} 23 > $out/result
''
