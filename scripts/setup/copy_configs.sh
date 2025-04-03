#!/bin/bash
# Copy config files to appropriate locations
set -euo pipefail

CONFIG_ROOT="${PWD}/config"

# Copy VS Code settings
mkdir -p .vscode
cp "${CONFIG_ROOT}/vscode/settings.json" .vscode/
echo "✓ Copied VS Code settings"

# Copy pre-commit config
cp "${CONFIG_ROOT}/pre-commit/.pre-commit-config.yaml" .
echo "✓ Copied pre-commit config"

# Copy Ruff config
cp "${CONFIG_ROOT}/ruff/ruff.toml" .
echo "✓ Copied Ruff config"

# Handle Poetry template if needed
if [ "$INSTALL_METHOD" = "poetry" ]; then
    cp templates/pyproject.toml .
    echo "✓ Copied Poetry template"
fi