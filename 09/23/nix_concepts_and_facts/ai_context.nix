{ pkgs ? import <nixpkgs> { }, concepts ? import ./concepts { inherit pkgs; } }:

pkgs.runCommand "ai-context-23" { } ''
  mkdir -p $out/concepts
  ln -s ${concepts.number-23}/number $out/concepts/number_23
  ln -s ${concepts.is-prime-23}/result $out/concepts/is_prime_23
  ln -s ${concepts.fact-23-oracle}/fact $out/concepts/fact_23
''
