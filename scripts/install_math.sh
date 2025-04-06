#!/bin/bash
# Install math/physics dependencies
set -e  # Fail on error

echo "Installing math/physics dependencies..."

# List of packages to install
PACKAGES=(
  "numpy"
)

# Call Python script
python scripts/install_packages.py "${PACKAGES[@]}"

echo "✓ Math/physics dependencies installed"
