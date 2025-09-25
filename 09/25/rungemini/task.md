task :
run gemini in nix for reproduciblity.
1. allow for access to gemini for network access to certain urls only.
2. use nix to run it.
3. run gemeinicli.
~/gemini-cli/ -> ~/nix/vendor/external/gemini-cli/ has a flake.nix
use that for a starting point.
3. see template ~/nix/ai-ml-zk-ops/flakes/repo-data-flake/repo-data-flake