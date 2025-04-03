#!/bin/bash
# 2. Universal Setup Script
# Common setup tasks
set -euo pipefail

# Create basic project structure
mkdir -p src/{main,game,math,database} tests docs/data

# Initialize Git
git init 2>/dev/null || true

# Install base Python tooling
python -m pip install --upgrade pip wheel setuptools

echo "✓ Core project structure created"
[file content end]