{
  description = "Orchestrates the bootstrap of a virtual mycology schedule, focusing on hackathon memes in a vial.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    zosSporeVialFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/zos-spore-vial-flake";
      flake = true;
    };
    sporeCultivationLabFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/spore-cultivation-lab-flake";
      flake = true;
    };
    bridgeInstanceFlake = {
      # This input will be provided by the caller (e.g., a top-level test or deployment)
      # It should be a flake that provides the bridge instance
      flake = true;
    };
    llmDataExtractorFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/llm-data-extractor-flake";
      flake = true;
    };
    projectSchedulerFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/project-scheduler-flake";
      flake = true;
    };
    llmApiWrapper = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/llm-api-wrapper";
      flake = true;
    };
    minizinc = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/minizinc-nix";
      flake = true;
    };
    narBridgeFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/hackathon/nar-bridge-flake";
      flake = true;
    };
    mctsSolanaFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/mcts-solana-flake";
      flake = true;
    };
    githubDataFetcherFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/github-data-fetcher-flake";
      flake = true;
    };
  };

  outputs =
    { self
    , nixpkgs
    , zosSporeVialFlake
    , sporeCultivationLabFlake
    , bridgeInstanceFlake
    , llmDataExtractorFlake
    , projectSchedulerFlake
    , llmApiWrapper
    , minizinc
    , narBridgeFlake
    , mctsSolanaFlake
    , githubDataFetcherFlake
    }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;

      # 1. Get the "memes in a vial" (ZOS Spore Vial)
      zosSporeVial = zosSporeVialFlake.packages.aarch64-linux.default;

      # 2. Cultivate the spore in the lab (Virtual Mycology)
      cultivatedSpore = sporeCultivationLabFlake.packages.aarch64-linux.default {
        inherit pkgs narBridgeFlake zosSporeVialFlake; # Pass the flake itself
      };

      # 3. Get Hackathon Results (from the bridge instance flake) and Extract Data
      hackathonResults = bridgeInstanceFlake.packages.aarch64-linux.default;
      extractedHackathonData = llmDataExtractorFlake.packages.aarch64-linux.default {
        inherit pkgs llmApiWrapper hackathonResults;
      };

      # 3.1. Fetch GitHub Data
      fetchedGitHubData = githubDataFetcherFlake.packages.aarch64-linux.default {
        inherit pkgs;
        githubApiWrapper = (builtins.getFlake (toString ../github-api-wrapper)).outputs; # Pass the dummy github-api-wrapper
        # sops-nix is not directly passed here, but would be used internally by githubDataFetcherFlake
      };

      # 4. Combine project state for the scheduler
      # This is a placeholder for combining cultivatedSpore, extractedHackathonData, and fetchedGitHubData
      combinedProjectState = pkgs.runCommand "combined-project-state"
        {
          inherit cultivatedSpore extractedHackathonData fetchedGitHubData;
        } ''
        mkdir -p $out
        echo "# Combined Project State" > $out/project-summary.md
        echo "## Cultivated Spore Insights" >> $out/project-summary.md
        cat "${cultivatedSpore}/cultivated-output/transformed-elements.json" >> $out/project-summary.md
        cat "${cultivatedSpore}/cultivated-output/self-description-copy.md" >> $out/project-summary.md
        echo "## Hackathon Data Insights" >> $out/project-summary.md
        cat "${extractedHackathonData}/extracted-data.json" >> $out/project-summary.md
        echo "## GitHub Data Insights" >> $out/project-summary.md
        cat "${fetchedGitHubData}/github-data.json" >> $out/project-summary.md
      '';

      # 5. Generate and Optimize Schedule
      finalSchedule = projectSchedulerFlake.packages.aarch64-linux.default {
        inherit pkgs llmApiWrapper minizinc;
        projectState = combinedProjectState;
      };

      # 6. Run MCTS with Solana Prediction Markets
      mctsSolanaOutput = mctsSolanaFlake.packages.aarch64-linux.default {
        inherit pkgs llmApiWrapper;
        projectSchedule = finalSchedule;
        mctsEngine = (builtins.getFlake (toString ../mcts-nix)).outputs; # Pass the dummy mcts-nix flake
        solanaTools = (builtins.getFlake (toString ../solana-nix)).outputs; # Pass the dummy solana-nix flake
      };
    in
    {
      packages.aarch64-linux.default = mctsSolanaOutput; # The final output is the MCTS Solana run
    };
}
