#!/usr/bin/env bash

set -e

DOCS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$DOCS_DIR/.venv"
START_PORT=8000
MAX_PORT=8100

# Function to check if a port is in use
is_port_in_use() {
    lsof -i :"$1" >/dev/null 2>&1
}

# Function to find next available port
find_available_port() {
    local port=$START_PORT
    while [ $port -le $MAX_PORT ]; do
        if ! is_port_in_use $port; then
            echo $port
            return 0
        fi
        ((port++))
    done
    echo "Error: No available ports found between $START_PORT and $MAX_PORT" >&2
    return 1
}

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Install/upgrade dependencies
echo "Installing/upgrading dependencies..."
pip install --upgrade pip >/dev/null 2>&1
pip install -r "$DOCS_DIR/requirements.txt" >/dev/null 2>&1

# Find available port
PORT=$(find_available_port)
if [ $? -ne 0 ]; then
    exit 1
fi

if [ $PORT -ne $START_PORT ]; then
    echo "Port $START_PORT is in use, using port $PORT instead"
fi

echo "Starting MkDocs server on http://127.0.0.1:$PORT"
echo "Press Ctrl+C to stop"
echo "Auto-reload enabled - changes will be detected automatically"

# Start MkDocs server with auto-reload
cd "$DOCS_DIR"
mkdocs serve -f mkdocs.yml -a "127.0.0.1:$PORT" --livereload --watch-theme
