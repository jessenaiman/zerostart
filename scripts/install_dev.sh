#!/bin/bash
# Install development dependencies
set -e  # Fail on error

echo "Installing development dependencies..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Install without version numbers
python -m pip install \
  pre-commit \
  pre-commit-hooks \
  --root-user-action=ignore

# Verify install
python -c "
import ruff, mypy, pre_commit
print('✓ pre-commit installed')
print('✓ pre-commit-hooks installed')
"

echo "✓ Development dependencies installed"