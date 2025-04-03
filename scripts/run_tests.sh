#!/bin/bash
# Run Omega Spiral tests with coverage
set -e  # Exit on error

echo "Running Omega Spiral tests..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Check if pytest is installed
if ! python -c "import pytest" 2>/dev/null; then
    echo "⚠ pytest not installed. Run 'bash scripts/install_test.sh' to install testing tools."
    exit 1
fi

python -m pytest tests --cov=src/omega_project --cov-report=term-missing

echo "✓ Tests passed with coverage report"