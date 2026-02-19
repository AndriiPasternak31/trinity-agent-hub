#!/bin/bash
# Install trinity-market CLI
# Usage: curl -sSL https://raw.githubusercontent.com/AndriiPasternak31/trinity-agent-hub/main/install.sh | bash

set -e

echo "Installing trinity-market CLI..."

# Check Python 3.10+
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required. Install from https://python.org"
    exit 1
fi

PY_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PY_MAJOR=$(echo "$PY_VERSION" | cut -d. -f1)
PY_MINOR=$(echo "$PY_VERSION" | cut -d. -f2)

if [ "$PY_MAJOR" -lt 3 ] || ([ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 10 ]); then
    echo "Error: Python 3.10+ required (found $PY_VERSION)"
    exit 1
fi

# Install dependencies
pip3 install --quiet requests pyyaml 2>/dev/null || pip install --quiet requests pyyaml

# Download CLI
INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR"

curl -sSL "https://raw.githubusercontent.com/AndriiPasternak31/trinity-agent-hub/main/trinity_market.py" \
    -o "${INSTALL_DIR}/trinity-market"
chmod +x "${INSTALL_DIR}/trinity-market"

# Check PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    echo ""
    echo "Add to your PATH:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

echo "Installed! Run: trinity-market configure"
