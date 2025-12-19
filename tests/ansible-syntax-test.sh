#!/usr/bin/env bash
set -euo pipefail

# Test Ansible YAML syntax

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Testing Ansible playbook syntax..."

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
    echo "ansible-playbook not found, skipping Ansible syntax tests"
    exit 0
fi

# Find all Ansible playbooks
PLAYBOOKS=$(find "$PROJECT_ROOT/packages" -name "*.yml" -path "*/playbooks/*" 2>/dev/null || true)

if [ -z "$PLAYBOOKS" ]; then
    echo "No playbooks found"
    exit 0
fi

ERRORS=0

for playbook in $PLAYBOOKS; do
    if ! ansible-playbook --syntax-check "$playbook" > /dev/null 2>&1; then
        echo "Syntax error in: $playbook"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo "Found $ERRORS syntax error(s)"
    exit 1
fi

echo "All Ansible playbooks have valid syntax"
exit 0
