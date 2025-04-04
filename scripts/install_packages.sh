#!/bin/bash
# Comprehensive package installer with clear output.
# This script installs Python packages for various development categories using Poetry.
# Package purposes are displayed in the terminal for better visibility.
set -euo pipefail

# Source terminal UI styling definitions
source scripts/terminal_ui.sh

# Display a header for each package group installation.
header() {
  echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${CYAN}┃ ${BOLD}Installing $1 Packages${NC}${CYAN}${NC}"
  echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

# Install a group of packages with error handling and informative output.
# Args:
#   $1: Group name (e.g., "dev", "test").
#   $2: Slash-separated list of packages (e.g., "pkg1 / pkg2 / pkg3").
#   $3: Group description.
#   $4: Pipe-separated descriptions for each package (in order).
#   $5: Optional flag ("true" to continue on failure, otherwise exits).
install_package_group() {
  local group=$1
  local package_list=$2
  local group_desc=$3
  local pkg_descs=$4
  local optional=${5:-false}

  # Convert the slash-separated package list to a space-separated list.
  local packages=$(echo "$package_list" | tr '/' ' ' | tr -s ' ' | xargs)

  header "$group"
  echo -e "${CYAN}# ${group} ecosystem: ${group_desc}${NC}"
  echo
  
  local total=$(echo "$packages" | wc -w)
  local current=1
  for pkg in $packages; do
    # Skip empty entries.
    if [ -z "$pkg" ]; then
      continue
    fi
    # Extract the description for the current package.
    desc=$(echo "$pkg_descs" | cut -d'|' -f$current)
    echo -e "${YELLOW}${ARROW} Package: $pkg${NC}"
    echo -e "${YELLOW}${ARROW} Description: $desc${NC}"
    install_with_progress "$pkg" "$total" "$current"
    echo -e "${CYAN}Running: poetry add --group $group $pkg${NC}"
    if poetry add --group "$group" "$pkg"; then
      echo -e "${CHECK} ${GREEN}$pkg installed successfully${NC}"
    else
      echo -e "${CROSS} ${RED}Failed to install $pkg${NC}"
      if [ "$optional" = "true" ]; then
        echo -e "${YELLOW}${WARNING} Optional package failed, continuing...${NC}"
      else
        echo -e "${RED}${CROSS} Required package installation failed${NC}"
        exit 1
      fi
    fi
    current=$((current + 1))
  done
}

# Define package groups and their descriptions in a human-readable format.
# Core dependencies.
core_packages="
    pydantic /
    tomli /"
core_desc="Essential packages for the project."
core_pkg_descs="Data validation, serialization, and deserialization of objects, useful for settings management and API data handling | Lightweight TOML parser for reading configuration files (used as a fallback for older Python versions)"

# Development tools.
dev_packages="
    mypy /
    black /
    isort /
    flake8 /
    pre-commit /
    ipdb /
    debugpy /
    loguru /
    ruff /
    bandit /
    pydocstyle /"
dev_desc="Enhance code quality and developer experience."
dev_pkg_descs="Static type checker for Python, ensuring type safety | Code formatter for consistent style | Sorts imports automatically for better readability | Linting tool to catch style and logical errors | Manages pre-commit hooks for automated checks (e.g., linting, formatting) | Interactive debugger for Python, an enhanced version of pdb | Debugger for Visual Studio Code, enabling remote debugging | Simplified logging library with better formatting and features | Fast linter and formatter, replacing parts of flake8 and isort | Security linter to catch vulnerabilities | Checks dependencies for known vulnerabilities | Enforces docstring standards"

# Testing ecosystem.
test_packages="
    pytest /
    pytest-cov /
    hypothesis /
    pytest-mock /
    pytest-benchmark /
    green /"
test_desc="Tools for writing and running tests."
test_pkg_descs="Testing framework for writing simple and scalable tests | Measures code coverage during tests | Property-based testing library for generating test cases | Simplifies mocking in tests | Benchmarks code performance during tests | Test runner with colorful output and detailed reporting"

# Documentation tools.
docs_packages="
    sphinx /
    sphinx-rtd-theme /
    myst-parser /
    sphinx-autobuild /
    sphinx-autodoc-typehints /
    sphinx-copybutton /"
docs_desc="For generating and maintaining project documentation."
docs_pkg_descs="Documentation generator for Python projects | Read the Docs theme for Sphinx, providing a professional look | Allows writing Sphinx docs in Markdown | Automatically rebuilds docs on changes for live preview | Integrates type hints into autodoc-generated docs | Adds a copy button to code blocks in docs"

# Diagram tools.
diagram_packages="
    graphviz /
    pylint /"
diagram_desc="For generating diagrams and additional linting."
diagram_pkg_descs="Generates diagrams (e.g., dependency graphs) | Advanced linter for catching complex code issues"

# Machine Learning (ML) tools.
ml_packages="
    pandas /
    numpy /
    matplotlib /
    seaborn /"
ml_desc="For data analysis and visualization."
ml_pkg_descs="Data manipulation and analysis library | Numerical computing library for arrays and matrices | Plotting library for creating visualizations | Statistical data visualization library built on matplotlib"

# Game development tools.
game_packages="
    arcade /
    pyglet /
    rich /
    alive-progress /"
game_desc="For building games."
game_pkg_descs="Modern Python framework for 2D game development | Cross-platform windowing and multimedia library for games | Rich text and formatting library for terminal output | Displays animated progress bars in the terminal"

# Data management tools.
data_packages="
    sqlalchemy /
    alembic /
    psycopg2 /"
data_desc="For database interaction."
data_pkg_descs="ORM for database access and management | Database migration tool for SQLAlchemy | PostgreSQL adapter for Python, enabling direct database connections"

# Prompt for optional package groups
echo -e "${YELLOW}${ARROW} Optional package groups are available (diagram, ml, game, data).${NC}"
read -p "Would you like to install optional packages? (y/n): " install_optional
if [[ "$install_optional" =~ ^[Yy]$ ]]; then
    install_package_group "diagram" "$diagram_packages" "$diagram_desc" "$diagram_pkg_descs" "true"
    install_package_group "ml" "$ml_packages" "$ml_desc" "$ml_pkg_descs" "true"
    install_package_group "game" "$game_packages" "$game_desc" "$game_pkg_descs" "true"
    install_package_group "data" "$data_packages" "$data_desc" "$data_pkg_descs" "true"
else
    echo -e "${GREEN}${CHECK} Skipping optional package installation.${NC}"
fi

# Install non-optional package groups
install_package_group "core" "$core_packages" "$core_desc" "$core_pkg_descs"
install_package_group "dev" "$dev_packages" "$dev_desc" "$dev_pkg_descs"
install_package_group "test" "$test_packages" "$test_desc" "$test_pkg_descs"
install_package_group "docs" "$docs_packages" "$docs_desc" "$docs_pkg_descs"