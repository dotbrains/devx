#!/usr/bin/env bash
set -euo pipefail

# Validate YAML configuration files

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Validating YAML configuration files..."

# Check if PyYAML is available
if ! python3 -c "import yaml" 2>/dev/null; then
    echo "PyYAML not found, skipping YAML validation tests"
    exit 0
fi

# Find all YAML files in group_vars
YAML_FILES=$(find "$PROJECT_ROOT/packages" -name "*.yml" -path "*/group_vars/*" 2>/dev/null || true)

if [ -z "$YAML_FILES" ]; then
    echo "No YAML config files found"
    exit 0
fi

ERRORS=0

for yaml_file in $YAML_FILES; do
    # Basic YAML syntax check using python
    if ! python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
        echo "Invalid YAML in: $yaml_file"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo "Found $ERRORS validation error(s)"
    exit 1
fi

echo "All YAML configurations are valid"
exit 0
