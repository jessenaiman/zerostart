#!/bin/bash
# Install documentation dependencies (optional)
set -e  # Fail on error

echo "Installing documentation dependencies..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Create docs directory and requirements file
mkdir -p docs
cat > docs/requirements-docs.txt << 'EOF'
sphinx
sphinxcontrib-mermaid
sphinx-autobuild
EOF

python -m pip install \
  sphinx \
  myst-parser \
  sphinx-autobuild \
  --root-user-action=ignore

# Verify install
python -c "
import sphinx
print('✓ sphinx installed')
print('✓ sphinx-autobuild installed')
print('✓ myst-parser installed')
"

# Set up Sphinx documentation with minimal configuration
sphinx-quickstart --quiet --sep -p "ZeroStart" -a "Jesse Naim" -v 1.0 \
  --makefile \
  --no-batchfile \
  --ext-autodoc \
  --ext-viewcode \
  --ext-coverage \
  docs

sphinx-build -M html docs/source/ docs/build/

echo "✓ Documentation dependencies installed and Sphinx setup complete"
