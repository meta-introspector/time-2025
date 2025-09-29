# Gemini CLI Tool Specification for New Project Functionalities

This document outlines how the newly introduced or significantly modified functionalities within the project could be exposed as callable tools for the Gemini CLI agent. It also provides a general understanding of how such tools are integrated into the `gemini-cli` environment.

## General Process for Integrating New Functionalities as Gemini CLI Tools:

To integrate a new functionality (e.g., a Rust function, a shell script, a binary) as a callable tool for the Gemini CLI agent, the following steps are typically involved:

1.  **Identify Core Functionality**: Determine the specific action or query the tool should perform.
2.  **Define Tool Signature**: Create a clear definition including:
    *   **`name`**: A unique, descriptive name for the tool (e.g., `extract_urls_from_log`).
    *   **`description`**: A concise explanation of what the tool does.
    *   **`parameters`**: A list of input arguments the tool requires, including their types, descriptions, and whether they are optional.
    *   **`output`**: A description of the expected output format and content.
3.  **Implement Tool Adapter**: Write a small adapter (often in Python, as the Gemini agent is Python-based) that bridges the Gemini tool definition to the actual underlying functionality (e.g., calling a Rust binary, executing a shell script, invoking a Python function).
4.  **Register Tool with Gemini CLI**: The tool definition and its adapter are registered with the `gemini-cli` framework, making it discoverable and callable by the agent.
5.  **Security and Permissions**: Ensure the tool operates within appropriate security contexts and has necessary permissions.

## Proposed Gemini CLI Tools for New Project Functionalities:

### 1. `extract_urls_from_log`

*   **Description**: Extracts all URLs from a specified log file or provided text content. Leverages the `url_extractor` module in `09/25/log_analyzer/src/url_extractor.rs`.
*   **Parameters**:
    *   `log_file_path` (string, optional): The absolute path to the log file from which to extract URLs. If not provided, `log_content` must be provided.
    *   `log_content` (string, optional): The raw text content from which to extract URLs. If not provided, `log_file_path` must be provided.
*   **Output**: A list of strings, where each string is a unique URL found in the input.
*   **Example Usage (Conceptual)**:
    ```python
    print(default_api.extract_urls_from_log(log_file_path='/path/to/telemetry.log'))
    print(default_api.extract_urls_from_log(log_content='Some text with a URL like https://example.com'))
    ```

### 2. `run_telemetry_manager`

*   **Description**: Executes the `telemetry_manager` binary with specified arguments. This tool would be used to trigger telemetry processing or management tasks.
*   **Parameters**:
    *   `args` (list of strings, optional): A list of command-line arguments to pass to the `telemetry_manager` binary.
*   **Output**: The standard output and standard error of the `telemetry_manager` binary execution.
*   **Example Usage (Conceptual)**:
    ```python
    print(default_api.run_telemetry_manager(args=['--process', 'all']))
    print(default_api.run_telemetry_manager(args=['--config', '/path/to/config.toml']))
    ```

### 3. `get_log_sources`

*   **Description**: Finds and lists paths to log files (defaulting to `telemetry.log`) within specified directories. This wraps the `getsources.sh` script.
*   **Parameters**:
    *   `output_file` (string, optional): The name of the file to write the list of sources to. Defaults to `sources.txt`.
    *   `target_file` (string, optional): The name of the log file to search for. Defaults to `telemetry.log`.
    *   `search_paths` (list of strings, optional): A list of absolute paths to directories to search within. Defaults to `["$HOME/gemini-cli/.gemini/", "../../"]`.
*   **Output**: The content of the `output_file` (list of paths) after the script has run.
*   **Example Usage (Conceptual)**:
    ```python
    print(default_api.get_log_sources())
    print(default_api.get_log_sources(target_file='error.log', search_paths=['/var/log/']))
    ```

### 4. `setup_today_symlinks`

*   **Description**: Sets up symbolic links for the current month and today's directory within the Nix environment and changes the current working directory. This wraps the `today.sh` script.
*   **Parameters**: None (the script derives paths from the current date).
*   **Output**: The standard output and standard error of the `today.sh` script, which includes the full path to today's directory.
*   **Example Usage (Conceptual)**:
    ```python
    print(default_api.setup_today_symlinks())
    ```

### 5. `check_submodule_status`

*   **Description**: Checks the status of Git submodules and updates them. This is a general Git operation but is relevant due to recent submodule changes.
*   **Parameters**: None.
*   **Output**: The output of `git submodule status` and `git submodule update --init --recursive`.
*   **Example Usage (Conceptual)**:
    ```python
    print(default_api.check_submodule_status())
    ```

---
**Note**: These are conceptual tool definitions. Actual implementation would require creating corresponding Python functions that execute the underlying Rust binaries or shell scripts and handle their input/output appropriately for the Gemini CLI environment.
