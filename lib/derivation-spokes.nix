{ pkgs, lib, ... }:

let
  tiktokConfig = import ../lib/tiktok-config.nix { inherit lib; };
in
{
  mkMiniZincSpoke = taskName: mznCode: dznCode: pkgs.stdenv.mkDerivation {
    name = "minizinc-${taskName}";
    buildInputs = [ pkgs.minizinc ];
    buildCommand = ''
      mkdir -p $out/src
      echo "${mznCode}" > $out/src/${taskName}.mzn
      echo "${dznCode}" > $out/src/${taskName}.dzn
      # Add MiniZinc run commands here
      # For now, just echo the solution (if any)
      ${pkgs.minizinc}/bin/minizinc --solver Gecode $out/src/${taskName}.mzn $out/src/${taskName}.dzn > $out/solution.txt
    '';
  };

  mkLean4Spoke = taskName: lean4Code: pkgs.stdenv.mkDerivation {
    name = "lean4-${taskName}";
    buildInputs = [ pkgs.lean ]; # Assuming pkgs.lean exists
    buildCommand = ''
      mkdir -p $out/src
      echo "${lean4Code}" > $out/src/${taskName}.lean
      # Add Lean4 build/check commands here
      # For now, just echo the code
      echo "Lean4 code for ${taskName}:" > $out/code.txt
      cat $out/src/${taskName}.lean >> $out/code.txt
    '';
  };

  mkRustSpoke = taskName: rustCode: pkgs.stdenv.mkDerivation {
    name = "rust-${taskName}";
    buildInputs = [ pkgs.rustc pkgs.cargo ];
    buildCommand = ''
      mkdir -p $out/src
      echo "${rustCode}" > $out/src/${taskName}.rs
      # Add Rust build/test commands here
      # For now, just echo the code
      echo "Rust code for ${taskName}:" > $out/code.txt
      cat $out/src/${taskName}.rs >> $out/code.txt
    '';
  };

  mkGenericSpoke = taskName: code: pkgs.stdenv.mkDerivation {
    name = "generic-${taskName}";
    buildCommand = ''
      mkdir -p $out/src
      echo "${code}" > $out/src/${taskName}.nix
    '';
  };

  mkTikTokSpoke = taskName: tiktokContent: oeisNumber: pkgs.stdenv.mkDerivation {
    name = "tiktok-${taskName}";
    buildCommand = ''
      mkdir -p $out/${tiktokConfig.tiktokOutputPath}
      echo "${tiktokConfig.tiktokChallengePrefix}#${oeisNumber}" > $out/${tiktokConfig.tiktokOutputPath}/${tiktokConfig.tiktokChallengeFile}
      echo "${tiktokContent}" > $out/${tiktokConfig.tiktokOutputPath}/${tiktokConfig.tiktokScriptFile}
      # Add commands to generate video assets or other TikTok specific content
    '';
  };
}
