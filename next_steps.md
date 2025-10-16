1. We can search our index of flakes for names like this:
```bash
grep solana ~/nix/index/flake.nix.store  | cut -d/ -f5- | sort | uniq -c| sort -n
```
Output:
```
      1 2025/10/09/mcts-solana-flake/flake.nix
      1 2025/10/09/solana-nix/flake.nix
      1 2025/10/11/solana-integration/flake.nix
      1 2025/10/12/proof/004_nix_to_solana_translator/flake.nix
      1 x/10/09/mcts-solana-flake/flake.nix
      1 x/10/09/solana-nix/flake.nix
      1 x/10/11/solana-integration/flake.nix
      1 x/10/12/proof/004_nix_to_solana_translator/flake.nix
      1 x/10/12/proof/lib/solana/flake.nix
     13 proof/004_nix_to_solana_translator/flake.nix
     13 proof/lib/solana/flake.nix
     30 12/proof/lib/solana/flake.nix
     34 12/proof/004_nix_to_solana_translator/flake.nix
     38 09/mcts-solana-flake/flake.nix
     38 09/solana-nix/flake.nix
     38 11/solana-integration/flake.nix
    695 10/12/proof/lib/solana/flake.nix
    869 10/12/proof/004_nix_to_solana_translator/flake.nix
   1074 10/11/solana-integration/flake.nix
   1075 10/09/mcts-solana-flake/flake.nix
   1075 10/09/solana-nix/flake.nix
```