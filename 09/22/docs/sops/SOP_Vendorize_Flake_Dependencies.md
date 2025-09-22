# SOP: Vendorize Flake Dependencies

This SOP describes the process of vendorizing external Nix flake dependencies. Vendorizing is the process of bringing external dependencies into our own source control, which helps to improve build reproducibility and reduce our reliance on external services.

## Workflow

The workflow consists of the following steps:

1.  **Generate a list of flake URLs:** This is done using the `scripts/nix_urls.sh` script. This script finds all `flake.nix` files in the project, extracts the URLs, and saves them to the `index/flake_nix_urls_with_filenames.txt` file.

2.  **Generate a script to update the URLs:** This is done using the `scripts/vendorize_flake_urls.sh` script. This script reads the `index/flake_nix_urls_with_filenames.txt` file and generates a new script called `scripts/apply_vendorized_urls.sh`. This new script contains `sed` commands to replace the original URLs with our own `meta-introspector` URLs.

3.  **Apply the URL updates:** This is done by running the `scripts/apply_vendorized_urls.sh` script. This script will update all the `flake.nix` files in the project.

4.  **Update the `flake.lock` file:** This is done using the `scripts/update_flake_lock.sh` script. This script reads the `index/flake_nix_urls_with_filenames.txt` file and generates a single `nix flake lock` command with all the necessary `--update-input` arguments.

## Scripts

*   `scripts/nix_urls.sh`: Generates a list of all flake URLs in the project.
*   `scripts/vendorize_flake_urls.sh`: Generates a script to update the flake URLs.
*   `scripts/apply_vendorized_urls.sh`: Applies the URL updates to the `flake.nix` files.
*   `scripts/update_flake_lock.sh`: Updates the `flake.lock` file.

## Script Quality Assurance

Before executing any of the scripts mentioned in this SOP, always run `shellcheck` on them to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](../../docs/memos/Shellcheck_Always_After_Changes.md) for details.

```bash
shellcheck scripts/nix_urls.sh
shellcheck scripts/vendorize_flake_urls.sh
shellcheck scripts/apply_vendorized_urls.sh
shellcheck scripts/update_flake_lock.sh
```
