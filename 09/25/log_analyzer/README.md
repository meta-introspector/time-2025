# Log Analyzer

This Rust program analyzes telemetry logs to identify errors and potentially unfinished work.

## Features

- Parses JSON log entries.
- Identifies errors based on keywords (case-insensitive: "error", "fail", "exception", "denied", "refused", "timeout", "panic") in the log body or event name.
- Detects failed tool calls (`success: false`).
- Flags tool calls without an explicit `success` status as "unfinished work".

## Build and Run

To build the `log_analyzer` using Nix flakes and Naersk, navigate to the project root and run:

```bash
nix build .#log-analyzer
```

This will create a symlink `result` in the project root pointing to the built package. You can then run the analyzer with your log file:

```bash
./result/bin/log_analyzer --log-file <path/to/your/telemetry.log>
```

**Example:**

```bash
./result/bin/log_analyzer --log-file logs/telemetry.log
```

## Nix Flake Details

The `flake.nix` is configured to use `naersk` for Rust project building, ensuring reproducible builds. It explicitly uses `Cargo.lock` for dependency resolution.