#!/bin/bash
# Verify filesystem structure
set -e  # Exit on error

echo "Verifying project structure..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Set PYTHONPATH to include the project root
export PYTHONPATH=$(pwd):$PYTHONPATH

cd src/omega_project

# Check critical paths
declare -a REQUIRED_PATHS=(
  "shared/types.py"
  "main.py"
)

for path in "${REQUIRED_PATHS[@]}"; do
  if [ ! -f "$path" ]; then
    echo "❌ Missing critical file: $path"
    exit 1
  fi
done

# Run module self-tests
python -m shared.types | grep -q "passed" || { echo "❌ Types import failed"; exit 1; }

cd ../..

# Check test directory
if [ ! -d "tests/unit" ]; then
    echo "❌ Missing tests/unit directory"
    exit 1
fi

echo "✓ Project structure verified"