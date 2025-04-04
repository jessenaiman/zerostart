#!/bin/bash
# Guaranteed package inclusion from original zerostart.sh

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
install_package_group "web" \
    fastapi \
    uvicorn \
    jinja2 \
    --optional true

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