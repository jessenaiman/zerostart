#!/bin/bash
# Comprehensive test runner that fires all tools to demonstrate linting, standard checks, and safety features.
set -euo pipefail

# Source terminal UI styling definitions
source scripts/terminal_ui.sh

echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
echo -e "${CYAN}┃ ${BOLD}Running All Checks and Tests${NC}${CYAN}${NC}"
echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"

# Run Pytest for unit and integration tests
echo -e "\n${YELLOW}${ARROW} Running Pytest${NC}"
if ! poetry run pytest -v; then
    echo -e "${RED}${CROSS} Pytest failed${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Pytest passed${NC}"

# Run Ruff for linting and formatting checks
echo -e "\n${YELLOW}${ARROW} Running Ruff (linting and formatting)${NC}"
if ! poetry run ruff check .; then
    echo -e "${RED}${CROSS} Ruff linting failed${NC}"
    exit 1
fi
if ! poetry run ruff format --check .; then
    echo -e "${RED}${CROSS} Ruff formatting check failed${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Ruff checks passed${NC}"

# Run Mypy for type checking
echo -e "\n${YELLOW}${ARROW} Running Mypy (type checking)${NC}"
if ! poetry run mypy .; then
    echo -e "${RED}${CROSS} Mypy type checking failed${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Mypy checks passed${NC}"

# Run Bandit for security linting
echo -e "\n${YELLOW}${ARROW} Running Bandit (security linting)${NC}"
if ! poetry run bandit -r src/; then
    echo -e "${RED}${CROSS} Bandit security linting failed${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Bandit checks passed${NC}"

# Run Interrogate for docstring coverage
echo -e "\n${YELLOW}${ARROW} Running Interrogate (docstring coverage)${NC}"
if ! poetry run interrogate src/; then
    echo -e "${RED}${CROSS} Interrogate docstring coverage failed${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Interrogate checks passed${NC}"

# Run pre-commit hooks
echo -e "\n${YELLOW}${ARROW} Running pre-commit hooks${NC}"
if ! poetry run pre-commit run --all-files; then
    echo -e "${RED}${CROSS} Pre-commit hooks failed${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Pre-commit hooks passed${NC}"

echo -e "\n${GREEN}${CHECK} All checks and tests passed successfully!${NC}"