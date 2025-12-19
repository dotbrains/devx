#!/usr/bin/env bash
set -euo pipefail

# Add Package to FOSS Registry
# Submits a package for security scanning and approval

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOSS_ROOT="$(dirname "$SCRIPT_DIR")"
REGISTRY_DIR="$FOSS_ROOT/registry"
SECURITY_DIR="$FOSS_ROOT/security"
PENDING_DIR="$REGISTRY_DIR/pending"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <package-name> <version>

Add a package to the FOSS registry for security scanning and approval.

Arguments:
    package-name    Name of the package (e.g., requests, express)
    version         Package version (e.g., 2.31.0)

Options:
    -t, --type TYPE         Package type (pypi, npm, maven, container, binary)
    -d, --description DESC  Package description
    -u, --upstream URL      Upstream package URL
    -s, --submitter EMAIL   Submitter email
    -h, --help              Show this help message

Examples:
    $(basename "$0") requests 2.31.0 -t pypi
    $(basename "$0") express 4.18.2 -t npm -d "Web framework"
    $(basename "$0") nginx 1.25.3-alpine -t container

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

# Parse arguments
PACKAGE_NAME=""
VERSION=""
PACKAGE_TYPE=""
DESCRIPTION=""
UPSTREAM_URL=""
SUBMITTER="${USER}@example.com"

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            PACKAGE_TYPE="$2"
            shift 2
            ;;
        -d|--description)
            DESCRIPTION="$2"
            shift 2
            ;;
        -u|--upstream)
            UPSTREAM_URL="$2"
            shift 2
            ;;
        -s|--submitter)
            SUBMITTER="$2"
            shift 2
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
            else
                log_error "Too many arguments"
                usage
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$PACKAGE_NAME" ]] || [[ -z "$VERSION" ]]; then
    log_error "Package name and version are required"
    usage
fi

# Auto-detect package type if not provided
if [[ -z "$PACKAGE_TYPE" ]]; then
    log_warn "Package type not specified, attempting to auto-detect..."
    
    if [[ "$PACKAGE_NAME" =~ ^[a-z0-9-]+$ ]] && [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        PACKAGE_TYPE="pypi"
    fi
    
    if [[ -z "$PACKAGE_TYPE" ]]; then
        log_error "Could not auto-detect package type. Please specify with -t/--type"
        exit 1
    fi
    
    log_info "Auto-detected package type: $PACKAGE_TYPE"
fi

# Validate package type
VALID_TYPES=("pypi" "npm" "maven" "container" "binary")
if [[ ! " ${VALID_TYPES[@]} " =~ " ${PACKAGE_TYPE} " ]]; then
    log_error "Invalid package type: $PACKAGE_TYPE"
    log_error "Valid types: ${VALID_TYPES[*]}"
    exit 1
fi

# Create directories if they don't exist
mkdir -p "$PENDING_DIR"
mkdir -p "$SECURITY_DIR/scans"

# Check if package already exists
PACKAGE_ID="${PACKAGE_NAME}-${VERSION}"
PENDING_FILE="$PENDING_DIR/${PACKAGE_ID}.yml"

if [[ -f "$PENDING_FILE" ]]; then
    log_error "Package already in pending queue: $PACKAGE_ID"
    exit 1
fi

# Check if package is already approved
if grep -q "name: \"$PACKAGE_NAME\"" "$REGISTRY_DIR/packages.yml" 2>/dev/null; then
    if grep -A 2 "name: \"$PACKAGE_NAME\"" "$REGISTRY_DIR/packages.yml" | grep -q "version: \"$VERSION\""; then
        log_error "Package already approved: $PACKAGE_NAME@$VERSION"
        exit 1
    fi
fi

log_info "Submitting package: $PACKAGE_NAME@$VERSION"
log_info "Type: $PACKAGE_TYPE"
log_info "Submitter: $SUBMITTER"

# Generate package submission file
SUBMISSION_DATE=$(date -u +"%Y-%m-%d")
SUBMISSION_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$PENDING_FILE" <<EOF
---
# Package Submission
name: "$PACKAGE_NAME"
version: "$VERSION"
type: "$PACKAGE_TYPE"
status: "pending"
submitted_by: "$SUBMITTER"
submitted_date: "$SUBMISSION_DATE"
submitted_time: "$SUBMISSION_TIME"
description: "$DESCRIPTION"
upstream_url: "$UPSTREAM_URL"

# Scanning Status
scanning:
  status: "queued"
  started_at: null
  completed_at: null
  
security_scan:
  status: "pending"
  score: null
  vulnerabilities: []
  
license_check:
  status: "pending"
  license: null
  approved: null
  
dependency_analysis:
  status: "pending"
  dependencies: []

# Approval Status
approval:
  status: "pending"
  approved_by: null
  approved_date: null
  rejection_reason: null
EOF

log_info "Package submission created: $PENDING_FILE"

# Trigger security scan
log_info "Triggering security scan..."
"$SCRIPT_DIR/security-scan.sh" "$PACKAGE_NAME" "$VERSION" || {
    log_warn "Security scan failed to start, but package is queued"
}

# Generate notification
log_info "Package submitted successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Package: $PACKAGE_NAME@$VERSION"
echo "Type: $PACKAGE_TYPE"
echo "Status: Pending Security Scan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Security scan will run automatically"
echo "  2. License compliance check"
echo "  3. Manual security review"
echo "  4. Approval or rejection"
echo ""
echo "Check status with: ./scripts/check-status.sh $PACKAGE_ID"
