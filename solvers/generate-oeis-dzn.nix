{ lib, config, oeisConfig, ... }:

let
  # Number of terms to generate (can be dynamic based on community contributions)
  n = 10; # For now, a fixed number

  # Format initial terms for MiniZinc
  initialTermsDzn = lib.concatStringsSep "\n" (
    lib.genList (i: "constraint F[${toString (i + 1)}] = ${toString (lib.elemAt oeisConfig.initialTerms i)};") (lib.length oeisConfig.initialTerms)
  );

  # Format community contributions for MiniZinc
  communityContributionsDzn = lib.concatStringsSep "\n" (
    lib.genList (i: "community_result_${toString (i + 1)} = ${toString (lib.elemAt oeisConfig.communityContributions i).result};") (lib.length oeisConfig.communityContributions)
  );

in
''
n = ${toString n};
${initialTermsDzn}
${communityContributionsDzn}
''

