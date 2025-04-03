#!/bin/bash
# Clear, sequential Poetry installation with explicit error reporting

set -eo pipefail

# Color setup for readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Simple status indicators
success() { echo -e "${GREEN}✓ $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; exit 1; }
attempt() { echo -e "${YELLOW}➜ $1...${NC}"; }

# --- Core Installation Sequence ---
{
    # 1. Python Version Check
    attempt "Verifying Python 3.13+"
    python3.13 --version || fail "Python 3.13+ required"

    # 2. Poetry Installation
    attempt "Installing Poetry"
    if ! command -v poetry &>/dev/null; then
        curl -sSL https://install.python-poetry.org | python3 -
        success "Poetry installed"
    else
        success "Poetry already present"
    fi

    # 3. Project Initialization
    attempt "Creating pyproject.toml"
    [ ! -f pyproject.toml ] && poetry init -n --python=^3.13
    
    # --- Package Installation ---
    # Each group gets explicit visibility
    install_package_group() {
        local group="$1"; shift
        echo -e "\n${YELLOW}⚙️ Installing $group Dependencies:${NC}"
        for pkg in "$@"; do
            attempt "Adding $pkg"
            poetry add --group "$group" "$pkg" || fail "Failed to install $pkg"
            success "$pkg added"
        done
    }

    # Core Dev Tools
    install_package_group "dev" \
        ruff mypy bandit pre-commit pytest

    # Testing Ecosystem
    install_package_group "test" \
        pytest-cov hypothesis

    # Documentation
    install_package_group "docs" \
        sphinx myst-parser sphinx-autobuild

    # Game Development
    install_package_group "game" \
        arcade pyglet

    # Database
    install_package_group "database" \
        sqlalchemy

    # Math/Science
    install_package_group "math" \
        numpy

    # --- Post-Install Setup ---
    attempt "Configuring pre-commit hooks"
    poetry run pre-commit install
    poetry run pre-commit run --all-files

    attempt "Creating project structure"
    mkdir -p src tests docs data

} || { # Global error catch
    fail "Installation aborted due to error"
}

# --- Final Output ---
echo -e "\n${GREEN}✔ Installation Complete!${NC}"
echo "Next steps:"
echo "1. poetry shell       # Enter virtual environment"
echo "2. poetry run pytest  # Validate setup"
echo "3. Start coding in ./src/"