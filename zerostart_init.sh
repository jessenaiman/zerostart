#!/bin/bash
# ZeroStart Initialization with Educational Checks
set -euo pipefail

# Colors and Symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
ARROW="➜"

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

function run_step() {
    echo -e "${YELLOW}${ARROW} $1${NC}"
    shift
    "$@" && echo -e "${GREEN}✓ Success${NC}" || {
        echo -e "${RED}❌ Failed${NC}"
        exit 1
    }
}

show_header

# Execution Flow
run_step "1. Bootstrap Project Structure" \
    bash scripts/setup/setup_core.sh

run_step "2. Install Poetry Dependencies" \
    bash scripts/poetry/install_poetry.sh

run_step "3. Configure IDE & Tooling" \
    bash scripts/setup/copy_configs.sh

run_step "4. Run Initial Quality Checks" \
    poetry run pre-commit run --all-files

run_step "5. Verify Runtime Environment" \
    poetry run python -c "from src.main import run_example; run_example()"

run_step "6. Execute Educational Test Suite" \
    poetry run pytest tests/test_standards.py -v \
    --tb=short \
    --color=yes \
    --strict-markers

# Final Instructions
echo -e "\n${GREEN}✓ ZeroStart Initialization Complete!${NC}"
echo -e "\nNext steps:"
echo -e "1. ${CYAN}Create your first commit:${NC}"
echo -e "   git add . && git commit -m 'feat: Initialize ZeroStart project'"
echo -e "2. ${CYAN}View CI readiness documentation:${NC}"
echo -e "   cat docs/CI_README.md"
echo -e "3. ${CYAN}Start developing:${NC}"
echo -e "   poetry run python src/main.py\n"
echo -e "\n${GREEN}✓ Setup Complete! Next steps:${NC}"
echo -e "  ➜ ${CYAN}poetry shell${NC}          # Enter virtual environment"
echo -e "  ➜ ${CYAN}poetry run pytest${NC}     # Run test suite"
echo -e "  ➜ ${CYAN}poetry run bandit -r src/${NC}  # Security scan"
echo -e "  ➜ ${CYAN}poetry run python src/main.py${NC}  # Start application\n"