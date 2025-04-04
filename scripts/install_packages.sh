#!/bin/bash
# Comprehensive package installer with clear output
set -euo pipefail

source scripts/_colors.sh  # Centralized color definitions

header() {
  echo -e "${CYAN}┌──────────────────────────────────────────┐"
  echo -e "│ ${BOLD}Installing $1 Packages${NC}${CYAN}"
  echo -e "└──────────────────────────────────────────┘${NC}"
}

install_package_group() {
  local group=$1; shift
  header "$group"
  
  for pkg in "$@"; do
    echo -e "${ARROW} ${YELLOW}Installing $pkg...${NC}"
    if poetry add --group "$group" "$pkg" > /dev/null; then
      echo -e "${CHECK} ${GREEN}$pkg installed${NC}"
    else
      echo -e "${CROSS} ${RED}Failed to install $pkg${NC}"
      [ "$optional" = "true" ] || exit 1
    fi
  done
}

# Core Development
install_package_group "dev" \
    mypy \
    black \
    isort \
    flake8 \
    flake8-docstrings \
    pre-commit \
    ipdb \
    debugpy \
    rich \
    loguru

# Testing Ecosystem
install_package_group "test" \
    pytest \
    pytest-cov \
    hypothesis \
    pytest-mock \
    pytest-benchmark \
    green

# Documentation
install_package_group "docs" \
    sphinx \
    sphinx-rtd-theme \
    myst-parser \
    sphinx-autobuild \
    sphinx-autodoc-typehints \
    sphinx-copybutton

install_package_group "diagram" \
    graphviz \
    pylint \
    --optional true

# Optional Categories
# install_package_group "web" \
#     fastapi \
#     uvicorn \
#     jinja2 \
#     --optional true

install_package_group "data" \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    --optional true

install_package_group "game" \
    arcade \
    pyglet \
    --optional true

install_package_group "db" \
    sqlalchemy \
    alembic \
    --optional true