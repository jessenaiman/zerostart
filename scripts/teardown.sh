#!/bin/bash
# Safe project reset that preserves key directories and provides detailed feedback
set -euo pipefail

# Colors and Symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'
CHECK="✓"
WARNING="⚠️"
INFO="ℹ️"
ARROW="➜"

echo -e "${RED}========================================"
echo "  ZeroStart Project Teardown"
echo -e "========================================${NC}"
echo -e "${YELLOW}This will remove generated files while preserving key project directories${NC}"
echo -e "${BLUE}${INFO} Purpose: Clean up temporary files without disrupting project structure${NC}"

# Confirm before proceeding
echo -e "\n${RED}${WARNING} WARNING: This will delete generated files but keep essential directories.${NC}"
echo -e "${YELLOW}Preserved directories: src, tests, docs, data, .github/workflows, scripts${NC}"
echo -e "${MAGENTA}Are you sure you want to continue? [y/N]${NC}"
read -r response
if [[ ! "$response" =~ ^[yY]$ ]]; then
    echo -e "${GREEN}${CHECK} Teardown cancelled. Your project remains intact.${NC}"
    exit 0
fi

# Backup scripts directory
SCRIPTS_BACKUP_DIR=".scripts_backup_$(date +%s)"
if [ -d "scripts" ]; then
    echo -e "\n${YELLOW}${ARROW} Backing up scripts directory${NC}"
    echo -e "${BLUE}${INFO} Copying all scripts to temporary backup: $SCRIPTS_BACKUP_DIR${NC}"
    mkdir -p "$SCRIPTS_BACKUP_DIR"
    cp -r scripts/* "$SCRIPTS_BACKUP_DIR"/ 2>/dev/null || true
    echo -e "${GREEN}${CHECK} Scripts successfully backed up${NC}"
fi

# Deactivate virtual environment if active
if [ -n "${VIRTUAL_ENV:-}" ]; then
    echo -e "\n${YELLOW}${ARROW} Deactivating virtual environment${NC}"
    echo -e "${BLUE}${INFO} Current environment: $VIRTUAL_ENV${NC}"
    deactivate 2>/dev/null || true
    echo -e "${GREEN}${CHECK} Virtual environment deactivated${NC}"
fi

# Remove generated content while preserving key directories
echo -e "\n${YELLOW}${ARROW} Removing generated content${NC}"
echo -e "${BLUE}${INFO} Preserving: .git, src, tests, docs, data, .github/workflows, scripts${NC}"

# List of directories and files to preserve
preserve_list=(".git" "src" "tests" "docs" "data" ".github/workflows" "scripts" "$SCRIPTS_BACKUP_DIR" "teardown.sh")

# Build find command to exclude preserved paths
find_args=(".")
for path in "${preserve_list[@]}"; do
    if [ -e "$path" ]; then
        find_args+=("!" "-path" "./$path/*" "!" "-path" "./$path")
    fi
done

# List items to be removed
echo -e "${CYAN}Items scheduled for removal:${NC}"
find "${find_args[@]}" -mindepth 1 -maxdepth 1 | sort | while read -r item; do
    if [ -d "$item" ]; then
        echo -e "  ${MAGENTA}[DIR]  $item${NC}"
    elif [ -f "$item" ]; then
        echo -e "  ${BLUE}[FILE] $item${NC}"
    fi
done

# Perform the removal
echo -e "\n${YELLOW}${ARROW} Executing cleanup...${NC}"
find "${find_args[@]}" -mindepth 1 -delete
echo -e "${GREEN}${CHECK} Generated content removed${NC}"

# Clean up empty directories outside preserved paths
echo -e "\n${YELLOW}${ARROW} Cleaning up empty directories${NC}"
find . -type d -empty -not -path "./src/*" -not -path "./tests/*" -not -path "./docs/*" \
    -not -path "./data/*" -not -path "./.github/workflows/*" -not -path "./scripts/*" \
    -not -path "./.git/*" -delete 2>/dev/null || true
echo -e "${GREEN}${CHECK} Empty directories cleaned${NC}"

# Restore scripts directory
if [ -d "$SCRIPTS_BACKUP_DIR" ]; then
    echo -e "\n${YELLOW}${ARROW} Restoring scripts directory${NC}"
    echo -e "${BLUE}${INFO} Moving scripts back from $SCRIPTS_BACKUP_DIR${NC}"
    mkdir -p scripts
    cp -r "$SCRIPTS_BACKUP_DIR"/* scripts/ 2>/dev/null || true
    find scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    rm -rf "$SCRIPTS_BACKUP_DIR"
    echo -e "${GREEN}${CHECK} Scripts restored with executable permissions${NC}"
fi

echo -e "\n${GREEN}${CHECK} Project reset complete!${NC}"
echo -e "${BLUE}${INFO} Preserved structure ready for development${NC}"
echo -e "${CYAN}Next step: Run ${MAGENTA}./scripts/zerostart.sh${NC} to reinitialize dependencies${NC}"