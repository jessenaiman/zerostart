#!/bin/bash
# Install and verify Python 3.13+ (Linux/MacOS/Windows via MinGW64)
set -e  # Fail on error

echo "Checking Python 3.13+ installation..."

if ! command -v python3.13 &> /dev/null; then
    echo "❌ Python 3.13+ not found. Please install from python.org."
    exit 1
fi

python --version
python -m ensurepip --upgrade
python -m pip install --upgrade pip

echo "✓ Python 3.13+ installed and pip upgraded"
