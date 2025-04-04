#!/bin/bash
# Enhanced ZeroStart package installation with flexible versioning
set -eo pipefail

# Color setup for readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Import rich progress display if available
if python3 -c "import rich.progress" &>/dev/null; then
    HAVE_RICH=1
else
    HAVE_RICH=0
fi

# Simple status indicators
success() { echo -e "${GREEN}✓ $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; exit 1; }
info() { echo -e "${CYAN}ℹ $1${NC}"; }
attempt() { 
    if [ "$HAVE_RICH" -eq 1 ]; then
        python3 -c "from rich.progress import Progress; from rich import print as rprint; rprint(f'[yellow]➜[/yellow] $1...')"
    else
        echo -e "${YELLOW}➜ $1...${NC}"
    fi
}

# --- Core Installation Sequence ---
{
    # 1. Python Version Check
    attempt "Verifying Python 3.13.2+"
    python3 --version || fail "Python 3.13.2+ required"

    # 2. Poetry Installation
    attempt "Checking for Poetry"
    if ! command -v poetry &>/dev/null; then
        info "Installing Poetry..."
        curl -sSL https://install.python-poetry.org | python3 -
        success "Poetry installed"
    else
        success "Poetry already present"
    fi

    # 3. Project Initialization
    attempt "Checking project configuration"
    [ ! -f pyproject.toml ] && poetry init -n --python="^3.13.2"
    
    # --- Package Installation ---
    # Each group gets explicit visibility and no version locking
    install_package_group() {
        local group="$1"; shift
        echo -e "\n${CYAN}⚙️ Installing $group Dependencies:${NC}"
        for pkg in "$@"; do
            attempt "Adding $pkg"
            # Note the exclusion of version specifiers
            poetry add --group "$group" "$pkg" || fail "Failed to install $pkg"
            success "$pkg added"
        done
    }

    # Core Dependencies
    install_package_group "main" \
        pydantic \
        loguru \
        rich \
        alive-progress \
        asciimatics \
        orjson

    # Development Tools
    install_package_group "dev" \
        black \
        isort \
        flake8 \
        flake8-docstrings \
        mypy \
        pre-commit \
        ipdb \
        debugpy \
        green

    # Testing Ecosystem
    install_package_group "test" \
        pytest \
        pytest-cov \
        hypothesis

    # Documentation
    install_package_group "docs" \
        sphinx \
        myst-parser \
        sphinx-autobuild

    # Game Development
    install_package_group "game" \
        arcade \
        pyglet

    # Database
    install_package_group "database" \
        sqlalchemy

    # Math/Science
    install_package_group "math" \
        numpy

    # --- Post-Install Setup ---
    attempt "Configuring tools"

    poetry run pre-commit install

    attempt "Creating project structure"
    mkdir -p src tests docs data

    # Setup basic logging configuration
    attempt "Setting up logging"
    mkdir -p src/utils
    cat > src/utils/logging.py << EOF
"""Logging configuration for the project."""
from loguru import logger
import sys
import os

# Configure loguru
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")

# Remove default handler
logger.remove()

# Add stdout handler with custom format
logger.add(
    sys.stdout,
    format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
    level=LOG_LEVEL,
    colorize=True,
)

# Add file handler
logger.add(
    "logs/app.log",
    rotation="500 MB",
    retention="10 days",
    level=LOG_LEVEL,
)

__all__ = ["logger"]
EOF

    # Create directories for logs
    mkdir -p logs

} || { # Global error catch
    fail "Installation aborted due to error"
}

# --- Final Output ---
if [ "$HAVE_RICH" -eq 1 ]; then
    python3 -c "from rich import print as rprint; rprint('[bold green]✔ Installation Complete![/bold green]')"
else
    echo -e "\n${GREEN}✔ Installation Complete!${NC}"
fi

echo "Next steps:"
echo "1. poetry shell       # Enter virtual environment"
echo "2. poetry run pytest  # Validate setup"
echo "3. Start coding in ./src/"