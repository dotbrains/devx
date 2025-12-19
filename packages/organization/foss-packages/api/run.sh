#!/usr/bin/env bash
set -euo pipefail

# FOSS API Startup Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Python virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install/upgrade dependencies
echo "Installing dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt

# Set environment variables
export FOSS_API_HOST="${FOSS_API_HOST:-0.0.0.0}"
export FOSS_API_PORT="${FOSS_API_PORT:-8000}"
export FOSS_API_RELOAD="${FOSS_API_RELOAD:-true}"
export FOSS_SCAN_ON_SUBMIT="${FOSS_SCAN_ON_SUBMIT:-true}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  FOSS Package API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "API Documentation: http://${FOSS_API_HOST}:${FOSS_API_PORT}/api/docs"
echo "ReDoc: http://${FOSS_API_HOST}:${FOSS_API_PORT}/api/redoc"
echo ""
echo "Starting server..."
echo ""

# Start the API server
uvicorn api.app:app \
    --host "$FOSS_API_HOST" \
    --port "$FOSS_API_PORT" \
    --reload
