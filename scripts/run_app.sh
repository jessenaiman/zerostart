#!/bin/bash
# Run the Omega Spiral application
set -e  # Exit on error

echo "Starting Omega Spiral application..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

python -m src.omega_project.main

echo "✓ Application ran successfully"