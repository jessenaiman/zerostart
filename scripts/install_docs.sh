#!/bin/bash
# install_docs.sh - Self-contained documentation setup script
set -euo pipefail  # Strict error handling

DOCS_DIR="docs"
SPHINX_CONF="${DOCS_DIR}/source/conf.py"


# Install/upgrade core dependencies
echo "📦 Installing documentation dependencies..."
python -m pip install --upgrade pip wheel
python -m pip install \
    sphinx \
    sphinx-rtd-theme \
    myst-parser \
    sphinx-autodoc-typehints \
    sphinx-copybutton \

# Initialize documentation structure
echo "📚 Setting up Sphinx documentation..."
mkdir -p "${DOCS_DIR}/source"
cd "${DOCS_DIR}"

# Non-interactive sphinx-quickstart with essential settings
sphinx-quickstart -q --sep \
    --project "Project Name" \
    --author "Your Name" \
    -v "1.0" \
    --language "en" \
    --extensions "sphinx.ext.autodoc,sphinx.ext.napoleon" \
    --makefile --no-batchfile \
    -p "${DOCS_DIR}/source" \
    .

# Configure conf.py with modern settings
echo "⚙️  Configuring Sphinx..."
cat << 'EOF' >> source/conf.py

# Added by install script
import os
import sys
sys.path.insert(0, os.path.abspath('../..'))

extensions += [
    'sphinx_rtd_theme',
    'sphinx_copybutton',
    'myst_parser'
]

html_theme = 'sphinx_rtd_theme'
html_theme_options = {
    'navigation_depth': 4,
    'style_external_links': True
}
EOF

# Create initial documentation structure
echo "📄 Generating initial docs..."
sphinx-apidoc -o source/ ../src/  # Adjust if your code is elsewhere

# Build verification
echo "🔨 Building docs for verification..."
if ! command -v make &> /dev/null; then
    echo "⚠️  'make' command not found"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "📝 Using python directly to build docs..."
        python -m sphinx.cmd.build source build/html
    else
        echo "📥 Installing make..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y make
        elif command -v yum &> /dev/null; then
            sudo yum install -y make
        else
            echo "❌ Could not install make. Please install it manually."
            exit 1
        fi
        make html
    fi
else
    make html
fi

echo "✅ Documentation setup complete!"
echo "➤ Access docs: ${DOCS_DIR}/build/html/index.html"
echo "➤ Live rebuild: sphinx-autobuild ${DOCS_DIR}/source ${DOCS_DIR}/build/html"
