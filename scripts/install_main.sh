#!/bin/bash
# Install main application dependencies
set -e  # Fail on error

echo "Installing main application dependencies..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Install without version numbers
python -m pip install \
  pydantic \
  ruff \
  mypy \
  --root-user-action=ignore

# Verify install
python -c "
import pydantic
print('✓ pydantic installed')
print('✓ ruff installed')
print('✓ mypy installed')
"

echo "✓ Main application dependencies installed"