#!/bin/bash
# Poetry-specific installation
set -euo pipefail

export INSTALL_METHOD="poetry"

# Run core setup
../../scripts/setup/setup_core.sh

# Install Poetry
curl -sSL https://install.python-poetry.org | python3 -
poetry self add poetry-plugin-export

# Install dependencies through Poetry
poetry install --no-root

# Export requirements.txt for AI compatibility
poetry export -f requirements.txt -o requirements.txt --without-hashes

echo "✓ Poetry installation completed"