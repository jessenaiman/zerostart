#!/bin/bash
# Poetry-based Omega Spiral project setup

# - 'set -e': Exit immediately if a command exits with a non-zero status.
# - 'set -u': Treat unset variables as an error and exit immediately.
# - 'set -o pipefail': Return the exit status of the last command in the pipeline that failed.
+ set -euo pipefail # Strict mode
# Enable strict mode:

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

function log_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

function log_error() {
    echo -e "${RED}❌ $1${NC}"
}

function run_step() {
    local step_name="$1"
    local step_command="$2"
    
    echo -e "\n${YELLOW}▶ Running: ${step_name}${NC}"
    if eval "$step_command"; then
        log_success "${step_name} completed"
        return 0
    else
        log_error "${step_name} failed"
        return 1
    fi
}

echo -e "\n${GREEN}=== Setting up Omega Spiral project with Poetry ===${NC}"

# Check for Python 3.13+
run_step "Python version check" \
    "python3.13 --version || { log_error 'Python 3.13+ required'; exit 1; }"

# Install Poetry if not present
if ! command -v poetry &> /dev/null; then
    run_step "Poetry installation" \
        "curl -sSL https://install.python-poetry.org | python3 -"
else
    log_success "Poetry already installed"
fi

# Create and initialize Poetry project
if [ ! -f "pyproject.toml" ]; then
    run_step "Project initialization" \
        "cp pyproject.toml.template pyproject.toml"
else
    log_warning "pyproject.toml already exists - preserving existing file"
fi

# Function to add dependencies to a specific group
add_dependencies() {
    local group="$1"
    shift
    local deps=("$@")
    
    for dep in "${deps[@]}"; do
        run_step "Adding ${dep} to ${group}" \
            "poetry add --group ${group} ${dep}"
    done
}

# Install main dependencies
add_dependencies "main" \
    "pydantic" \
    "ruff" \
    "mypy" \
    "pre-commit" \
    "pre-commit-hooks"

# Install test dependencies
add_dependencies "test" \
    "pytest" \
    "pytest-sugar" \
    "hypothesis" \
    "coverage" \
    "pytest-cov"

# Install game dependencies
add_dependencies "game" \
    "arcade" \
    "pyglet"

# Install security dependencies
add_dependencies "security" \
    "bandit"

# Install documentation dependencies
add_dependencies "docs" \
    "sphinx" \
    "myst-parser" \
    "sphinx-autobuild"

# Install database dependencies
add_dependencies "database" \
    "SQLAlchemy"

# Install math dependencies
add_dependencies "math" \
    "numpy"

# Setup pre-commit
run_step "Pre-commit setup" \
    "poetry run pre-commit install && poetry run pre-commit run --all-files"

# Verify installations
run_step "Dependency verification" \
    "poetry run python -c \"
import pydantic, ruff, mypy, pre_commit
import arcade, pyglet, bandit, sphinx, sqlalchemy, numpy
import pytest, hypothesis, coverage
print('All imports successful')
\""

# Final setup
run_step "Project structure verification" \
    "mkdir -p src tests docs data"

log_success "\n=== Project setup complete ==="
echo -e "\nNext steps:"
echo "1. Run 'poetry shell' to activate the virtual environment"
echo "2. Run 'poetry run pytest' to execute tests"
echo "3. Run 'poetry run bandit -r src/' for security scanning"
echo "4. Run 'poetry run python src/main.py' to start the application"