#!/bin/bash
# Verify imports across modules
set -e  # Exit on error

echo "Verifying imports..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Set PYTHONPATH to include the project root
export PYTHONPATH=$(pwd):$PYTHONPATH

# Verify imports
python -c "
from src.omega_project.shared.types import Vector2
print('✓ Core imports valid')
"

echo "✓ Imports verified"
