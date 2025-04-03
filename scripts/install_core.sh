#!/bin/bash
# Install core dependencies including testing and documentation tools
set -e  # Fail on error

echo "Installing core dependencies..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Install with pinned versions
python -m pip install \
  arcade==3.0.2 \
  pydantic \
  SQLAlchemy \
  pytest \
  pytest-sugar \
  hypothesis \
  coverage \
  pytest-cov \
  ruff \
  mypy \
  pre-commit \
  sphinx \
  sphinxcontrib-mermaid \
  pre-commit-hooks \
  --root-user-action=ignore

# Verify install
python -c "
import arcade, pydantic, sqlalchemy, pytest, hypothesis, coverage, ruff, mypy, pre_commit, sphinx
print(f'✓ arcade {arcade.__version__}')
print(f'✓ pydantic {pydantic.__version__}')
print(f'✓ SQLAlchemy {sqlalchemy.__version__}')
print(f'✓ pytest {pytest.__version__}')
print(f'✓ hypothesis {hypothesis.__version__}')
print(f'✓ coverage {coverage.__version__}')
print('✓ pytest-cov installed')
print('✓ pytest-sugar installed')
print('✓ ruff installed')
print('✓ mypy installed')
print('✓ pre-commit installed')
print('✓ sphinx installed')
print('✓ sphinxcontrib-mermaid installed')"

echo "✓ Core dependencies installed"