#!/bin/bash
# Generate standard project files
set -e  # Exit on error

echo "Generating standard project files..."

cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*.pyo
*.pyd
.Python
venv/
.venv/
env/
ENV/

# IDEs
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# PyPI packaging
dist/
build/
*.egg-info/
EOF

# Create CI workflow
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.13'
    - name: Create virtual environment
      run: python -m venv .venv
    - name: Activate virtual environment
      run: source .venv/bin/activate && echo "VIRTUAL_ENV=$VIRTUAL_ENV" >> $GITHUB_ENV
    - name: Run setup
      run: bash setup_project.sh
    - name: Run tests
      run: bash scripts/run_tests.sh
EOF

# Create pre-commit config
cat > .pre-commit-config.yaml << 'EOF'
repos:
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v5.0.0
  hooks:
  - id: trailing-whitespace
  - id: end-of-file-fixer
  - id: check-yaml
  - id: check-json
- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.11.2
  hooks:
  - id: ruff
    args: [--fix]
  - id: ruff-format
EOF

echo "✓ Standard project files generated"
