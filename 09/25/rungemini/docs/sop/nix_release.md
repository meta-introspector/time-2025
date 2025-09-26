# Standard Operating Procedure: Releasing Nix Packages with NPM Dependencies in Constrained Environments

This document outlines a robust procedure for packaging Node.js applications with NPM dependencies into Nix derivations, specifically addressing challenges encountered in older Nix environments or those with strict sandboxing policies where direct `npm install` within the Nix build process fails.

## Problem Statement

In environments where Nix's experimental features (flakes) are not fully supported, or where `buildNpmPackage` consistently fails to resolve NPM dependencies due to network restrictions (e.g., `npm error code ENOTCACHED`, `ENOENT /homeless-shelter`), a direct pure-Nix build of Node.js projects with NPM dependencies can be challenging. This SOP provides a workaround to achieve reproducibility by pre-packaging dependencies.

## Assumptions

*   The target Nix environment is older or has limited flake support.
*   Direct network access during Nix builds for `npm install` is problematic.
*   The project uses `package.json` and `package-lock.json` for dependency management.

## Solution: Manual Tarball Creation with Pre-installed `node_modules`

This approach involves preparing the Node.js project with its `node_modules` outside of the Nix build environment, then packaging this complete source into a tarball, which Nix can then `fetchurl` and build. This bypasses the problematic `npm install` step within the Nix sandbox.

## Procedure

### Step 1: Prepare the Node.js Project (Outside Nix)

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url> <project-name>
    cd <project-name>
    ```
    *Example:*
    ```bash
    git clone https://github.com/google-gemini/gemini-cli gemini-cli-source
    cd gemini-cli-source
    ```

2.  **Install NPM dependencies:**
    Ensure you have Node.js and NPM installed on your host system.
    ```bash
    npm install
    ```
    This step will download and install all `node_modules` into the `gemini-cli-source` directory.

3.  **Clean up (Optional but Recommended):**
    Remove any unnecessary files that are not part of the final build, such as `.git` directories, build artifacts, or temporary files.
    ```bash
    rm -rf .git
    # Add other cleanup commands as needed
    ```

4.  **Create a tarball of the prepared source:**
    Navigate one level up from your project directory and create a compressed tarball.
    ```bash
    cd ..
    tar -czvf <project-name>-with-deps.tar.gz <project-name>
    ```
    *Example:*
    ```bash
    tar -czvf gemini-cli-0.3.4-with-deps.tar.gz gemini-cli-source
    ```
    Note the exact filename of the tarball, as you will need it for the Nix expression.

### Step 2: Create the Nix Derivation (`default.nix`)

Create a `default.nix` file in your Nix project directory with the following structure. This derivation will fetch the tarball created in Step 1 and then build the application.

```nix
let
  # Import nixpkgs
  pkgs = import (fetchTarball "https://github.com/meta-introspector/nixpkgs/archive/feature/CRQ-016-nixify.tar.gz") {};

  # Define the source tarball with pre-installed node_modules
  # Replace 'path/to/your/tarball.tar.gz' with the actual path to your tarball
  # Replace 'sha256-YOUR_TARBALL_SHA256_HASH=' with the actual SHA256 hash of your tarball
  preparedSource = pkgs.fetchurl {
    url = "file:///path/to/your/tarball.tar.gz"; # IMPORTANT: Use 'file://' for local paths
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  };

in
  pkgs.stdenv.mkDerivation {
    pname = "gemini-cli";
    version = "0.3.4"; # Match your project's version
    src = preparedSource;

    # No need for npm install here, as node_modules are already in src
    # Ensure nodejs is available for running the application if needed
    buildInputs = [ pkgs.nodejs pkgs.git pkgs.ripgrep ];

    # The build phase might be minimal if the project is already built
    # or if the installPhase handles everything. 
    # For gemini-cli, the original flake.nix had a preConfigure script
    # and specific install steps. Adapt these as necessary.
    preConfigure = ''
      # If your project has a 'scripts/generate-git-info.sh', include it.
      # Otherwise, remove this line.
      ${pkgs.bash}/bin/bash ./scripts/generate-git-info.sh "dirty"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/{bin,share/gemini-cli}

      # Copy the entire source directory (which now includes node_modules)
      cp -r ./* $out/share/gemini-cli/

      # Recreate symlinks for the CLI executable
      ln -s $out/share/gemini-cli/packages/cli/dist/index.js $out/bin/gemini
      chmod +x "$out/bin/gemini"

      runHook postInstall
    '';
  }
```