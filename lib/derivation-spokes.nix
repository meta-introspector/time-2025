{ pkgs, lib, ... }:

let
  tiktokConfig = import ../lib/tiktok-config.nix { inherit lib; };
  ipfsPublisher = import ../lib/ipfs-publisher.nix { inherit pkgs lib; };
in
{
  mkMiniZincSpoke = taskName: mznCode: dznCode: pkgs.stdenv.mkDerivation {
    name = "minizinc-${taskName}";
    buildInputs = [ pkgs.minizinc ];
    buildCommand = ''
      mkdir -p $out/src
      echo "${mznCode}" > $out/src/${taskName}.mzn
      echo "${dznCode}" > $out/src/${taskName}.dzn
      ${pkgs.minizinc}/bin/minizinc --solver Gecode $out/src/${taskName}.mzn $out/src/${taskName}.dzn > $out/solution.txt

      # Publish to IPFS
      cid=$(cat ${ipfsPublisher.publishToIpfs "$out/solution.txt"})
      echo "IPFS_CID=$cid" >> $out/nix-support/hydra-build-products
    '';
  };

  mkLean4Spoke = taskName: lean4Code: pkgs.stdenv.mkDerivation {
    name = "lean4-${taskName}";
    buildInputs = [ pkgs.lean ]; # Assuming pkgs.lean exists
    buildCommand = ''
      mkdir -p $out/src
      echo "${lean4Code}" > $out/src/${taskName}.lean
      # FIXME: Add Lean4 build/check commands here
      # For now, just echo the code
      echo "Lean4 code for ${taskName}:" > $out/code.txt
      cat $out/src/${taskName}.lean >> $out/code.txt

      # FIXME: The IPFS publisher is mocked. Replace with a real implementation.
      # Publish to IPFS
      cid=$(${ipfsPublisher.publishToIpfs} $out/code.txt)
      echo "IPFS_CID=$cid" >> $out/nix-support/hydra-build-products
    '';
  };

  mkRustSpoke = taskName: rustCode: pkgs.stdenv.mkDerivation {
    name = "rust-${taskName}";
    buildInputs = [ pkgs.rustc pkgs.cargo ];
    buildCommand = ''
      mkdir -p $out/src
      echo "${rustCode}" > $out/src/${taskName}.rs
      # FIXME: Add Rust build/test commands here
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
      # FIXME: Add commands to generate video assets or other TikTok specific content
    '';
  };

  mkAwsSpoke = taskName: deploymentConfig: pkgs.stdenv.mkDerivation {
    name = "aws-${taskName}";
    # FIXME: Implement AWS deployment logic
    buildCommand = ''
      echo "Deploying ${taskName} to AWS with config: ${deploymentConfig}" > $out
    '';
  };

  mkGcpSpoke = taskName: deploymentConfig: pkgs.stdenv.mkDerivation {
    name = "gcp-${taskName}";
    # FIXME: Implement GCP deployment logic
    buildCommand = ''
      echo "Deploying ${taskName} to GCP with config: ${deploymentConfig}" > $out
    '';
  };

  mkAzureSpoke = taskName: deploymentConfig: pkgs.stdenv.mkDerivation {
    name = "azure-${taskName}";
    # FIXME: Implement Azure deployment logic
    buildCommand = ''
      echo "Deploying ${taskName} to Azure with config: ${deploymentConfig}" > $out
    '';
  };

  mkOracleCloudSpoke = taskName: deploymentConfig: pkgs.stdenv.mkDerivation {
    name = "oracle-cloud-${taskName}";
    # FIXME: Implement Oracle Cloud deployment logic
    buildCommand = ''
      echo "Deploying ${taskName} to Oracle Cloud with config: ${deploymentConfig}" > $out
    '';
  };

  mkArchiveOrgSpoke = taskName: content: pkgs.stdenv.mkDerivation {
    name = "archive-org-${taskName}";
    # FIXME: Implement archive.org upload logic
    buildCommand = ''
      echo "Archiving ${taskName} to archive.org with content: ${content}" > $out
    '';
  };

  mkHuggingFaceSpoke = taskName: modelConfig: pkgs.stdenv.mkDerivation {
    name = "hugging-face-${taskName}";
    # FIXME: Implement Hugging Face deployment logic
    buildCommand = ''
      echo "Deploying ${taskName} to Hugging Face with config: ${modelConfig}" > $out
    '';
  };

  mkSdfOrgSpoke = taskName: content: pkgs.stdenv.mkDerivation {
    name = "sdf-org-${taskName}";
    # FIXME: Implement sdf.org hosting logic
    buildCommand = ''
      echo "Hosting ${taskName} on sdf.org with content: ${content}" > $out
    '';
  };

  mkFilecoinSpoke = taskName: data: pkgs.stdenv.mkDerivation {
    name = "filecoin-${taskName}";
    # FIXME: Implement Filecoin storage logic
    buildCommand = ''
      echo "Storing ${taskName} on Filecoin with data: ${data}" > $out
    '';
  };

  mkOtherStorageCoinSpoke = taskName: data: pkgs.stdenv.mkDerivation {
    name = "other-storage-coin-${taskName}";
    # FIXME: Implement other storage coin logic
    buildCommand = ''
      echo "Storing ${taskName} on other storage coin with data: ${data}" > $out
    '';
  };

  mkDockerHubSpoke = taskName: imageConfig: pkgs.stdenv.mkDerivation {
    name = "dockerhub-${taskName}";
    # FIXME: Implement DockerHub publishing logic
    buildCommand = ''
      echo "Publishing ${taskName} to DockerHub with config: ${imageConfig}" > $out
    '';
  };

  mkGithubReleaseSpoke = taskName: releaseConfig: pkgs.stdenv.mkDerivation {
    name = "github-release-${taskName}";
    # FIXME: Implement GitHub Release creation logic
    buildCommand = ''
      echo "Creating GitHub Release for ${taskName} with config: ${releaseConfig}" > $out
    '';
  };

  mkGithubActionsSpoke = taskName: workflowConfig: pkgs.stdenv.mkDerivation {
    name = "github-actions-${taskName}";
    # FIXME: Implement GitHub Actions triggering logic
    buildCommand = ''
      echo "Triggering GitHub Actions for ${taskName} with config: ${workflowConfig}" > $out
    '';
  };

  mkAwsCodeBuildSpoke = taskName: buildConfig: pkgs.stdenv.mkDerivation {
    name = "aws-codebuild-${taskName}";
    # FIXME: Implement AWS CodeBuild logic
    buildCommand = ''
      echo "Running AWS CodeBuild for ${taskName} with config: ${buildConfig}" > $out
    '';
  };

  mkSelfHostedNixBuildHydraSpoke = taskName: hydraConfig: pkgs.stdenv.mkDerivation {
    name = "self-hosted-hydra-${taskName}";
    # FIXME: Implement self-hosted Hydra scheduling logic
    buildCommand = ''
      echo "Scheduling ${taskName} on self-hosted Nix build Hydra with config: ${hydraConfig}" > $out
    '';
  };

  mkLLMCodeSpoke = taskName: llmProvider: llmCode: pkgs.stdenv.mkDerivation {
    name = "${llmProvider}-code-${taskName}";
    buildCommand = ''
      mkdir -p $out/src
      echo "${llmCode}" > $out/src/${taskName}.txt
    '';
  };

  mkMiniZincOptimizationSpoke = taskName: mznModel: dznData: pkgs.stdenv.mkDerivation {
    name = "minizinc-optimization-${taskName}";
    buildInputs = [ pkgs.minizinc ];
    buildCommand = ''
      mkdir -p $out/src
      echo "${mznModel}" > $out/src/${taskName}.mzn
      echo "${dznData}" > $out/src/${taskName}.dzn
      ${pkgs.minizinc}/bin/minizinc --solver Gecode $out/src/${taskName}.mzn $out/src/${taskName}.dzn > $out/solution.txt
    '';
  };

  mkBootstrapSpoke = taskName: bootstrapNixExpression: pkgs.stdenv.mkDerivation {\n    name = \"bootstrap-${taskName}\";\n    buildInputs = [ pkgs.nix ]; # Need Nix to evaluate expressions\n    buildCommand = \'\'\n      mkdir -p $out/bootstrap-plan\n\n      # Save the bootstrap plan and executor for later use\n      echo \"${bootstrapNixExpression}\" > $out/bootstrap-plan/bootstrap-plan.nix\n      cp ${../../10/04/bootstrap/bootstrap-executor.nix} $out/bootstrap-plan/bootstrap-executor.nix\n\n      # Create a script to run the next step\n      cat > $out/bootstrap-plan/run-next-step.sh << EOF\n      #!/bin/sh\n      set -eu\n\n      # Usage: ./run-next-step.sh [current_global_state_json_path]\n      # If no current_global_state_json_path is provided, it starts with an empty state.\n\n      current_state_path=\"\$1\"\n      if [ -z \"\$current_state_path\" ]; then\n        current_state=\'{}\'\n      else\n        current_state=\"$(cat \"\$current_state_path\")\"\n      fi\n\n      bootstrap_plan_path=\"$out/bootstrap-plan/bootstrap-plan.nix\"\n      executor_path=\"$out/bootstrap-plan/bootstrap-executor.nix\"\n\n      # Evaluate the executor with current state and plan\n      # This will produce the new global state after executing one step\n      ${pkgs.nix}/bin/nix-instantiate \\\n        --eval --json \\\n        --arg pkgs ${pkgs} \\\n        --arg lib ${lib} \\\n        --argstr bootstrapPlanExpression \"$(cat \"\$bootstrap_plan_path\")\" \\\n        --argstr globalState \"\$current_state\" \\\n        \"\$executor_path\" > \$out/bootstrap-plan/next-global-state.json\n\n      echo \"Executed one bootstrap step. New state in \$out/bootstrap-plan/next-global-state.json\"\n      EOF\n      chmod +x $out/bootstrap-plan/run-next-step.sh\n\n      echo \"Bootstrap plan and executor prepared in $out/bootstrap-plan/\"\n      echo \"To run the first step: $out/bootstrap-plan/run-next-step.sh\"\n      echo \"To run subsequent steps: $out/bootstrap-plan/run-next-step.sh $out/bootstrap-plan/next-global-state.json\"\n    \'\';\n  };
}
