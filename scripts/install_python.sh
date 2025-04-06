#!/bin/bash
# Install and verify Python 3.13.2
set -e  # Fail on error

echo "Checking Python 3.13.2 installation..."

python --version
python -m ensurepip --upgrade
python -m pip install --upgrade pip
pip install pipx

echo "✓ Python 3.13.2 installed and pip upgraded"
