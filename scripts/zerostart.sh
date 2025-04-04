#!/bin/bash
# ZeroStart: One-Command Python Project Initialization (Current Version: Python 3.13.2)
# This script runs ALL necessary setup tasks in the correct order
set -euo pipefail

# Source terminal UI styling definitions
source scripts/terminal_ui.sh

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

# Handle common errors during execution
handle_common_errors() {
    local error_output="$1"
    local step_name="$2"
    
    if echo "$error_output" | grep -q "pyproject.toml file with a project and/or a poetry section already exists"; then
        echo -e "\n${YELLOW}${WARNING} Poetry project already exists${NC}"
        echo -e "${GREEN}${CHECK} This is fine, continuing with existing pyproject.toml${NC}"
        return 0
    fi
    
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
    
    if echo "$error_output" | grep -q "Failed to install"; then
        echo -e "\n${YELLOW}${WARNING} Resolution Guide:${NC}"
        echo -e "1. Package installation failed"
        echo -e "2. Check network connection and try again"
        echo -e "3. If specific package is problematic, modify install_packages.sh to skip it"
        return 1
    fi
    
    return 1
}

# Run a step with error handling
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
        
        if handle_common_errors "$output" "$step_name"; then
            echo -e "${YELLOW}${WARNING} Continuing despite issue${NC}"
            return 0
        else
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

# Set up script permissions
setup_permissions() {
    echo -e "\n${YELLOW}${ARROW} Setting script permissions${NC}"
    chmod +x scripts/*.sh 2>/dev/null || true
    find . -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    echo -e "${GREEN}${CHECK} All scripts made executable${NC}"
}

# Install Poetry if not already installed
install_poetry() {
    echo -e "\n${YELLOW}${ARROW} Checking for Poetry${NC}"
    if ! command -v poetry &>/dev/null; then
        echo -e "${CYAN}Installing Poetry...${NC}"
        pipx install poetry
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo -e "${GREEN}${CHECK} Poetry already installed${NC}"
    fi
    
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

# Initialize Poetry project, using pyproject.toml.bak if no pyproject.toml exists
initialize_poetry_project() {
    echo -e "\n${YELLOW}${ARROW} Initializing Poetry project${NC}"
    if [ -f "pyproject.toml" ]; then
        echo -e "${GREEN}${CHECK} Using existing pyproject.toml${NC}"
    else
        if [ -f "pyproject.toml.bak" ]; then
            cp pyproject.toml.bak pyproject.toml
            echo -e "${GREEN}${CHECK} Copied pyproject.toml.bak to pyproject.toml${NC}"
        else
            echo -e "${RED}${CROSS} pyproject.toml.bak not found!${NC}"
            exit 1
        fi
    fi
}

# Set up documentation using install_sphinx.sh
setup_documentation() {
    echo -e "\n${YELLOW}${ARROW} Setting Up Professional Documentation${NC}"
    if [ -f "scripts/install_sphinx.sh" ]; then
        ./scripts/install_sphinx.sh
    else
        echo -e "${RED}${CROSS} Documentation script (install_sphinx.sh) not found!${NC}"
        echo -e "Please ensure all scripts are present in the repository. You may need to re-clone the project."
        exit 1
    fi
}

# Install dependencies using install_packages.sh
install_dependencies() {
    echo -e "\n${CYAN}=== Installing Dependencies ===${NC}"
    if [ -f "scripts/install_packages.sh" ]; then
        ./scripts/install_packages.sh
    else
        echo -e "${RED}${CROSS} Package installation script (install_packages.sh) not found!${NC}"
        echo -e "Please ensure all scripts are present in the repository. You may need to re-clone the project."
        exit 1
    fi
}

# Verify installed packages
verify_packages() {
    echo -e "\n${CYAN}🔍 Verifying Installed Packages${NC}"
    poetry show --tree || {
        echo -e "${YELLOW}⚠️ Package verification warning - check poetry.lock${NC}"
    }
}

# Update pyproject.toml with scripts
update_pyproject_scripts() {
    echo -e "\n${YELLOW}${ARROW} Updating pyproject.toml with scripts${NC}"
    poetry run python -c "
import toml

# Read existing pyproject.toml
with open('pyproject.toml', 'r') as f:
    pyproject = toml.load(f)

# Ensure tool and poetry sections exist
if 'tool' not in pyproject:
    pyproject['tool'] = {}
if 'poetry' not in pyproject['tool']:
    pyproject['tool']['poetry'] = {}
if 'scripts' not in pyproject['tool']['poetry']:
    pyproject['tool']['poetry']['scripts'] = {}

# Add scripts
scripts = pyproject['tool']['poetry']['scripts']
scripts['format'] = 'black .'
scripts['lint'] = 'ruff check .'
scripts['typecheck'] = 'mypy .'
scripts['docs:build'] = 'sphinx-build -b html docs docs/_build/html'
scripts['docs:clean'] = 'rm -rf docs/_build'
scripts['docs:serve'] = 'python -m http.server -d docs/_build/html'

# Write updated pyproject.toml
with open('pyproject.toml', 'w') as f:
    toml.dump(pyproject, f)

print('Scripts added to pyproject.toml')
"
    echo -e "${GREEN}${CHECK} Scripts added to pyproject.toml${NC}"
}

# Run all checks and instruct the user to run tests
run_tests_and_start_app() {
    echo -e "\n${CYAN}=== Running All Checks ===${NC}"
    if [ -f "scripts/run_all_checks.sh" ]; then
        ./scripts/run_all_checks.sh
    else
        echo -e "${RED}${CROSS} Check script (run_all_checks.sh) not found!${NC}"
        echo -e "Please ensure all scripts are present in the repository. You may need to re-clone the project."
        exit 1
    fi

    echo -e "\n${YELLOW}${ARROW} Starting application${NC}"
    poetry run python -m src.main || {
        echo -e "${RED}${CROSS} Failed to start application${NC}"
        exit 1
    }
    echo -e "${GREEN}${CHECK} Application started successfully${NC}"
}

# --- Main Execution ---
show_header
check_venv

# Pre-setup verification
run_step "0.1" "Verify system permissions" "setup_permissions"
run_step "0.2" "Install Poetry" "install_poetry"

# Installation Steps
run_step "1" "Create project structure" "mkdir -p src tests docs data"
run_step "2" "Initialize Poetry project" "initialize_poetry_project" true
run_step "3" "Install dependencies" "install_dependencies"
run_step "4" "Setup Documentation" "setup_documentation"
run_step "5" "Verify Installed Packages" "verify_packages"
run_step "6" "Update pyproject.toml with scripts" "update_pyproject_scripts"

# Final step: Run all checks and instruct the user to run tests
run_tests_and_start_app

# --- Final Output ---
echo -e "\n${GREEN}${CHECK} ZeroStart Initialization Complete!${NC}"
cat << EOF

${CYAN}🚀 Next Steps:${NC}
1. ${GREEN}Run tests:${NC}    poetry run pytest -v tests/
2. ${GREEN}Build docs:${NC}   poetry run docs:build
3. ${GREEN}View docs:${NC}    poetry run docs:serve
4. ${GREEN}Start coding:${NC} Add your modules to src/

${YELLOW}💡 Pro Tip:${NC} Use these quality-of-life commands:
   ${CYAN}poetry run format${NC}   - Auto-format code
   ${CYAN}poetry run lint${NC}     - Check code quality
   ${CYAN}poetry run typecheck${NC} - Verify type annotations

${CYAN}✨ Happy Coding! ✨${NC}
EOF