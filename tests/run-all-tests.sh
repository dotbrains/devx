#!/usr/bin/env bash
set -euo pipefail

# Main Test Runner for Developer Environment Framework

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $*"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $*"
}

log_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  $*${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

run_test() {
    local test_name=$1
    local test_command=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    log_info "Running: $test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        log_success "$test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        log_error "$test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Start tests
log_section "Developer Environment Framework - Test Suite"

# Syntax and validation tests
log_section "Syntax & Validation Tests"
run_test "Ansible YAML syntax" "cd '$SCRIPT_DIR' && bash ansible-syntax-test.sh"
run_test "Shell script syntax" "cd '$SCRIPT_DIR' && bash shell-syntax-test.sh"
run_test "Configuration validation" "cd '$SCRIPT_DIR' && bash config-validation-test.sh"

# Unit tests
log_section "Unit Tests"
run_test "Base layer tests" "cd '$SCRIPT_DIR' && bash unit/test-base-layer.sh"
run_test "Organization layer tests" "cd '$SCRIPT_DIR' && bash unit/test-org-layer.sh"
run_test "FOSS package tests" "cd '$SCRIPT_DIR' && bash unit/test-foss-packages.sh"

# Integration tests
log_section "Integration Tests"
run_test "API integration tests" "cd '$SCRIPT_DIR' && bash integration/test-api.sh"
run_test "CLI integration tests" "cd '$SCRIPT_DIR' && bash integration/test-cli.sh"

# Report
log_section "Test Results"
echo "Total Tests:  $TOTAL_TESTS"
echo -e "${GREEN}Passed:       $PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed:       $FAILED_TESTS${NC}"
else
    echo -e "${GREEN}Failed:       $FAILED_TESTS${NC}"
fi

echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    log_success "All tests passed!"
    exit 0
else
    log_error "Some tests failed"
    exit 1
fi
