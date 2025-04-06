#!/bin/bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Symbols
ARROW="➜"
CHECK="✓"
CROSS="❌"
WARNING="⚠"
INFO="ℹ"
SUCCESS="★"
SPINNER="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

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
    echo -e "${MAGENTA}${BOLD}"
    echo "┌────────────────────────────┐"
    echo "│ ZeroStart v0.1.0           │"
    echo "│ Python Project Starter     │"
    echo "└────────────────────────────┘"
    echo -e "${NC}"
    echo -e "${GREEN}Initializing your project...${NC}"
    echo
}

function info() {
    echo -e "${BLUE}${INFO} $1${NC}"
}

function success() {
    echo -e "${GREEN}${SUCCESS} $1${NC}"
}

function error() {
    echo -e "${RED}${CROSS} $1${NC}"
}

function spinner() {
    local msg="$1"
    local pid=$2
    local i=0
    local spin=${SPINNER}
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % ${#SPINNER} ))
        printf "\r${YELLOW}${spin:$i:1} ${msg}"
        sleep 0.1
    done
    printf "\r"
}

function progress_bar() {
    local total=$1
    local current=$2
    local width=30
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    printf "${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' ' '
    printf "] %d%%\n${NC}" $percent
}
