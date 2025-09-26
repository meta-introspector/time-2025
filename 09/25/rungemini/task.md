task :
run gemini in nix for reproduciblity.
1. allow for access to gemini for network access to certain urls only.
2. use nix to run it.
3. run gemeinicli.
~/gemini-cli/ -> ~/nix/vendor/external/gemini-cli/flake.nix
use that for a starting point.
3. see template ~/nix/ai-ml-zk-ops/flakes/repo-data-flake/flake.nix

- access granted to  ~/nix/vendor/external/gemini-cli/,
- read and copy files as needed into here.
- do not delete anything
- if you have edit errors, refactor and rewrite into smaller files.
- version file names instead of deleting.

Status:
- Read gemini-cli/flake.nix and repo-data-flake/flake.nix.
- Attempted to run with `nix run .#gemini-runner` and `nix develop` but encountered errors related to dirty Git tree and flake resolution.
- Attempted to enable experimental features with `NIX_CONFIG` but `--flake` flag is not recognized.
- Conclusion: The current Nix environment does not support flakes directly. Converted `flake.nix` to `default.nix`.
- Encountered `npm error code ENOTCACHED` due to network restrictions during `npm install` within `buildNpmPackage`.
- Attempted to use `buildNpmDeps` but `error: attribute 'buildNpmDeps' missing` in the current `nixpkgs`.
- Attempted to manually run `npm install` in `preBuild` with `dontNpmInstall = true;` and various `npm` environment variables, but still failed with `ENOENT` related to `/homeless-shelter`.
- Attempted to use a `flake.nix` to override `npmDepsHash` but `nix build` without `--flake` still failed to resolve the flake's source in a dirty Git repository.
- Final Decision: The current Nix environment's limitations (no direct flake support, `npm install` issues in sandbox, dirty Git repository) make a pure Nix solution infeasible without upgrading Nix or modifying the `gemini-cli` source. Proceeding with manual workaround: clone `gemini-cli`, run `npm install` outside of Nix, create a tarball of the result (including `node_modules`), and then use `fetchurl` and `stdenv.mkDerivation` in `default.nix` to package it.
- Documented the challenges and the manual tarball workaround in `docs/sop/nix_release.md`.
- **Current Blocker:** I cannot execute the manual steps (cloning, `npm install`, tarball creation) outside the designated workspace. These steps must be performed by the user. Please provide the absolute path to the created tarball and its SHA256 hash to proceed with Step 2.