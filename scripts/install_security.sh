#!/bin/bash
# Install security dependencies
set -e  # Fail on error

echo "Installing security dependencies..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Install without version numbers
python -m pip install \
  bandit \
  --root-user-action=ignore

# Verify install
python -c "
import bandit
print('✓ bandit installed')
"

echo "✓ Security dependencies installed"
echo "To scan for security issues, run 'bandit -r src/'."