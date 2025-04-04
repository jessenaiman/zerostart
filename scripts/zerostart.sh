#!/bin/bash
# ZeroStart: One-Command Python Project Initialization (Current Version: Python 3.13.2)
# This script runs ALL necessary setup tasks in the correct order
set -euo pipefail

# Colors and Symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
ARROW="➜"; CHECK="✓"; CROSS="❌"; WARNING="⚠️"

# Function to check if a virtual environment is active
check_venv() {
    if [ -z "${VIRTUAL_ENV:-}" ]; then
        echo -e "${RED}${CROSS} No virtual environment detected!${NC}"
        echo -e "${YELLOW}${ARROW} Please activate your virtual environment before running this script.${NC}"
        echo -e "${CYAN}Run the following command based on your OS:${NC}"
        echo -e "  Linux/Mac: ${CYAN}source .venv/bin/activate${NC}"
        echo -e "  Windows: ${CYAN}.venv\\Scripts\\activate${NC}"
        exit 1
    else
        echo -e "${GREEN}${CHECK} Virtual environment detected: ${VIRTUAL_ENV}${NC}"
    fi
}



function handle_common_errors() {
    local error_output="$1"
    local step_name="$2"
    
    # Poetry initialization error
    if echo "$error_output" | grep -q "pyproject.toml file with a project and/or a poetry section already exists"; then
        echo -e "\n${YELLOW}${WARNING} Poetry project already exists${NC}"
        echo -e "${GREEN}${CHECK} This is fine, continuing with existing pyproject.toml${NC}"
        return 0  # Return success to continue
    fi
    
    # Python version error
    if echo "$error_output" | grep -q "Python 3.13"; then
        echo -e "\n${YELLOW}${WARNING} Resolution Guide:${NC}"
        echo -e "1. Python 3.13 is required but not available"
        echo -e "2. Options:"
        echo -e "   a) Install Python 3.13 from python.org"
        echo -e "   b) Use pyenv: ${CYAN}pyenv install 3.13.0${NC}"
        echo -e "   c) Modify the script to use your installed Python version:"
        echo -e "      → Edit the script and replace all instances of python3.13 with your version"
        return 1
    fi
    
    # Generic package installation error
    if echo "$error_output" | grep -q "Failed to install"; then
        echo -e "\n${YELLOW}${WARNING} Resolution Guide:${NC}"
        echo -e "1. Package installation failed"
        echo -e "2. Check network connection and try again"
        echo -e "3. If specific package is problematic, modify install_packages.sh to skip it"
        return 1
    fi
    
    return 1  # Unrecognized error
}

# Enhanced run_step with better error handling
run_step() {
    local step_num=$1
    local step_name=$2
    local step_cmd=$3
    local optional=${4:-false}
    
    echo -e "\n${YELLOW}${ARROW} Step ${step_num}: ${step_name}${NC}"
    if output=$(eval "$step_cmd" 2>&1); then
        echo -e "${GREEN}${CHECK} Success${NC}"
        return 0
    else
        echo -e "\n${RED}${CROSS} Issue at step ${step_num} (${step_name})${NC}"
        echo -e "Output:\n${output}\n"
        
        # Try to handle common errors
        if handle_common_errors "$output" "$step_name"; then
            echo -e "${YELLOW}${WARNING} Continuing despite issue${NC}"
            return 0
        else
            # If this is an optional step, we can continue
            if [ "$optional" = true ]; then
                echo -e "${YELLOW}${WARNING} Optional step failed, continuing anyway${NC}"
                return 0
            else
                echo -e "${RED}${CROSS} Failed at required step ${step_num}${NC}"
                exit 1
            fi
        fi
    fi
}

