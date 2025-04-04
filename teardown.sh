#!/bin/bash
# Safe project reset that preserves only scripts directory
set -euo pipefail

# Colors and Symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
CHECK="✓"; WARNING="⚠️"

echo -e "${RED}========================================"
echo "  ZeroStart Project Teardown"
echo -e "========================================${NC}"
echo -e "${YELLOW}This will remove ALL generated files but keep your scripts${NC}"

# Confirm before proceeding
echo -e "${RED}WARNING: This will delete all generated files and directories.${NC}"
echo -e "${YELLOW}Only your scripts directory will be preserved.${NC}"
echo -e "${YELLOW}Are you sure you want to continue? [y/N]${NC}"
read -r response
if [[ ! "$response" =~ ^[yY]$ ]]; then
    echo -e "${GREEN}Teardown cancelled.${NC}"
    exit 0
fi

# Backup scripts directory
SCRIPTS_BACKUP_DIR=".scripts_backup_$(date +%s)"
if [ -d "scripts" ]; then
    echo -e "\n${YELLOW}➜ Backing up scripts directory${NC}"
    mkdir -p "$SCRIPTS_BACKUP_DIR"
    cp -r scripts/* "$SCRIPTS_BACKUP_DIR"/ 2>/dev/null || true
    echo -e "${GREEN}${CHECK} Scripts backed up${NC}"
fi

# Deactivate virtual environment if active
if [ -n "${VIRTUAL_ENV:-}" ]; then
    echo -e "\n${YELLOW}➜ Deactivating virtual environment${NC}"
    deactivate 2>/dev/null || true
    echo -e "${GREEN}${CHECK} Virtual environment deactivated${NC}"
fi

# Remove everything except git directory and scripts backup
echo -e "\n${YELLOW}➜ Removing all generated content${NC}"

# First make a list of all files/directories to preserve
preserve_list=()
# Preserve .git if it exists
if [ -d ".git" ]; then
    preserve_list+=(".git")
fi
# Preserve scripts backup directory
preserve_list+=("$SCRIPTS_BACKUP_DIR")
# Preserve the teardown script itself
preserve_list+=("teardown.sh")

# Create a find command that excludes preserved paths
find_args=(".")
for path in "${preserve_list[@]}"; do
    if [ -e "$path" ]; then
        find_args+=("!" "-path" "./$path/*" "!" "-path" "./$path")
    fi
done

# Remove everything except what we want to preserve
# First list what will be removed
echo -e "${YELLOW}The following will be removed:${NC}"
find "${find_args[@]}" -mindepth 1 -maxdepth 1 | sort | sed 's/^/  /'

# Do the actual removal
find "${find_args[@]}" -mindepth 1 -delete

# Clean up any potentially empty directories
find . -type d -empty -delete 2>/dev/null || true

# Restore scripts directory
if [ -d "$SCRIPTS_BACKUP_DIR" ]; then
    echo -e "\n${YELLOW}➜ Restoring scripts directory${NC}"
    mkdir -p scripts
    cp -r "$SCRIPTS_BACKUP_DIR"/* scripts/ 2>/dev/null || true
    # Make scripts executable
    find scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    # Remove backup
    rm -rf "$SCRIPTS_BACKUP_DIR"
    echo -e "${GREEN}${CHECK} Scripts restored${NC}"
fi

echo -e "\n${GREEN}${CHECK} Project reset complete!${NC}"
echo -e "Only the scripts directory has been preserved."
echo -e "To recreate the project, run: ${CYAN}./scripts/zerostart.sh${NC}"