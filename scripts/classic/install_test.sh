#!/bin/bash
# Install testing dependencies
set -e  # Fail on error

echo "Installing testing dependencies..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Install without version numbers
python -m pip install \
  pytest \
  pytest-sugar \
  hypothesis \
  coverage \
  pytest-cov \
  --root-user-action=ignore

# Verify install
python -c "
import pytest, hypothesis, coverage
print('✓ pytest installed')
print('✓ hypothesis installed')
print('✓ coverage installed')
print('✓ pytest-cov installed')
print('✓ pytest-sugar installed')
"

echo "✓ Testing dependencies installed"
