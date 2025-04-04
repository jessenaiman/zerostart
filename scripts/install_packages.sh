#!/bin/bash
# Script to install Python packages for various development categories using Poetry.
# Installs each package individually with a delay to ensure clear feedback.
set -euo pipefail

# Source terminal UI styling definitions
source scripts/terminal_ui.sh

# Ensure alive-progress is installed for visual feedback
if ! poetry run python -c "import alive_progress" 2>/dev/null; then
    echo -e "${YELLOW}${ARROW} Installing alive-progress for progress visualization${NC}"
    poetry add alive-progress
fi

# Display a header for each package group installation.
header() {
    echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CYAN}┃ Installing $1 Packages${NC}"
    echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

# Install a group of packages with detailed feedback.
# Args:
#   $1: Group name (e.g., "core", "dev").
#   $2: Slash-separated list of packages (e.g., "pkg1 / pkg2 / pkg3").
#   $3: Group description.
#   $4: Pipe-separated descriptions for each package (in order).
install_package_group() {
    local group=$1
    local package_list=$2
    local group_desc=$3
    local pkg_descs=$4

    # Convert the slash-separated package list to a space-separated list.
    local packages=$(echo "$package_list" | tr '/' ' ' | tr -s ' ' | xargs)

    header "$group"
    echo -e "${CYAN}# $group ecosystem: $group_desc${NC}"
    echo -e "Packages:"

    # Display package descriptions.
    local current=1
    for pkg in $packages; do
        if [ -z "$pkg" ]; then
            continue
        fi
        desc=$(echo "$pkg_descs" | cut -d'|' -f$current)
        echo -e "  • $pkg: $desc"
        current=$((current + 1))
    done
    echo

    # Install each package individually.
    for pkg in $packages; do
        if [ -z "$pkg" ]; then
            continue
        fi
        echo -e "${YELLOW}${ARROW} Installing $pkg${NC}"
        echo -e "${CYAN}Running: poetry add --group $group $pkg${NC}"
        # Run poetry add and display its output directly.
        if ! poetry add --group "$group" "$pkg"; then
            echo -e "${RED}${CROSS} Installation of $pkg failed. Please review the error above.${NC}"
            echo -e "${YELLOW}Continuing with the next package...${NC}"
        fi
        # Add a 10-second delay with a progress bar using alive-progress.
        poetry run python -c "from alive_progress import alive_bar; import time; with alive_bar(10, title='Waiting') as bar: [time.sleep(1) for _ in range(10)]; bar()"
        echo
    done
}

# Define package groups and their descriptions.
# Core dependencies.
core_packages="pydantic / tomli"
core_desc="Essential packages for the project."
core_pkg_descs="Data validation, serialization, and deserialization of objects, useful for settings management and API data handling | Lightweight TOML parser for reading configuration files (used as a fallback for older Python versions)"

# Development tools.
dev_packages="mypy / black / isort / flake8 / pre-commit / ipdb / debugpy / loguru / ruff / bandit / pydocstyle / interrogate"
dev_desc="Enhance code quality and developer experience."
dev_pkg_descs="Static type checker for Python, ensuring type safety | Code formatter for consistent style | Sorts imports automatically for better readability | Linting tool to catch style and logical errors | Manages pre-commit hooks for automated checks (e.g., linting, formatting) | Interactive debugger for Python, an enhanced version of pdb | Debugger for Visual Studio Code, enabling remote debugging | Simplified logging library with better formatting and features | Fast linter and formatter, replacing parts of flake8 and isort | Security linter to catch vulnerabilities | Enforces docstring standards | Checks docstring coverage"

# Testing ecosystem.
test_packages="pytest / pytest-cov / hypothesis / pytest-mock / pytest-benchmark / green"
test_desc="Tools for writing and running tests."
test_pkg_descs="Testing framework for writing simple and scalable tests | Measures code coverage during tests | Property-based testing library for generating test cases | Simplifies mocking in tests | Benchmarks code performance during tests | Test runner with colorful output and detailed reporting"

# Documentation tools.
docs_packages="sphinx / sphinx-rtd-theme / myst-parser / sphinx-autobuild / sphinx-autodoc-typehints / sphinx-copybutton"
docs_desc="For generating and maintaining project documentation."
docs_pkg_descs="Documentation generator for Python projects | Read the Docs theme for Sphinx, providing a professional look | Allows writing Sphinx docs in Markdown | Automatically rebuilds docs on changes for live preview | Integrates type hints into autodoc-generated docs | Adds a copy button to code blocks in docs"

# Diagram tools.
diagram_packages="graphviz / pylint"
diagram_desc="For generating diagrams and additional linting."
diagram_pkg_descs="Generates diagrams (e.g., dependency graphs) | Advanced linter for catching complex code issues"

# Machine Learning (ML) tools.
ml_packages="pandas / numpy / matplotlib / seaborn"
ml_desc="For data analysis and visualization."
ml_pkg_descs="Data manipulation and analysis library | Numerical computing library for arrays and matrices | Plotting library for creating visualizations | Statistical data visualization library built on matplotlib"

# Game development tools.
game_packages="arcade / pyglet / rich / alive-progress"
game_desc="For building games."
game_pkg_descs="Modern Python framework for 2D game development | Cross-platform windowing and multimedia library for games | Rich text and formatting library for terminal output | Displays animated progress bars in the terminal"

# Data management tools.
data_packages="sqlalchemy / alembic / psycopg2"
data_desc="For database interaction."
data_pkg_descs="ORM for database access and management | Database migration tool for SQLAlchemy | PostgreSQL adapter for Python, enabling direct database connections"

# Install all package groups.
install_package_group "core" "$core_packages" "$core_desc" "$core_pkg_descs"
install_package_group "dev" "$dev_packages" "$dev_desc" "$dev_pkg_descs"
install_package_group "test" "$test_packages" "$test_desc" "$test_pkg_descs"
install_package_group "docs" "$docs_packages" "$docs_desc" "$docs_pkg_descs"
install_package_group "diagram" "$diagram_packages" "$diagram_desc" "$diagram_pkg_descs"
install_package_group "ml" "$ml_packages" "$ml_desc" "$ml_pkg_descs"
install_package_group "game" "$game_packages" "$game_desc" "$game_pkg_descs"
install_package_group "data" "$data_packages" "$data_desc" "$data_pkg_descs"

echo -e "${GREEN}${CHECK} Dependency installation complete!${NC}"
echo -e "${YELLOW}Note: If you do not need certain packages (e.g., game or ML tools), comment them out in pyproject.toml and run 'poetry update'.${NC}"