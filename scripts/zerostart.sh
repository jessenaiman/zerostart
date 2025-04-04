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

function show_header() {
    clear
    echo -e "${CYAN}"
    echo "███████╗███████╗██████╗  ██████╗ ███████╗████████╗ █████╗ ██████╗ ████████╗"
    echo "╚══███╔╝██╔════╝██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝"
    echo "  ███╔╝ █████╗  ██████╔╝██║   ██║███████╗   ██║   ███████║██████╔╝   ██║   "
    echo " ███╔╝  ██╔══╝  ██╔══██╗██║   ██║╚════██║   ██║   ██╔══██║██╔══██╗   ██║   "
    echo "███████╗███████╗██║  ██║╚██████╔╝███████║   ██║   ██║  ██║██║  ██║   ██║   "
    echo "╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "${GREEN}One-Command Python Project Initialization${NC}"
    echo
}


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
    for pkg in "$@"; do
        echo -e "${YELLOW}➜ Adding $pkg...${NC}"
        poetry add --group "$group" "$pkg" || {
            echo -e "${RED}❌ Failed to install $pkg${NC}"
            [ "$optional" = true ] || exit 1
        }
        echo -e "${GREEN}✓ $pkg installed${NC}"
    done
}


# In zerostart.sh, replace create_sphinx_docs() with:
setup_documentation() {
    echo -e "\n${YELLOW}${ARROW} Setting Up Professional Documentation${NC}"
    if [ -f "scripts/install_sphinx.sh" ]; then
        ./scripts/install_sphinx.sh
    else
        echo -e "${RED}${CROSS} Documentation script not found!${NC}"
        echo -e "Get it from: https://example.com/install_sphinx.sh"
    fi
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

# Added package verification step
verify_packages() {
    echo -e "\n${CYAN}🔍 Verifying Installed Packages${NC}"
    poetry show --tree || {
        echo -e "${YELLOW}⚠️ Package verification warning - check poetry.lock${NC}"
    }
}

# --- Main Execution ---
show_header

# Check if the virtual environment is active
check_venv

# Pre-setup verification
run_step "0.1" "Verify system permissions" "setup_permissions"
run_step "0.2" "Install Poetry" "install_poetry"

# Installation Steps
run_step "1" "Create project structure" "mkdir -p src tests docs data"

# Initialize Poetry project (if not already done)
run_step "2" "Initialize Poetry project" "poetry init -n --python='^3.13.2'" true

# Install dependencies by category
echo -e "\n${CYAN}=== Installing Dependencies ===${NC}"

# Core dependencies
install_package_group "dev" "mypy black isort flake8 flake8-docstrings pre-commit ipdb debugpy"
install_package_group "test" "pytest pytest-cov hypothesis pytest-mock pytest-benchmark hypothesis green"
install_package_group "docs" "sphinx sphinx-rtd-theme sphinx-autobuild"

# Documentation Setup
echo -e "\n${CYAN}=== Professional Documentation Setup ===${NC}"
run_step "3.1" "Setup Documentation" "setup_documentation"

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
run_step "3.2" "Create Sphinx documentation" "create_sphinx_docs"
run_step "3.3" "Update pyproject.toml with scripts" "update_pyproject"

# Verification steps
echo -e "\n${CYAN}=== Verifying Installation ===${NC}"
run_step "4.1" "Run tests" "run_tests" true
run_step "4.2" "Run sample application" "run_sample_app" true
run_step "4.3" "Build documentation" "build_docs" true

# Added to main execution flow
run_step "5" "Verify Installed Packages" "verify_packages"

# --- Final Output ---
echo -e "\n${GREEN}${CHECK} ZeroStart Initialization Complete!${NC}"
cat << EOF

${CYAN}🚀 Next Steps:${NC}
1. ${GREEN}Build docs:${NC}   poetry run docs:build
2. ${GREEN}View docs:${NC}    poetry run docs:serve
3. ${GREEN}Start coding:${NC} Add your modules to src/

${YELLOW}💡 Pro Tip:${NC} Use these quality-of-life commands:
   ${CYAN}poetry run format${NC}   - Auto-format code
   ${CYAN}poetry run lint${NC}     - Check code quality
   ${CYAN}poetry run typecheck${NC} - Verify type annotations

${MAGENTA}✨ Happy Coding! ✨${NC}
EOF

[project]
name = "zerostart"
version = "0.1.0"