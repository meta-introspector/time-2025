#!/usr/bin/env bash

set -e

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

# Source the lib_git_submodule.sh library for git operations
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_git_submodule.sh"

SUBMODULE_PATH="$1"

if [ -z "$SUBMODULE_PATH" ]; then
  execute_cmd echo "Usage: $0 <submodule_path>"
  exit 1
fi

execute_cmd echo "Adding standard scripts to submodule: $SUBMODULE_PATH"

# Navigate into the submodule directory
execute_cmd pushd "$SUBMODULE_PATH"

# Create scripts directory
execute_cmd mkdir -p scripts

# Create build.sh
execute_cmd bash -c "cat << EOF > scripts/build.sh
#!/usr/bin/env bash

set -e

echo \"Building $(basename \"$PWD\")\"
cargo build --release
EOF"

# Create test.sh
execute_cmd bash -c "cat << EOF > scripts/test.sh
#!/usr/bin/env bash

set -e

echo \"Testing $(basename \"$PWD\")\"
cargo test
EOF"

# Make scripts executable
execute_cmd chmod +x scripts/build.sh scripts/test.sh

# Add and commit changes within the submodule
execute_cmd git add scripts/build.sh scripts/test.sh
execute_cmd git commit -m "CRQ-008: Add standard build.sh and test.sh scripts"

# Navigate back to the original directory
execute_cmd popd

execute_cmd echo "Standard scripts added to submodule: $SUBMODULE_PATH"

