#!/bin/bash
# Install pre-commit hooks
set -e  # Exit on error

echo "Setting up pre-commit hooks..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "⚠ pre-commit not installed. Run 'bash scripts/install_dev.sh' to install development tools."
    exit 1
fi

pre-commit install
pre-commit run --all-files

echo "✓ Pre-commit hooks installed"
