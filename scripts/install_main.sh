#!/bin/bash
set -e
source scripts/terminal_ui.sh

info "Installing main application dependencies..."
PACKAGES=("pydantic"
  "mypy"
  "importlib"
  "pydantic"
  "loguru"
  "pylint"
  "flake8"
  "black"
  "isort"
  "ruff"
  )
python scripts/install_packages.py "${PACKAGES[@]}" & pid=$!
spinner "Installing packages..." $pid
wait $pid
success "Main application dependencies installed"
