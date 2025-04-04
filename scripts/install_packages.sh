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
    attempt "Verifying Python 3.9+"
    python3 --version || fail "Python 3.9+ required"

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
    [ ! -f pyproject.toml ] && poetry init -n --python="^3.9"
    
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
    
    # Setup Black configuration
    cat > pyproject.toml << EOF
[tool.black]
line-length = 88
target-version = ['py39']
include = '\.pyi?$'

[tool.isort]
profile = "black"
line_length = 88

[tool.mypy]
python_version = "3.9"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_functions = "test_*"

[tool.poetry.scripts]
start = "src.main:main"
EOF

    # Setup pre-commit hooks
    attempt "Configuring pre-commit hooks"
    cat > .pre-commit-config.yaml << EOF
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files

-   repo: https://github.com/psf/black
    rev: 24.1.1
    hooks:
    -   id: black

-   repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
    -   id: isort

-   repo: https://github.com/pycqa/flake8
    rev: 7.0.0
    hooks:
    -   id: flake8
        additional_dependencies: [flake8-docstrings]

-   repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
    -   id: mypy
        additional_dependencies: [types-all]
EOF

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