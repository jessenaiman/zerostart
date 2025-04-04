#!/bin/bash
# Application runner with environment checks
set -eo pipefail

source scripts/_colors.sh

# Check virtualenv
if [ -z "${VIRTUAL_ENV:-}" ]; then
  echo -e "${RED}❌ Activate virtualenv first!${NC}"
  exit 1
fi

echo -e "${CYAN}${BOLD}Launching Application${NC}"
echo -e "${CYAN}─────────────────────${NC}"

poetry run python -m src.main