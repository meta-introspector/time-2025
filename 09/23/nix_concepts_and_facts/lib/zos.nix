{ pkgs, lib, crqBinstore ? {}, nixLib ? {} } @ args:

let
  primesList = import ./primes.nix;

  # Function to unpack a NAR file and extract primes.txt
  unpackZosNar = prime:
    let
      narFileName = "zos-sequence-${builtins.toString prime}.nar";
      narPath = "${crqBinstore}/${narFileName}"; # Path to the NAR file within the input
    in
    pkgs.runCommand "unpacked-zos-sequence-${builtins.toString prime}"
      {
        # No specific buildInputs needed for nix-store --restore as it's part of core Nix
        script = ./scripts/unpack-zos-sequence.sh;
      } ''
      $script ${narPath} $out
    '';

  zosPrimes = builtins.listToAttrs (builtins.map
    (prime: {
      name = "prime-${builtins.toString prime}";
      value = unpackZosNar prime;
    })
    primesList);
in
{
  inherit unpackZosNar zosPrimes;
}
