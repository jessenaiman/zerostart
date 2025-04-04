#!/bin/bash
# Professional test runner with rich output
set -eo pipefail

source scripts/_colors.sh

echo -e "${CYAN}${BOLD}Running Test Suite${NC}"
echo -e "${CYAN}──────────────────${NC}"

if ! poetry run pytest \
  --cov=src \
  --cov-report=term-missing \
  --durations=5 \
  -v \
  tests/; then
  echo -e "\n${RED}${BOLD}❌ Tests Failed!${NC}"
  exit 1
fi

echo -e "\n${GREEN}${BOLD}✅ All Tests Passed!${NC}"