#!/bin/bash
# ZeroStart Initialization with Educational Checks
set -euo pipefail

# Colors and Symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
ARROW="➜"; CHECK="✓"; CROSS="❌"

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
}
# --- Installation Functions ---
run_step() {
    local step_num=$1
    local step_name=$2
    local step_cmd=$3
    
    echo -e "\n${YELLOW}${ARROW} Step ${step_num}: ${step_name}${NC}"
    if output=$(eval "$step_cmd" 2>&1); then
        echo -e "${GREEN}${CHECK} Success${NC}"
    else
        echo -e "\n${RED}${CROSS} Failed at step ${step_num} (${step_name})${NC}"
        echo -e "Error output:\n${output}\n"
        exit 1
    fi
}

setup_permissions() {
    echo -e "\n${YELLOW}${ARROW} Setting script permissions${NC}"
    chmod +x scripts/*.sh
    find . -name "*.sh" -exec chmod +x {} \;
    echo -e "${GREEN}${CHECK} All scripts made executable${NC}"
}

activate_venv() {
    echo -e "\n${YELLOW}${ARROW} Activating virtual environment${NC}"
    if [ ! -d ".venv" ]; then
        python3.13 -m venv .venv
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
    echo -e "${GREEN}${CHECK} Virtual environment activated${NC}"
}

# --- Main Execution ---
show_header

# Pre-setup verification
run_step "0" "Verify system permissions" \
    "setup_permissions"

run_step "0" "Activate virtual environment" \
    "activate_venv"

# Installation Steps
run_step "1" "Create project structure" \
    "mkdir -p src/{main,utils} tests/{unit,integration} docs data"

run_step "2" "Initialize Poetry project" \
    "poetry init -n --python='>=3.13'"

run_step "3" "Install core dependencies" \
    "poetry add pydantic ruff mypy pre-commit"

run_step "4" "Install development tools" \
    "poetry add --group dev pytest pytest-cov bandit"

run_step "5" "Configure quality tools" \
    "poetry run pre-commit install && poetry run pre-commit run --all-files"

run_step "6" "Verify installation" \
    "poetry run python -c \"import pydantic, ruff; print('Core imports working')\""

run_step "7" "Run test suite" \
    "poetry run pytest tests/ -v --tb=short --cov=src"

# --- Final Output ---
echo -e "\n${GREEN}${CHECK} ZeroStart Initialization Complete!${NC}"
cat << EOF

Next Steps:
1. ${CYAN}Reactivate virtual environment:${NC}
   source .venv/bin/activate  # Linux/Mac
   .venv\\Scripts\\activate    # Windows

2. ${CYAN}Run security audit:${NC}
   poetry run bandit -r src/

3. ${CYAN}Start development:${NC}
   poetry run python src/main.py

4. ${CYAN}Commit your changes:${NC}
   git add . && git commit -m "feat: Initialize project"

Project Structure:
src/       - Main application code
tests/     - Unit and integration tests
docs/      - Documentation
data/      - Data files and databases
EOF