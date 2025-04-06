#!/bin/bash
# ZeroStart: One-Command Python Project Initialization (Current Version: Python 3.13.2)
set -euo pipefail

# Source terminal UI styling definitions (assumed to exist)
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

# Initialize Poetry project using poetry init interactively
initialize_poetry_project() {
    echo -e "\n${YELLOW}${ARROW} Step 1: Initializing Poetry project${NC}"
    # Check for existing pyproject.toml and prompt for removal
    if [ -f "pyproject.toml" ]; then
        echo -e "${YELLOW}${WARNING} Existing pyproject.toml file found.${NC}"
        read -p "Do you want to remove it and start fresh? (y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            rm pyproject.toml
            if [ $? -ne 0 ]; then
                echo -e "${RED}${CROSS} Failed to remove existing pyproject.toml file.${NC}"
                exit 1
            fi
            echo -e "${GREEN}${CHECK} Removed existing pyproject.toml file.${NC}"
        else
            echo -e "${RED}${CROSS} Cannot proceed with existing pyproject.toml file. Please remove it manually or edit it.${NC}"
            exit 1
        fi
    fi

    # Run poetry init interactively, passing terminal control to the user
    echo -e "${CYAN}Please provide the project details for poetry init. Follow the prompts below:${NC}"
    poetry init
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${CHECK} Initialized Poetry project using poetry init${NC}"
    else
        echo -e "${RED}${CROSS} Failed to initialize Poetry project${NC}"
        echo -e "${YELLOW}${WARNING} Please check the error above. You may need to run 'poetry init' manually to debug.${NC}"
        exit 1
    fi
}

# Create standard project directories
create_project_structure() {
    echo -e "\n${YELLOW}${ARROW} Step 2: Creating standard project directories${NC}"
    mkdir -p src tests
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${CHECK} Created src/ and tests/ directories${NC}"
    else
        echo -e "${RED}${CROSS} Failed to create project directories${NC}"
        exit 1
    fi
}

# Display a header for each package group installation
header() {
    echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CYAN}┃ Installing $1 Packages${NC}"
    echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

# Install a group of packages with detailed feedback
# Args:
#   $1: Group name (e.g., "core", "dev").
#   $2: Group description.
#   $3: Space-separated list of packages.
#   $4: Space-separated list of package descriptions (in the same order as packages).
install_package_group() {
    local group=$1
    local group_desc=$2
    local packages=$3
    local pkg_descs=$4

    header "$group"
    echo -e "${CYAN}# $group ecosystem: $group_desc${NC}"
    echo -e "Packages:"

    # Display package descriptions
    local pkg_array=($packages)
    local desc_array=($pkg_descs)
    for i in "${!pkg_array[@]}"; do
        echo -e "  • ${pkg_array[$i]}: ${desc_array[$i]}"
    done
    echo

    # Install each package individually with verbose output
    for pkg in $packages; do
        if [ -z "$pkg" ]; then
            continue
        fi
        echo -e "${YELLOW}${ARROW} Installing $pkg${NC}"
        echo -e "${CYAN}Running: poetry add --group $group $pkg --verbose${NC}"
        if ! poetry add --group "$group" "$pkg" --verbose; then
            echo -e "${RED}${CROSS} Failed to install $pkg${NC}"
            echo -e "${YELLOW}${WARNING} Please check the error above for details. You may need to: ${NC}"
            echo -e "  - Verify your network connection"
            echo -e "  - Check for package compatibility with Python 3.13.2"
            echo -e "  - Run the command manually to debug: poetry add --group $group $pkg --verbose"
            exit 1
        fi
        echo -e "${GREEN}${CHECK} Successfully installed $pkg${NC}"
        echo
    done
}

# Set up Sphinx documentation
setup_documentation() {
    echo -e "\n${YELLOW}${ARROW} Setting up Sphinx documentation${NC}"

    # Extract project name and author from pyproject.toml
    project_name=$(grep '^name = ' pyproject.toml | cut -d'"' -f2)
    author=$(grep '^authors = ' pyproject.toml | cut -d'"' -f2 | cut -d'<' -f1 | xargs)

    # Use sphinx-quickstart as per official documentation
    # Reference: https://www.sphinx-doc.org/en/master/usage/quickstart.html
    echo -e "${YELLOW}${ARROW} Running sphinx-quickstart${NC}"
    mkdir -p docs
    cd docs
    # Non-interactive sphinx-quickstart with values from pyproject.toml
    echo -e "n\n${project_name}\n${author}\n0.1.0\nen\n" | poetry run sphinx-quickstart --verbose
    cd ..

    # Build initial HTML documentation
    echo -e "${YELLOW}${ARROW} Building initial HTML documentation${NC}"
    poetry run make -C docs html --verbose

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${CHECK} Sphinx documentation setup completed successfully!${NC}"
    else
        echo -e "${RED}${CROSS} Failed to set up Sphinx documentation${NC}"
        echo -e "${YELLOW}${WARNING} Please check the error above. You may need to run 'make -C docs html' manually to debug.${NC}"
        exit 1
    fi
}

