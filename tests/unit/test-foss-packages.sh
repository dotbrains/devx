#!/usr/bin/env bash
set -euo pipefail

# Unit tests for FOSS packages

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOSS_DIR="$PROJECT_ROOT/packages/organization/foss-packages"

echo "Testing FOSS packages..."

# Test 1: Check FOSS directory structure
REQUIRED_DIRS=(
    "$FOSS_DIR/registry"
    "$FOSS_DIR/security"
    "$FOSS_DIR/licenses"
    "$FOSS_DIR/scripts"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "ERROR: Required directory not found: $dir"
        exit 1
    fi
done

# Test 2: Check required scripts are executable
SCRIPTS=(
    "$FOSS_DIR/scripts/add-package.sh"
    "$FOSS_DIR/scripts/security-scan.sh"
    "$FOSS_DIR/scripts/approve-package.sh"
    "$FOSS_DIR/scripts/sync-mirrors.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ ! -x "$script" ]; then
        echo "ERROR: Script not executable: $script"
        exit 1
    fi
done

# Test 3: Validate package registry
REGISTRY="$FOSS_DIR/registry/packages.yml"
if python3 -c "import yaml" 2>/dev/null; then
    if ! python3 -c "import yaml; yaml.safe_load(open('$REGISTRY'))" 2>/dev/null; then
        echo "ERROR: Invalid package registry YAML"
        exit 1
    fi
else
    echo "PyYAML not installed, skipping YAML validation"
fi

# Test 4: Check licenses configuration
LICENSES="$FOSS_DIR/licenses/approved-licenses.yml"
if ! grep -q "approved_licenses:" "$LICENSES"; then
    echo "ERROR: approved_licenses not found in licenses config"
    exit 1
fi

echo "FOSS packages tests passed"
exit 0
