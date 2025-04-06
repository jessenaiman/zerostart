#!/bin/bash
# Install database dependencies
set -e  # Fail on error

echo "Installing database dependencies..."

# List of packages to install
PACKAGES=(
  "SQLAlchemy"
  "Alembic"
  "sqlite3"
)

# Call Python script
python scripts/install_packages.py "${PACKAGES[@]}"

# Setup database directory
mkdir -p data
echo "✓ Created data/ directory for SQLite database"

echo "✓ Database dependencies installed"
