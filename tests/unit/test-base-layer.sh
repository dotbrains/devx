#!/usr/bin/env bash
set -euo pipefail

# Unit tests for base layer

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BASE_DIR="$PROJECT_ROOT/packages/base"

echo "Testing base layer..."

# Test 1: Check base directory structure
if [ ! -d "$BASE_DIR/images" ]; then
    echo "ERROR: Base images directory not found"
    exit 1
fi

if [ ! -d "$BASE_DIR/ansible" ]; then
    echo "ERROR: Base ansible directory not found"
    exit 1
fi

# Test 2: Check required files exist
REQUIRED_FILES=(
    "$BASE_DIR/README.md"
    "$BASE_DIR/ansible/group_vars/all.yml"
    "$BASE_DIR/ansible/playbooks/base-setup.yml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "ERROR: Required file not found: $file"
        exit 1
    fi
done

# Test 3: Validate base configuration
if ! grep -q "base_security_hardening:" "$BASE_DIR/ansible/group_vars/all.yml"; then
    echo "ERROR: base_security_hardening not found in base config"
    exit 1
fi

echo "Base layer tests passed"
exit 0
