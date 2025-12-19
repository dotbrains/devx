# Test Infrastructure

This directory contains the test suite for the Developer Environment Framework.

## Running Tests

### Run All Tests
```bash
# From project root
make test

# Or directly
./tests/run-all-tests.sh
```

### Run Specific Test Categories
```bash
# Syntax & Validation Tests
./tests/ansible-syntax-test.sh
./tests/shell-syntax-test.sh
./tests/config-validation-test.sh

# Unit Tests
./tests/unit/test-base-layer.sh
./tests/unit/test-org-layer.sh
./tests/unit/test-foss-packages.sh

# Integration Tests
./tests/integration/test-api.sh
./tests/integration/test-cli.sh
```

## Test Categories

### Syntax & Validation Tests
These tests validate the correctness of configuration files and scripts without executing them.

- **ansible-syntax-test.sh**: Validates Ansible playbook syntax
  - Requires: `ansible-playbook` command
  - Gracefully skips if ansible is not installed

- **shell-syntax-test.sh**: Validates shell script syntax
  - Uses `bash -n` to check syntax
  - Tests all `.sh` files in the project

- **config-validation-test.sh**: Validates YAML configuration files
  - Requires: `python3` with `PyYAML` module
  - Gracefully skips if PyYAML is not installed
  - Tests all YAML files in `group_vars/` directories

### Unit Tests
These tests verify individual components in isolation.

- **test-base-layer.sh**: Tests base layer structure and configuration
  - Verifies directory structure
  - Checks required files exist
  - Validates security hardening configuration

- **test-org-layer.sh**: Tests organization layer components
  - Verifies app store catalog
  - Checks FOSS packages structure
  - Validates required apps are present

- **test-foss-packages.sh**: Tests FOSS package ecosystem
  - Checks directory structure
  - Verifies scripts are executable
  - Validates package registry (requires PyYAML)
  - Checks license configuration

### Integration Tests
These tests verify how components work together.

- **test-api.sh**: Tests FOSS API integration
  - Verifies API directory structure
  - Checks Python syntax for all API files
  - Validates requirements.txt exists
  - Ensures API versions are present

- **test-cli.sh**: Tests FOSS CLI integration
  - Verifies CLI directory structure
  - Checks CLI is executable
  - Validates Python syntax for all CLI files
  - Ensures all command modules exist

## Dependencies

### Required
- `bash`: For running shell scripts
- `python3`: For Python syntax validation

### Optional
- `ansible-playbook`: For Ansible playbook syntax checking
  - Install: `pip install ansible`
  - Tests gracefully skip if not available

- `PyYAML`: For YAML validation
  - Install: `pip install pyyaml`
  - Tests gracefully skip if not available

## Test Output

Tests provide colored output:
- **[PASS]**: Test passed successfully (green)
- **[FAIL]**: Test failed (red)
- **[INFO]**: Informational message (cyan)

The test runner displays:
- Progress for each test
- Summary with total/passed/failed counts
- Exit code 0 for success, 1 for failure

## Adding New Tests

### Add a Syntax/Validation Test
1. Create test script in `tests/`
2. Make it executable: `chmod +x tests/your-test.sh`
3. Add it to `run-all-tests.sh` in the "Syntax & Validation" section

### Add a Unit Test
1. Create test script in `tests/unit/`
2. Make it executable: `chmod +x tests/unit/your-test.sh`
3. Add it to `run-all-tests.sh` in the "Unit Tests" section

### Add an Integration Test
1. Create test script in `tests/integration/`
2. Make it executable: `chmod +x tests/integration/your-test.sh`
3. Add it to `run-all-tests.sh` in the "Integration Tests" section

## Test Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Description of test

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Testing something..."

# Check for optional dependencies
if ! command -v some-tool &> /dev/null; then
    echo "some-tool not found, skipping tests"
    exit 0
fi

# Test logic here
if [ some_condition ]; then
    echo "ERROR: Something failed"
    exit 1
fi

echo "Tests passed"
exit 0
```

## Continuous Integration

The test suite is designed to work in CI/CD environments:
- All tests exit with proper codes (0 for success, 1 for failure)
- Optional dependencies are handled gracefully
- Tests can run without user interaction
- Output is suitable for CI log parsing

Example CI configuration:
```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: |
          pip install ansible pyyaml
      - name: Run tests
        run: make test
```
