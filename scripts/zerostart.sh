#!/bin/bash
# ZeroStart: One-Command Python Project Initialization
set -euo pipefail

source ./terminal_ui.sh

show_header

SCRIPTS=(
  "install_python.sh"
  "install_main.sh"
  "install_test.sh"
  "install_game.sh"
  "install_security.sh"
  "install_math.sh"
)

echo -e "\n${YELLOW}${ARROW} Setting up ZeroStart project${NC}"
for i in "${!SCRIPTS[@]}"; do
    script=${SCRIPTS[$i]}
    info "Running $script..."
    bash "scripts/$script" & pid=$!
    spinner "Processing $script" $pid
    wait $pid
    success "$script completed"
    progress_bar ${#SCRIPTS[@]} $((i + 1))
done

pip freeze > requirements.txt

info "Initializing git repository..."
git init
git add .
git commit -m "Initial ZeroStart setup" || success "No files to commit yet; git initialized"

# info "Setting up pre-commit hooks..."
# pre-commit install
# pre-commit run --all-files || error "Pre-commit checks failed; review .pre-commit-config.yaml"

success "ZeroStart Initialization Complete!"
echo -e "${CYAN}Next Steps:${NC}"
echo -e "- Build docs: make -C docs html"
echo -e "- Run tests: pytest"
echo -e "- Push to GitHub: git push origin main"
