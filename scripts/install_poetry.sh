#!/usr/bin/env bash
# Install Poetry with enhanced reliability
# This script installs Poetry, a Python dependency management tool.
# It checks for an existing installation, verifies the version, and installs the specified version if necessary.
# It also adds Poetry to the PATH if it's not already included.
# Usage: ./install_poetry.sh
set -euo pipefail

# Configure Poetry installation path
export POETRY_HOME="${POETRY_HOME:-${HOME}/.local/share/poetry}"
export POETRY_VERSION="1.8.2"

function install_poetry() {
    echo "Installing Poetry ${POETRY_VERSION}..."
    curl -sSL https://install.python-poetry.org | python3 - --version "${POETRY_VERSION}"
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":${POETRY_HOME}/bin:"* ]]; then
        echo "export PATH=\"${POETRY_HOME}/bin:\$PATH\"" >> ~/.bashrc
        source ~/.bashrc
    fi
}

# Verify existing installation
if command -v poetry &> /dev/null; then
    installed_version=$(poetry --version | awk '{print $3}')
    if [[ "${installed_version}" == "${POETRY_VERSION}" ]]; then
        echo "✓ Poetry ${POETRY_VERSION} already installed"
        exit 0
    else
        echo "⚠ Found Poetry ${installed_version}, installing ${POETRY_VERSION}"
        unset -f poetry
    fi
fi

install_poetry
poetry self add poetry-plugin-export
echo "✓ Poetry installation completed"
[file content end]