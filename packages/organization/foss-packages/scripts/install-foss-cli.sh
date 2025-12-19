#!/usr/bin/env bash
set -euo pipefail

# Install FOSS CLI Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOSS_ROOT="$(dirname "$SCRIPT_DIR")"
CLI_DIR="$FOSS_ROOT/cli"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Installing FOSS CLI...${NC}"
echo ""

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "✓ Found Python $PYTHON_VERSION"

# Create virtual environment if it doesn't exist
if [ ! -d "$CLI_DIR/venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$CLI_DIR/venv"
fi

# Activate virtual environment
source "$CLI_DIR/venv/bin/activate"

# Install CLI package
echo "Installing dependencies..."
cd "$CLI_DIR"
pip install -q --upgrade pip
pip install -q -e .

echo ""
echo -e "${GREEN}✓ FOSS CLI installed successfully!${NC}"
echo ""
echo "To use the CLI:"
echo "  1. Activate the virtual environment:"
echo "     source $CLI_DIR/venv/bin/activate"
echo ""
echo "  2. Run commands:"
echo "     foss-cli --help"
echo "     foss-cli search requests"
echo "     foss-cli info flask"
echo ""
echo "Or create a symlink to use globally:"
echo "  sudo ln -s $CLI_DIR/venv/bin/foss-cli /usr/local/bin/foss-cli"
echo ""
echo "Environment variables:"
echo "  FOSS_API_URL    - API base URL (default: http://localhost:8000)"
echo "  FOSS_VERBOSE    - Enable verbose output (default: false)"
echo "  FOSS_JSON       - Output as JSON (default: false)"
