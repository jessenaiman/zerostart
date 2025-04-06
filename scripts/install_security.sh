#!/bin/bash
# Install security dependencies
set -e  # Fail on error

echo "Installing security dependencies..."

# List of packages to install
PACKAGES=(
  "bandit"
)

# Call Python script
python scripts/install_packages.py "${PACKAGES[@]}"

echo "✓ Security dependencies installed"
echo "To scan for security issues, run 'bandit -r src/'."
