#!/usr/bin/env bash
set -euo pipefail

# Integration tests for FOSS API

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
API_DIR="$PROJECT_ROOT/packages/organization/foss-packages/api"

echo "Testing API integration..."

# Test 1: Check API directory structure
if [ ! -f "$API_DIR/app.py" ]; then
    echo "ERROR: API app.py not found"
    exit 1
fi

if [ ! -d "$API_DIR/versions" ]; then
    echo "ERROR: API versions directory not found"
    exit 1
fi

# Test 2: Check Python syntax
PYTHON_FILES=$(find "$API_DIR" -name "*.py" -type f 2>/dev/null || true)

for py_file in $PYTHON_FILES; do
    if ! python3 -m py_compile "$py_file" 2>/dev/null; then
        echo "ERROR: Python syntax error in: $py_file"
        exit 1
    fi
done

# Test 3: Check requirements.txt exists
if [ ! -f "$API_DIR/requirements.txt" ]; then
    echo "ERROR: requirements.txt not found"
    exit 1
fi

# Test 4: Validate API versions exist
if [ ! -d "$API_DIR/versions/v1" ]; then
    echo "ERROR: API v1 not found"
    exit 1
fi

echo "API integration tests passed"
exit 0
