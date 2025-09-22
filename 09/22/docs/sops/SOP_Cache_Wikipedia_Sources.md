# SOP: Caching Wikipedia Sources

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the process for caching Wikipedia articles locally. This is essential for creating reproducible build environments and ensuring that LLM context generation processes have stable and offline access to Wikipedia content.

## 2. Scope

This SOP applies to anyone needing to cache Wikipedia articles for use within the project's Nix-based build system or for local development and testing.

## 3. Prerequisites

-   A working Bash environment.
-   `curl` installed for fetching web content.
-   `sed` for sanitizing filenames.
-   `lib_exec.sh` sourced for `execute_cmd` function.

## 4. Procedure

The `scripts/cache_wikipedia_sources.sh` script automates the process of downloading specified Wikipedia articles and organizing them into a local cache.

### 4.1. Script Location

The script is located at: `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/cache_wikipedia_sources.sh`

### 4.2. Execution

To run the script, execute it from the project root:

```bash
/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/cache_wikipedia_sources.sh
```

### 4.3. Script Functionality

The script performs the following steps:

1.  **Ensures Cache Directory Exists**: It calls `setup_wikipedia_cache.sh` to prepare the `wikipedia_cache/` directory.
2.  **Clears/Creates Articles List**: It initializes or clears `wikipedia_articles.md`, which will log the cached URLs and their corresponding local file paths.
3.  **Iterates Through Wikipedia URLs**: It loops through a predefined list of Wikipedia article URLs.
4.  **Sanitizes Filenames**: For each URL, it sanitizes the URL to create a clean, valid filename for the local HTML file (e.g., `Online_Encyclopedia_of_Integer_Sequences.html`).
5.  **Fetches Content**: It uses `curl` to download the HTML content of each Wikipedia article and saves it to the `wikipedia_cache/` directory.
6.  **Logs Cached Articles**: It appends a markdown-formatted link to `wikipedia_articles.md` for each successfully cached article.
7.  **Completion Message**: It prints a message indicating the completion of the caching process and advises reviewing `wikipedia_articles.md` and the `wikipedia_cache/` directory.

## 5. Customization

To customize the list of Wikipedia articles to be cached, edit the `WIKI_URLS` array directly within the `scripts/cache_wikipedia_sources.sh` file.

## 6. Verification

After execution, verify the cached content by:
-   Checking the contents of `wikipedia_articles.md` for a list of cached URLs and their paths.
-   Inspecting the `wikipedia_cache/` directory to ensure the HTML files have been downloaded.

## 7. Related Files

-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh`: Provides the `execute_cmd` function.
-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/setup_wikipedia_cache.sh`: Script to set up the cache directory.
-   `wikipedia_cache/`: Directory where the HTML files are stored.
-   `wikipedia_articles.md`: Markdown file listing the cached articles.
