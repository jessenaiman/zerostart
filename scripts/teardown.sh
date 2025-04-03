#!/bin/bash
# Safe project reset that preserves configuration
set -euo pipefail

# Files to preserve
PRESERVE=(
  "pyproject.toml"
  "README.md"
  "LICENSE"
  ".pre-commit-config.yaml"
  ".github/workflows/ci.yml"
  ".vscode/settings.json"
)

# Backup directory
BACKUP_DIR=".zerostart_backup_$(date +%s)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup of preserved files..."
for file in "${PRESERVE[@]}"; do
  if [ -f "$file" ] || [ -d "$file" ]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$file")"
    cp -r "$file" "$BACKUP_DIR/$file"
  fi
done

echo "Removing generated files..."
rm -rf .venv/
rm -f poetry.lock
rm -rf dist/
rm -rf build/
rm -rf src/zerostart/__pycache__/
rm -rf tests/__pycache__/
find . -type d -name "__pycache__" -exec rm -rf {} +
find . -type f -name "*.pyc" -delete
find . -type f -name "*.pyo" -delete

echo "Restoring preserved files..."
for file in "${PRESERVE[@]}"; do
  if [ -f "$BACKUP_DIR/$file" ] || [ -d "$BACKUP_DIR/$file" ]; then
    mkdir -p "$(dirname "$file")"
    cp -r "$BACKUP_DIR/$file" "$file"
  fi
done

echo "Cleaning up..."
rm -rf "$BACKUP_DIR"

echo -e "\n✓ Project reset complete"
echo "Preserved:"
printf "  - %s\n" "${PRESERVE[@]}"
echo -e "\nRun 'poetry install' to recreate the virtual environment"