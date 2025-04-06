#!/bin/bash
# Install game development dependencies
set -e  # Fail on error

echo "Installing game development dependencies..."

# List of packages to install
PACKAGES=(
  "arcade"
  "pyglet"
  "rich"
  "asciimatics"
  "asyncio"
)

# Call Python script to handle installation and verification
python scripts/install_packages.py "${PACKAGES[@]}"

echo "✓ Game development dependencies installed"
