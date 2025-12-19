#!/usr/bin/env bash
set -euo pipefail

# Integration tests for FOSS CLI

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLI_DIR="$PROJECT_ROOT/packages/organization/foss-packages/cli"

echo "Testing CLI integration..."

# Test 1: Check CLI directory structure
if [ ! -f "$CLI_DIR/foss-cli" ]; then
    echo "ERROR: foss-cli executable not found"
    exit 1
fi

if [ ! -d "$CLI_DIR/foss_cli" ]; then
    echo "ERROR: foss_cli package directory not found"
    exit 1
fi

# Test 2: Check CLI is executable
if [ ! -x "$CLI_DIR/foss-cli" ]; then
    echo "ERROR: foss-cli is not executable"
    exit 1
fi

# Test 3: Check Python syntax for CLI
PYTHON_FILES=$(find "$CLI_DIR/foss_cli" -name "*.py" -type f 2>/dev/null || true)

for py_file in $PYTHON_FILES; do
    if ! python3 -m py_compile "$py_file" 2>/dev/null; then
        echo "ERROR: Python syntax error in: $py_file"
        exit 1
    fi
done

# Test 4: Check setup.py exists
if [ ! -f "$CLI_DIR/setup.py" ]; then
    echo "ERROR: setup.py not found"
    exit 1
fi

# Test 5: Check all command modules exist
COMMANDS=(
    "$CLI_DIR/foss_cli/commands/search.py"
    "$CLI_DIR/foss_cli/commands/info.py"
    "$CLI_DIR/foss_cli/commands/security.py"
    "$CLI_DIR/foss_cli/commands/submit.py"
)

for cmd in "${COMMANDS[@]}"; do
    if [ ! -f "$cmd" ]; then
        echo "ERROR: CLI command not found: $cmd"
        exit 1
    fi
done

echo "CLI integration tests passed"
exit 0
