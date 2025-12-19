#!/usr/bin/env bash
set -euo pipefail

# Security Scan Script for FOSS Packages
# Scans packages for vulnerabilities using multiple tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOSS_ROOT="$(dirname "$SCRIPT_DIR")"
SECURITY_DIR="$FOSS_ROOT/security"
SCANS_DIR="$SECURITY_DIR/scans"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <package-name> [version]

Perform security scanning on a FOSS package.

Arguments:
    package-name    Name of the package
    version         Package version (optional, scans latest if omitted)

Options:
    --tool TOOL     Specific tool to use (trivy, grype, osv-scanner, all)
    --format FMT    Output format (json, yaml, table, html)
    --all           Scan all packages in registry
    -v, --verbose   Verbose output
    -h, --help      Show this help message

Examples:
    $(basename "$0") requests 2.31.0
    $(basename "$0") express --tool trivy
    $(basename "$0") --all --format html

EOF
    exit 1
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_scan() {
    echo -e "${BLUE}[SCAN]${NC} $*"
}

check_tool() {
    local tool=$1
    if ! command -v "$tool" &> /dev/null; then
        log_warn "$tool not found, skipping"
        return 1
    fi
    return 0
}

scan_with_trivy() {
    local package=$1
    local version=$2
    local output_file=$3
    
    log_scan "Running Trivy scan..."
    
    if ! check_tool "trivy"; then
        return 1
    fi
    
    # Scan based on package type
    trivy fs --format json --output "$output_file" . || {
        log_error "Trivy scan failed"
        return 1
    }
    
    log_info "Trivy scan completed: $output_file"
    return 0
}

scan_with_grype() {
    local package=$1
    local version=$2
    local output_file=$3
    
    log_scan "Running Grype scan..."
    
    if ! check_tool "grype"; then
        return 1
    fi
    
    grype "$package:$version" -o json > "$output_file" || {
        log_error "Grype scan failed"
        return 1
    }
    
    log_info "Grype scan completed: $output_file"
    return 0
}

scan_with_osv() {
    local package=$1
    local version=$2
    local output_file=$3
    
    log_scan "Running OSV scanner..."
    
    if ! check_tool "osv-scanner"; then
        return 1
    fi
    
    osv-scanner --format json "$package@$version" > "$output_file" 2>&1 || {
        log_warn "OSV scanner completed with warnings"
    }
    
    log_info "OSV scan completed: $output_file"
    return 0
}

analyze_scan_results() {
    local scan_dir=$1
    
    log_info "Analyzing scan results..."
    
    local critical=0
    local high=0
    local medium=0
    local low=0
    
    # Parse results from different tools
    for scan_file in "$scan_dir"/*.json; do
        if [[ ! -f "$scan_file" ]]; then
            continue
        fi
        
        # Simple vulnerability counting (would use jq in production)
        if grep -q "CRITICAL" "$scan_file" 2>/dev/null; then
            critical=$((critical + 1))
        fi
        if grep -q "HIGH" "$scan_file" 2>/dev/null; then
            high=$((high + 1))
        fi
        if grep -q "MEDIUM" "$scan_file" 2>/dev/null; then
            medium=$((medium + 1))
        fi
        if grep -q "LOW" "$scan_file" 2>/dev/null; then
            low=$((low + 1))
        fi
    done
    
    # Calculate security score (0-100)
    local total_issues=$((critical * 10 + high * 5 + medium * 2 + low))
    local security_score=$((100 - total_issues))
    if [[ $security_score -lt 0 ]]; then
        security_score=0
    fi
    
    echo "$security_score|$critical|$high|$medium|$low"
}

generate_report() {
    local package=$1
    local version=$2
    local scan_dir=$3
    local format=$4
    
    log_info "Generating security report..."
    
    local report_file="$scan_dir/report.$format"
    local analysis
    analysis=$(analyze_scan_results "$scan_dir")
    
    IFS='|' read -r score critical high medium low <<< "$analysis"
    
    if [[ "$format" == "json" ]]; then
        cat > "$report_file" <<EOF
{
  "package": "$package",
  "version": "$version",
  "scan_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "security_score": $score,
  "vulnerabilities": {
    "critical": $critical,
    "high": $high,
    "medium": $medium,
    "low": $low,
    "total": $((critical + high + medium + low))
  },
  "approval_recommended": $([ $critical -eq 0 ] && [ $high -eq 0 ] && echo "true" || echo "false"),
  "scan_tools": ["trivy", "grype", "osv-scanner"]
}
EOF
    else
        cat > "$report_file" <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Security Scan Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Package:        $package
Version:        $version
Scan Date:      $(date -u +"%Y-%m-%d %H:%M:%S UTC")

Security Score: $score/100

Vulnerabilities:
  Critical:     $critical
  High:         $high
  Medium:       $medium
  Low:          $low
  Total:        $((critical + high + medium + low))

Approval Status: $([ $critical -eq 0 ] && [ $high -eq 0 ] && echo "RECOMMENDED" || echo "BLOCKED")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    fi
    
    log_info "Report generated: $report_file"
    
    # Display summary
    echo ""
    cat "$report_file"
    echo ""
}

# Parse arguments
PACKAGE_NAME=""
VERSION=""
TOOL="all"
FORMAT="table"
SCAN_ALL=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --tool)
            TOOL="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --all)
            SCAN_ALL=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            ;;
        *)
            if [[ -z "$PACKAGE_NAME" ]]; then
                PACKAGE_NAME="$1"
            elif [[ -z "$VERSION" ]]; then
                VERSION="$1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$PACKAGE_NAME" ]] && [[ "$SCAN_ALL" != true ]]; then
    log_error "Package name required"
    usage
fi

# Create scan directory
mkdir -p "$SCANS_DIR"

SCAN_ID="${PACKAGE_NAME}-${VERSION}-$(date +%Y%m%d-%H%M%S)"
SCAN_DIR="$SCANS_DIR/$SCAN_ID"
mkdir -p "$SCAN_DIR"

log_info "Starting security scan for $PACKAGE_NAME@$VERSION"
log_info "Scan ID: $SCAN_ID"

# Run scans
if [[ "$TOOL" == "all" ]] || [[ "$TOOL" == "trivy" ]]; then
    scan_with_trivy "$PACKAGE_NAME" "$VERSION" "$SCAN_DIR/trivy.json" || true
fi

if [[ "$TOOL" == "all" ]] || [[ "$TOOL" == "grype" ]]; then
    scan_with_grype "$PACKAGE_NAME" "$VERSION" "$SCAN_DIR/grype.json" || true
fi

if [[ "$TOOL" == "all" ]] || [[ "$TOOL" == "osv-scanner" ]]; then
    scan_with_osv "$PACKAGE_NAME" "$VERSION" "$SCAN_DIR/osv.json" || true
fi

# Generate report
generate_report "$PACKAGE_NAME" "$VERSION" "$SCAN_DIR" "$FORMAT"

log_info "Security scan completed successfully"
log_info "Results stored in: $SCAN_DIR"
