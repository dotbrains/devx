#!/usr/bin/env bash
set -euo pipefail

# Unit tests for organization layer

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ORG_DIR="$PROJECT_ROOT/packages/organization"

echo "Testing organization layer..."

# Test 1: Check organization directory structure
if [ ! -d "$ORG_DIR/app-store" ]; then
    echo "ERROR: App store directory not found"
    exit 1
fi

if [ ! -d "$ORG_DIR/foss-packages" ]; then
    echo "ERROR: FOSS packages directory not found"
    exit 1
fi

# Test 2: Check app store catalog
if [ ! -f "$ORG_DIR/app-store/catalog.yml" ]; then
    echo "ERROR: App store catalog not found"
    exit 1
fi

# Test 3: Validate app store has required apps
REQUIRED_APPS=("docker" "kubectl" "python" "nodejs")
CATALOG="$ORG_DIR/app-store/catalog.yml"

for app in "${REQUIRED_APPS[@]}"; do
    if ! grep -q "$app:" "$CATALOG"; then
        echo "ERROR: Required app '$app' not found in catalog"
        exit 1
    fi
done

# Test 4: Check FOSS packages structure
if [ ! -f "$ORG_DIR/foss-packages/registry/packages.yml" ]; then
    echo "ERROR: FOSS package registry not found"
    exit 1
fi

echo "Organization layer tests passed"
exit 0