setup_permissions() {
    echo -e "\n${YELLOW}${ARROW} Setting script permissions${NC}"
    chmod +x scripts/*.sh 2>/dev/null || true
    find . -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    echo -e "${GREEN}${CHECK} All scripts made executable${NC}"
}

activate_venv() {
    echo -e "\n${YELLOW}${ARROW} Activating virtual environment${NC}"
    
    # Get Python version to use
    PYTHON_CMD="python3.13.2"
    
    echo -e "${CYAN}Using Python: $($PYTHON_CMD --version)${NC}"
    
    if [ ! -d ".venv" ]; then
        $PYTHON_CMD -m venv .venv
    fi
    
    # Platform-specific activation
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        source .venv/bin/activate
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        source .venv/Scripts/activate
    else
        echo -e "${RED}${CROSS} Unsupported OS for auto-activation${NC}"
        echo "Please activate manually:"
        echo "  Linux/Mac: source .venv/bin/activate"
        echo "  Windows: .venv\\Scripts\\activate"
        exit 1
    fi

    # Pause for virtual environment activation
    echo -e "${GREEN}${CHECK} Virtual environment activated${NC}"
}

install_poetry() {
    echo -e "\n${YELLOW}${ARROW} Checking for Poetry${NC}"
    if ! command -v poetry &>/dev/null; then
        echo -e "${CYAN}Installing Poetry...${NC}"
        pipx install poetry
        export PATH="$HOME/.local/bin:$PATH"  # Add poetry to path
    else
        echo -e "${GREEN}${CHECK} Poetry already installed${NC}"
    fi
    
    # Verify poetry works
    poetry --version || {
        echo -e "${RED}${CROSS} Poetry installation issue. Adding to PATH...${NC}"
        export PATH="$HOME/.local/bin:$PATH"
        poetry --version || {
            echo -e "${RED}${CROSS} Poetry still not working. Please install manually:${NC}"
            echo "curl -sSL https://install.python-poetry.org | python3 -"
            exit 1
        }
    }
}

install_package_group() {
    local group="$1"; shift
    echo -e "\n${CYAN}⚙️ Installing $group Dependencies:${NC}"
    
    # Join all package names with spaces
    local packages="$*"
    
    # Install all packages at once
    if [ -n "$packages" ]; then
        run_step "$group packages" "Adding $group packages" "poetry add --group $group $packages" true
    fi
}

create_sample_app() {
    echo -e "\n${YELLOW}${ARROW} Creating sample application${NC}"
    
    # Create directories
    mkdir -p src/demo
    mkdir -p tests/unit
    
    # Create __init__.py files
    touch src/__init__.py
    touch src/demo/__init__.py
    touch tests/__init__.py
    touch tests/unit/__init__.py
    
    # Create sample app
    cat > src/demo/app.py << EOF
"""
Sample application that opens a window.

This demonstrates that the project is set up correctly.
"""
import sys
from pathlib import Path
import logging

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)


class DemoApp:
    """
    A simple demo application.
    
    This class provides a minimal working example to demonstrate
    that the ZeroStart setup is functioning correctly.
    """
    
    def __init__(self, name="ZeroStart Demo"):
        """
        Initialize the demo application.
        
        Args:
            name: Name of the application
        """
        self.name = name
        logger.info("Demo application initialized")
    
    def run(self):
        """Run the demo application."""
        try:
            logger.info(f"Running {self.name}")
            logger.info("Application started successfully")
            
            # If rich is installed, use it for fancy output
            try:
                from rich.console import Console
                from rich.panel import Panel
                
                console = Console()
                console.print(Panel(f"[bold green]{self.name} is running![/bold green]"))
                console.print("[bold cyan]This sample app confirms ZeroStart is working correctly![/bold cyan]")
            except ImportError:
                print(f"{self.name} is running!")
                print("This sample app confirms ZeroStart is working correctly!")
            
            return True
        except Exception as e:
            logger.error(f"Error running application: {e}")
            return False


def main():
    """Main entry point for the demo application."""
    app = DemoApp()
    success = app.run()
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
EOF

    # Create main.py
    cat > src/main.py << EOF
"""Main entry point for the application."""
from demo.app import main

if __name__ == "__main__":
    main()
EOF

    # Create sample test
    cat > tests/unit/test_app.py << EOF
"""
Tests for the demo application.

These tests verify that the sample app works correctly.
"""
import pytest
from src.demo.app import DemoApp


def test_app_initialization():
    """Test that the app initializes correctly."""
    app = DemoApp(name="Test App")
    assert app.name == "Test App"


def test_app_run():
    """Test that the app runs without errors."""
    app = DemoApp()
    result = app.run()
    assert result is True
EOF

    echo -e "${GREEN}${CHECK} Sample application created${NC}"
}

create_sphinx_docs() {
    echo -e "\n${YELLOW}${ARROW} Setting up Sphinx documentation${NC}"
    
    # Create docs directory structure
    mkdir -p docs/{_static,_templates,api,guides,examples}
    
    # Create a basic conf.py
    cat > docs/conf.py << EOF
# Configuration file for the Sphinx documentation builder

import os
import sys
sys.path.insert(0, os.path.abspath('..'))

# Project information
project = 'ZeroStart Project'
copyright = '2025, Jesse Naiman'
author = 'Jesse Naiman'

# General configuration
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    'sphinx.ext.intersphinx',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# HTML output
html_theme = 'alabaster'
html_static_path = ['_static']

# Extension configuration
autodoc_member_order = 'bysource'
EOF

    # Create a basic index.rst
    cat > docs/index.rst << EOF
ZeroStart Project Documentation
==============================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   guides/getting_started
   api/index

Indices and tables
==================

* :ref:\`genindex\`
* :ref:\`modindex\`
* :ref:\`search\`
EOF

    # Create a getting started guide
    mkdir -p docs/guides
    cat > docs/guides/getting_started.rst << EOF
Getting Started
==============

This is a sample project created with ZeroStart.

Installation
-----------

To use this project:

1. Clone the repository
2. Run \`poetry install\`
3. Activate the virtual environment
4. Run \`poetry run python -m src.main\`

That's it!
EOF

    # Create an API index
    mkdir -p docs/api
    cat > docs/api/index.rst << EOF
API Reference
============

.. automodule:: src.demo.app
   :members:
   :undoc-members:
   :show-inheritance:
EOF

    echo -e "${GREEN}${CHECK} Sphinx documentation setup complete${NC}"
}

create_ci_workflow() {
    echo -e "\n${YELLOW}${ARROW} Creating GitHub Actions CI workflow${NC}"
    
    # Create directories
    mkdir -p .github/workflows
    
    # Create CI workflow
    cat > .github/workflows/ci.yml << EOF
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.13.2'
    
    - name: Install Poetry
      run: |
        curl -sSL https://install.python-poetry.org | python3 -
        echo "\$HOME/.local/bin" >> \$GITHUB_PATH
    
    - name: Install dependencies
      run: |
        poetry install
    
    - name: Run tests
      run: |
        poetry run pytest
    
    - name: Build documentation
      run: |
        poetry run sphinx-build -b html docs docs/_build
EOF

    echo -e "${GREEN}${CHECK} GitHub Actions workflow created${NC}"
}

update_pyproject() {
    echo -e "\n${YELLOW}${ARROW} Updating pyproject.toml with scripts${NC}"
    
    # Use Python to update pyproject.toml
    python3 -c "
import sys
try:
    import toml
except ImportError:
    print('Installing toml package...')
    import subprocess
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'toml'])
    import toml

try:
    with open('pyproject.toml', 'r') as f:
        config = toml.load(f)
except FileNotFoundError:
    config = {}

# Ensure the structure exists
if 'tool' not in config:
    config['tool'] = {}
if 'poetry' not in config['tool']:
    config['tool']['poetry'] = {}
if 'scripts' not in config['tool']['poetry']:
    config['tool']['poetry']['scripts'] = {}

# Add scripts
scripts = config['tool']['poetry']['scripts']
scripts['start'] = 'src.main:main'
scripts['docs'] = 'sphinx-build -M html docs docs/_build'
scripts['test'] = 'pytest'

with open('pyproject.toml', 'w') as f:
    toml.dump(config, f)

print('pyproject.toml updated with scripts')
" || echo -e "${YELLOW}${WARNING} Could not update pyproject.toml with scripts${NC}"
}

create_readme() {
    echo -e "\n${YELLOW}${ARROW} Creating README.md${NC}"
    
    cat > README.md << EOF
# ZeroStart Project

A professional Python project template with best practices built-in.

## Features

- ✅ Modern Python packaging with Poetry
- ✅ Comprehensive testing setup with pytest
- ✅ Documentation with Sphinx
- ✅ CI/CD with GitHub Actions
- ✅ Sample application to verify setup

## Quick Start

1. Clone this repository
2. Run \`poetry install\`
3. Run \`poetry run start\` to run the sample app
4. Run \`poetry run test\` to run tests
5. Run \`poetry run docs\` to build documentation

## Project Structure

\`\`\`
project/
├── src/                  # Source code
│   └── demo/             # Sample application
├── tests/                # Tests
├── docs/                 # Documentation
├── .github/workflows/    # GitHub Actions
└── pyproject.toml        # Project configuration
\`\`\`

## Development

Add your code to the \`src\` directory and tests to the \`tests\` directory.
Update the documentation in the \`docs\` directory.

## License

MIT
EOF

    echo -e "${GREEN}${CHECK} README.md created${NC}"
}

run_tests() {
    echo -e "\n${YELLOW}${ARROW} Running tests${NC}"
    poetry run pytest -v || {
        echo -e "${YELLOW}${WARNING} Tests failed, but continuing setup${NC}"
    }
}

run_sample_app() {
    echo -e "\n${YELLOW}${ARROW} Running sample application${NC}"
    poetry run python -m src.main || {
        echo -e "${YELLOW}${WARNING} Sample app failed, but continuing setup${NC}"
    }
}

build_docs() {
    echo -e "\n${YELLOW}${ARROW} Building documentation${NC}"
    poetry run sphinx-build -M html docs docs/_build || {
        echo -e "${YELLOW}${WARNING} Documentation build failed, but continuing setup${NC}"
    }
}

# --- Main Execution ---
show_header

# Check if the virtual environment is active
check_venv

# Pre-setup verification
run_step "0.1" "Verify system permissions" "setup_permissions"
run_step "0.2" "Activate virtual environment" "activate_venv"
run_step "0.3" "Install Poetry" "install_poetry"

# Installation Steps
run_step "1" "Create project structure" "mkdir -p src tests docs data"

# Initialize Poetry project (if not already done)
run_step "2" "Initialize Poetry project" "poetry init -n --python='^3.13.2'" true

# Install dependencies by category
echo -e "\n${CYAN}=== Installing Dependencies ===${NC}"

# Core dependencies
install_package_group "dev" "mypy black isort flake8 flake8-docstrings pre-commit ipdb debugpy"
install_package_group "test" "pytest pytest-cov hypothesis"
install_package_group "docs" "sphinx sphinx-rtd-theme sphinx-autobuild"

# Optional category-specific dependencies
echo -e "\n${CYAN}=== Installing Optional Category-Specific Dependencies ===${NC}"
echo -e "${YELLOW}You can add your specific dependencies for each category${NC}"

install_package_group "dev" "rich loguru"  # General purpose utilities
install_package_group "web" "fastapi uvicorn jinja2" true  # Web development
install_package_group "data" "pandas numpy matplotlib seaborn" true  # Data science
install_package_group "game" "arcade pyglet" true  # Game development
install_package_group "db" "sqlalchemy alembic" true  # Database

# Setup project components
echo -e "\n${CYAN}=== Setting Up Project Components ===${NC}"
run_step "3.1" "Create sample application" "create_sample_app"
run_step "3.2" "Create Sphinx documentation" "create_sphinx_docs"
run_step "3.3" "Create GitHub Actions workflow" "create_ci_workflow"
run_step "3.4" "Update pyproject.toml with scripts" "update_pyproject"
run_step "3.5" "Create README.md" "create_readme"

# Verification steps
echo -e "\n${CYAN}=== Verifying Installation ===${NC}"
run_step "4.1" "Run tests" "run_tests" true
run_step "4.2" "Run sample application" "run_sample_app" true
run_step "4.3" "Build documentation" "build_docs" true

# --- Final Output ---
echo -e "\n${GREEN}${CHECK} ZeroStart Initialization Complete!${NC}"
cat << EOF

Next Steps:
1. ${CYAN}Verify your installation:${NC}
   poetry run pytest         # Run tests
   poetry run start          # Run the sample app
   poetry run docs           # Build docs

2. ${CYAN}Start development:${NC}
   - Add your code to src/
   - Add tests to tests/
   - Update docs in docs/

3. ${CYAN}Commit your changes:${NC}
   git add .
   git commit -m "Initialize project with ZeroStart"
   git push

Your project is now ready for GitHub CI/CD!
EOF

[project]
name = "zerostart"
version = "0.1.0"
requires-python = ">=3.13.2"