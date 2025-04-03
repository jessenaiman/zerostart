#!/bin/bash
# Install game development dependencies
set -e  # Fail on error

echo "Installing game development dependencies..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Install without version numbers
python -m pip install \
  arcade \
  pyglet \
  --root-user-action=ignore

# Verify install
python -c "
import arcade, pyglet
print('✓ arcade installed')
print('✓ pyglet installed')
"

echo "✓ Game development dependencies installed"
