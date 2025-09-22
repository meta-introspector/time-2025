# MIB Crash Retrieval Protocol: Hyperspace Recovery of Crashed Processes

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the protocol for retrieving critical information and assessing system state after a hyperspace anomaly (system crash). It focuses on recovering data from Asciinema recordings and analyzing the Git repository to understand the pre-crash environment and facilitate recovery efforts.

## 2. Black Box Retrieval: Recovering Asciinema Recordings

In the event of a system crash, critical operational data may be preserved in Asciinema recordings. These "black boxes" provide invaluable telemetry of the pre-crash state. The `asciicast_processor` tool can be used to extract and analyze these recordings.

### 2.1 Locating Asciinema Recordings

Asciinema recordings are typically stored in `${HOME}/logs/gemini/` with filenames like `session_YYYYMMDD_HHMMSS.cast`. Identify the most recent recording prior to the hyperspace anomaly.

### 2.2 Processing Recordings with `asciicast_processor`

To process a recording, navigate to the `asciicast_processor` directory and use its binaries. For example, to strip ANSI escape codes or clean the output:

```bash
# Example: Strip ANSI escape codes from a recording
/data/data/com.termux.nix/files/home/pick-up-nix/source/github/meta-introspector/minizinc-introspector/crates/asciicast_processor/target/debug/test_strip <path_to_asciicast_file> > stripped_output.txt

# Example: Clean the recording output
/data/data/com.termux.nix/files/home/pick-up-nix/source/github/meta-introspector/minizinc-introspector/crates/asciicast_processor/target/debug/test_cleaning <path_to_asciicast_file> > cleaned_output.txt
```

*   **Purpose:** These tools help in making the raw Asciinema output readable and analyzable, providing insights into the commands executed and their outputs before the crash.

## 3. Initiating Contact: Assessing Git Repository State After a Hyperspace Anomaly

In the wake of a system crash—a sudden, unexpected hyperspace anomaly—it is paramount to immediately assess the state of the Git repository. This initial contact aims to identify any uncommitted changes or discrepancies, treating them as vital data packets adrift in the void.

### 3.1 Check Git Status

Execute the following command to view the current status of the Git working directory and staging area:

```bash
git status
```

*   **Purpose:** This command will show which files are untracked, modified, or staged for commit. It helps in understanding what changes were present at the time of the crash.

### 3.2 Document Git Differences

To get a detailed view of the changes in modified files, execute the following command:

```bash
git diff HEAD
```

*   **Purpose:** This command displays the differences between the working directory and the last commit (`HEAD`). This is essential for documenting the exact state of files that were being worked on.

### 3.3 Stage All Changes

If there are untracked or modified files that need to be preserved, stage them for commit.

```bash
git add .
```

*   **Purpose:** This command adds all changes in the current directory to the staging area. Use with caution, as it stages all changes, including potentially unwanted ones.

### 3.4 Document Staged Differences

To get a detailed view of the changes that have been staged, execute the following command:

```bash
git diff --staged
```

*   **Purpose:** This command displays the differences between the staging area and the last commit (`HEAD`). This is essential for reviewing what will be committed.

### 3.5 Record Output

Record the output of `git status`, `git diff HEAD`, `git add .` (if executed), and `git diff --staged` commands. This documentation is critical for post-crash analysis and recovery efforts.

## 4. Data Packet Analysis: Utilizing the Log Processor

To gain deeper insights into the system's state prior to the hyperspace anomaly, the `log_processor` tool can be used to analyze Gemini logs and Asciinema recordings. This tool helps in correlating events and understanding the sequence of operations.

### 4.1 Configuration

The `log_processor` relies on a `config.toml` file to specify the locations of the Gemini logs and Asciinema recordings. This file is located at `memetic_code/log_processor/config.toml`.

**Important Note:** The paths within `config.toml` must be accessible from the project's workspace. If the default paths are outside the workspace, they will need to be adjusted or the relevant log directories moved into an accessible location.

### 4.2 Executing the Log Processor

The `log_processor` can be executed using the `run_log_processor.sh` script located in the project root.

```bash
./run_log_processor.sh
```

*   **Purpose:** This script will list all files within the configured Gemini log and Asciinema recording directories, along with their modification timestamps. This information is crucial for identifying the most recent logs and recordings related to the crash.

### 4.3 Analyzing Output

The output of the `log_processor` will provide a chronological list of log and recording files. This can be used to:
*   Identify the last recorded actions before the crash.
*   Correlate events across different log types.
*   Pinpoint potential areas of interest for further investigation.

## 5. Related Documents

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)