# Define package groups, packages, and descriptions
core_packages="pydantic tomli"
core_desc="Essential packages for the project"
core_pkg_descs="Data validation and serialization Lightweight TOML parser"

dev_packages="mypy black isort flake8 pre-commit ipdb debugpy loguru ruff bandit pydocstyle interrogate"
dev_desc="Development tools for linting, formatting, and debugging"
dev_pkg_descs="Type checking Code formatting Import sorting Linting Pre-commit hooks Interactive debugging Debug protocol support Logging Linting and formatting Security linting Docstring style checking Docstring coverage"

test_packages="pytest pytest-cov hypothesis pytest-mock pytest-benchmark green"
test_desc="Testing frameworks and tools"
test_pkg_descs="Testing framework Test coverage Property-based testing Mocking for tests Benchmarking Test runner with coverage"

docs_packages="sphinx sphinx-rtd-theme myst-parser sphinx-autobuild sphinx-autodoc-typehints sphinx-copybutton"
docs_desc="Documentation generation tools"
docs_pkg_descs="Documentation generator Read the Docs theme Markdown support Auto-rebuild for docs Type hints in docs Copy button for code blocks"

diagram_packages="graphviz pylint"
diagram_desc="Tools for diagramming and advanced linting"
diagram_pkg_descs="Graph visualization Advanced linting"

ml_packages="pandas numpy matplotlib seaborn"
ml_desc="Machine learning and data analysis libraries"
ml_pkg_descs="Data manipulation Numerical computing Plotting Data visualization"

game_packages="arcade pyglet rich"
game_desc="Game development and terminal enhancement libraries"
game_pkg_descs="Game development framework Game library Terminal formatting"

data_packages="sqlalchemy alembic psycopg2"
data_desc="Database management and ORM tools"
data_pkg_descs="ORM and SQL toolkit Database migrations PostgreSQL driver"

# Main execution
show_header
check_venv

echo -e "\n${YELLOW}${ARROW} Step 1: Initializing Poetry project${NC}"
initialize_poetry_project

create_project_structure

echo -e "\n${CYAN}=== Installing Dependencies ===${NC}"
install_package_group "core" "$core_desc" "$core_packages" "$core_pkg_descs"
install_package_group "dev" "$dev_desc" "$dev_packages" "$dev_pkg_descs"
install_package_group "test" "$test_desc" "$test_packages" "$test_pkg_descs"
install_package_group "docs" "$docs_desc" "$docs_packages" "$docs_pkg_descs"
setup_documentation
install_package_group "diagram" "$diagram_desc" "$diagram_packages" "$diagram_pkg_descs"
install_package_group "ml" "$ml_desc" "$ml_packages" "$ml_pkg_descs"
install_package_group "game" "$game_desc" "$game_packages" "$game_pkg_descs"
install_package_group "data" "$data_desc" "$data_packages" "$data_pkg_descs"

echo -e "\n${GREEN}${CHECK} ZeroStart Initialization Complete!${NC}"
echo -e "\n${CYAN}🚀 Verification Steps:${NC}"
echo -e "1. ${GREEN}Check pyproject.toml:${NC} Open pyproject.toml to confirm project details and dependencies."
echo -e "2. ${GREEN}Verify package installation:${NC} Run 'poetry show --tree' to list installed packages."
echo -e "3. ${GREEN}Test Sphinx documentation:${NC} Run 'poetry run make -C docs html' to build documentation."
echo -e "\n${CYAN}🚀 Next Steps:${NC}"
echo -e "1. ${GREEN}Build docs:${NC}   poetry run make -C docs html"
echo -e "2. ${GREEN}Start coding:${NC} Add your modules to src/"
echo -e "\n${CYAN}✨ Happy Coding! ✨${NC}"
