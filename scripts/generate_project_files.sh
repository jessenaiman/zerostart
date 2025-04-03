#!/bin/bash
# Generate standard project files
set -e  # Exit on error

echo "Generating standard project files..."

# Create standard project files
cat > README.md << 'EOF'
# ZeroStart

A Python project starting template.

## Setup

1. Create and activate a virtual environment:
   - `python3.13 -m venv .venv`
   - `source .venv/Scripts/activate` (Windows) or `source .venv/bin/activate` (Linux/MacOS)
2. Run `bash setup_project.sh` to set up the project with core dependencies (main, dev, test).
3. (Optional) Install additional dependencies as needed:
   - `bash scripts/install_documentation.sh` for documentation tools (Sphinx).
   - `bash scripts/install_database.sh` for database support (SQLite with SQLAlchemy).
   - `bash scripts/install_math.sh` for math/physics packages (NumPy).
   - `bash scripts/install_game.sh` for game development packages (Arcade).
   - `bash scripts/install_security.sh` for security tools (Bandit).
4. Run `bash scripts/run_app.sh` to start the application.
5. Run `bash scripts/run_tests.sh` to execute tests.
EOF

cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Jesse Naim

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

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

# Create pyproject.toml for PyPI packaging
cat > pyproject.toml << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "zerostart"
version = "0.1.0"
authors = [
  { name="Jesse Naim", email="your.email@example.com" },
]
description = "A Python project starting template with modular setup scripts."
readme = "README.md"
requires-python = ">=3.13"
license = { file="LICENSE" }
keywords = ["python", "template", "starter", "project", "setup"]
classifiers = [
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
]

[project.urls]
Homepage = "https://github.com/jesseniman/zerostart"
Repository = "https://github.com/jessenaiman/zerostart"
EOF

echo "✓ Standard project files generated"