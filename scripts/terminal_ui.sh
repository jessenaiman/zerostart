#!/bin/bash
set -euo pipefail

# Terminal UI styling definitions for ZeroStart scripts.
# This script provides reusable color codes, symbols, header display, and enhanced terminal output using Rich and alive-progress.

# Colors and Symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'
ARROW="➜"
CHECK="✓"
CROSS="❌"
WARNING="⚠️"

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
    echo -e "${GREEN}One-Command Python Project Initialization${NC}"
    echo
}

# Display a package installation progress bar.
# Args:
#   $1: Package name being installed.
#   $2: Total number of packages in the group.
#   $3: Current package index (1-based).
function install_with_progress() {
    local pkg=$1
    local total=$2
    local current=$3

    echo -e "${CYAN}Installing $pkg... [$current/$total]${NC}"
    # Simulate installation time with a simple dot animation
    for i in {1..3}; do
        echo -n "."
        sleep 0.3
    done
    echo -e "${NC}"
}