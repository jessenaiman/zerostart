#!/bin/bash
# Comprehensive quality checks
set -eo pipefail

echo "🔄 Running Flake8..."
flake8 src tests

echo "🔄 Running MyPy..."
mypy src

echo "🔄 Running Pylint..."
pylint src --score=no

echo "🔄 Running Bandit..."
bandit -r src

echo "✅ All quality checks passed!"