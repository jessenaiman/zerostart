#!/bin/bash
# Install math/physics dependencies
set -e  # Fail on error

echo "Installing math/physics dependencies..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Install without version numbers
python -m pip install \
  numpy \
  --root-user-action=ignore

# Verify install
python -c "
import numpy
print('✓ numpy installed')
"

echo "✓ Math/physics dependencies installed"