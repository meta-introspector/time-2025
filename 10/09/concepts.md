## Lattice of Functions: NAR Bridge Operations

This section details the functions provided by the `nar-bridge-flake` and their underlying Nix command implementations, illustrating their roles in managing NAR archives.

### `nar-bridge-flake` Functions

*   **`lib.createNar`**:
    *   **Purpose:** Serializes a given Nix store path into a NAR archive (`.nar` file).
    *   **Inputs:** `name` (string, for the NAR filename), `path` (Nix store path to archive).
    *   **Underlying Command:** `nix-store --export "$path" > "$out/${name}.nar"`
    *   **Output:** A derivation containing the generated `.nar` file.

*   **`lib.restoreNar`**:
    *   **Purpose:** Restores a NAR archive (`.nar` file) into the Nix store and provides the path to the restored content.
    *   **Inputs:** `name` (string, for the restored path's name), `narFile` (path to the `.nar` file).
    *   **Underlying Command:** `nix-nar-unpack --file "$narFile" --to "$out/restored-content"`
    *   **Output:** A derivation containing the restored content, with the path to the content written to `$out/restored-path`.

### Relationship to Nix Commands

The `nar-bridge-flake` acts as an abstraction layer over specific Nix commands, providing a consistent interface for NAR operations within Nix flakes.

```mermaid
graph TD
    subgraph nar-bridge-flake API
        A[lib.createNar] -->|Uses| B[nix-store --export]
        C[lib.restoreNar] -->|Uses| D[nix-nar-unpack]
    end

    subgraph Nix Commands
        B
        D
    end

    subgraph Nix Store Operations
        E[Nix Store Path] -->|Input to| B
        D -->|Outputs| F[Restored Content (Nix Store Path)]
    end
```