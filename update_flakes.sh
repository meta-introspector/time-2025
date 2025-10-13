#!/nix/store/hxmi7d6vbdgbzklm4icfk2y83ncw8la9-bash-5.3p3/bin/bash

nix registry add readRdVial "github:meta-introspector/time-2025?ref=feature/aimyc-002-sample-extraction&dir=flakes/read-md-vial"
nix flake update --verbose --show-trace
