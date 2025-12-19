#!/usr/bin/env bash
set -euo pipefail

# Test shell script syntax

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Testing shell script syntax..."

# Find all shell scripts
SCRIPTS=$(find "$PROJECT_ROOT" -name "*.sh" -type f 2>/dev/null || true)

if [ -z "$SCRIPTS" ]; then
    echo "No scripts found"
    exit 0
fi

ERRORS=0

for script in $SCRIPTS; do
    if ! bash -n "$script" 2>/dev/null; then
        echo "Syntax error in: $script"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo "Found $ERRORS syntax error(s)"
    exit 1
fi

echo "All shell scripts have valid syntax"
exit 0
