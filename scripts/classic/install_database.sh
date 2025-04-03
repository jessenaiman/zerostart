#!/bin/bash
# Install database dependencies and set up directory
set -e  # Fail on error

echo "Installing database dependencies..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Install without version numbers
python -m pip install \
  SQLAlchemy \
  --root-user-action=ignore

# Verify install
python -c "
import sqlalchemy
print('✓ SQLAlchemy installed')
"

# Set up database directory
mkdir -p data
echo "✓ Created data/ directory for SQLite database (omega_project.db)"

echo "✓ Database dependencies installed"
