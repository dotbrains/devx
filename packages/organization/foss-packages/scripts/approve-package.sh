#!/usr/bin/env bash
set -euo pipefail

# Approve Package Script
# Moves a package from pending to approved registry

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOSS_ROOT="$(dirname "$SCRIPT_DIR")"
REGISTRY_DIR="$FOSS_ROOT/registry"
PENDING_DIR="$REGISTRY_DIR/pending"
APPROVED_DIR="$REGISTRY_DIR/approved"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <package-name> <version>

Approve a package for use in the FOSS ecosystem.

Arguments:
    package-name    Name of the package
    version         Package version

Options:
    -a, --approver EMAIL    Approver email (default: current user)
    -n, --notes TEXT        Approval notes
    -r, --reject            Reject instead of approve
    --reason TEXT           Rejection reason (required with --reject)
    -h, --help              Show this help message

Examples:
    $(basename "$0") requests 2.31.0
    $(basename "$0") express 4.18.2 -a security-lead@example.com
    $(basename "$0") vulnerable-pkg 1.0.0 --reject --reason "Critical CVE"

EOF
    exit 1
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

PACKAGE_NAME=""
VERSION=""
APPROVER="${USER}@example.com"
NOTES=""
REJECT=false
REJECTION_REASON=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--approver)
            APPROVER="$2"
            shift 2
            ;;
        -n|--notes)
            NOTES="$2"
            shift 2
            ;;
        -r|--reject)
            REJECT=true
            shift
            ;;
        --reason)
            REJECTION_REASON="$2"
            shift 2
            ;;
        -h|--help)
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

if [[ -z "$PACKAGE_NAME" ]] || [[ -z "$VERSION" ]]; then
    log_error "Package name and version required"
    usage
fi

if [[ "$REJECT" == true ]] && [[ -z "$REJECTION_REASON" ]]; then
    log_error "Rejection reason required with --reject"
    usage
fi

PACKAGE_ID="${PACKAGE_NAME}-${VERSION}"
PENDING_FILE="$PENDING_DIR/${PACKAGE_ID}.yml"

if [[ ! -f "$PENDING_FILE" ]]; then
    log_error "Package not found in pending queue: $PACKAGE_ID"
    exit 1
fi

mkdir -p "$APPROVED_DIR"

APPROVAL_DATE=$(date -u +"%Y-%m-%d")

if [[ "$REJECT" == true ]]; then
    log_warn "Rejecting package: $PACKAGE_NAME@$VERSION"
    log_warn "Reason: $REJECTION_REASON"
    
    # Add to rejected list in packages.yml
    cat >> "$REGISTRY_DIR/packages.yml" <<EOF

  - name: "$PACKAGE_NAME"
    version: "$VERSION"
    rejection_reason: "$REJECTION_REASON"
    rejected_by: "$APPROVER"
    rejected_date: "$APPROVAL_DATE"
EOF
    
    rm "$PENDING_FILE"
    log_info "Package rejected and removed from pending queue"
else
    log_info "Approving package: $PACKAGE_NAME@$VERSION"
    log_info "Approver: $APPROVER"
    
    # Move to approved registry
    mv "$PENDING_FILE" "$APPROVED_DIR/${PACKAGE_ID}.yml"
    
    # Update main packages.yml (simplified - would be more sophisticated in production)
    log_info "Adding to approved packages registry"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Package Approved: $PACKAGE_NAME@$VERSION"
    echo "Approved by: $APPROVER"
    echo "Date: $APPROVAL_DATE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_info "Package is now available for use"
fi
