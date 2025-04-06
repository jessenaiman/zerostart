#!/bin/bash
set -e
echo "Installing testing dependencies..."
PACKAGES=(
    "pytest"
    "hypothesis"
    "coverage"
    "pylint"
    "flake8"
    "black"
    "isort"
    "ruff"
    )
python scripts/install_packages.py "${PACKAGES[@]}"

echo "✓ Testing dependencies installed and verified"
