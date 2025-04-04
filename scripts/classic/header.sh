#!/bin/bash
# Centralized header and UI terminal codes for ZeroStart scripts.
# This script defines colors, symbols, and header display functions for consistent UI across scripts.

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

# Function to display the ZeroStart header
show_header() {
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