#!/bin/bash
# ZeroStart Documentation Setup
# This script sets up Sphinx documentation for the project
set -euo pipefail

# Colors and Symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
ARROW="➜"; CHECK="✓"; CROSS="❌"

# Check prerequisites
if [ ! -f "pyproject.toml" ]; then
    echo -e "${RED}${CROSS} pyproject.toml not found. Are you in the project root?${NC}"
    exit 1
fi

if ! command -v poetry &> /dev/null; then
    echo -e "${RED}${CROSS} Poetry not found. Please run install_poetry.sh first${NC}"
    exit 1
fi

# Check if virtual environment is activated
if [ -z "${VIRTUAL_ENV:-}" ]; then
    echo -e "${YELLOW}${ARROW} Activating virtual environment${NC}"
    if [ -d ".venv" ]; then
        # Platform-specific activation
        if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
            source .venv/bin/activate
        elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
            source .venv/Scripts/activate
        else
            echo -e "${RED}${CROSS} Unsupported OS for auto-activation${NC}"
            echo "Please activate manually:"
            echo "  Linux/Mac: source .venv/bin/activate"
            echo "  Windows: .venv\\Scripts\\activate"
            exit 1
        fi
        echo -e "${GREEN}${CHECK} Virtual environment activated${NC}"
    else
        echo -e "${RED}${CROSS} Virtual environment not found. Run zerostart_init.sh first${NC}"
        exit 1
    fi
fi

# Install Sphinx and related dependencies
echo -e "${YELLOW}${ARROW} Installing Sphinx and documentation dependencies${NC}"
poetry add --group docs sphinx sphinx-rtd-theme myst-parser sphinx-autodoc-typehints sphinx-copybutton

# Create documentation structure
echo -e "${YELLOW}${ARROW} Creating documentation directory structure${NC}"
mkdir -p docs/{_static,_templates,api,guides,examples}
touch docs/.gitignore
echo "_build/" > docs/.gitignore

# Extract project metadata
echo -e "${YELLOW}${ARROW} Reading project metadata${NC}"
PROJECT_NAME=$(poetry version | cut -d' ' -f1)
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="ZeroStart Project"
fi

# Create Sphinx configuration
echo -e "${YELLOW}${ARROW} Creating Sphinx configuration${NC}"
cat > docs/conf.py << EOF
# Configuration file for the Sphinx documentation builder

import os
import sys
sys.path.insert(0, os.path.abspath('..'))

# Project information
project = '$PROJECT_NAME'
copyright = '2025, ZeroStart Team'
author = 'ZeroStart Team'

# General configuration
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    'sphinx.ext.intersphinx',
    'sphinx_autodoc_typehints',
    'sphinx_copybutton',
    'myst_parser',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# HTML output
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']

# Extension configuration
autodoc_member_order = 'bysource'
autodoc_typehints = 'description'
autoclass_content = 'both'
napoleon_google_docstring = True
napoleon_numpy_docstring = False
myst_enable_extensions = ['colon_fence']

# Intersphinx mapping
intersphinx_mapping = {
    'python': ('https://docs.python.org/3', None),
}
EOF

# Create index.rst
echo -e "${YELLOW}${ARROW} Creating documentation index${NC}"
cat > docs/index.rst << EOF
$PROJECT_NAME Documentation
$(printf '=' $(echo "$PROJECT_NAME Documentation" | wc -c))

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   guides/getting_started
   guides/architecture
   api/index
   examples/index

Indices and tables
=================

* :ref:\`genindex\`
* :ref:\`modindex\`
* :ref:\`search\`
EOF

# Create starter docs
echo -e "${YELLOW}${ARROW} Creating starter documentation${NC}"

# Getting started guide
cat > docs/guides/getting_started.rst << EOF
Getting Started
==============

Installation
-----------

Install the package using Poetry:

.. code-block:: bash

    # Clone the repository
    git clone https://github.com/yourusername/$PROJECT_NAME.git
    cd $PROJECT_NAME

    # Run the ZeroStart initialization
    ./zerostart_init.sh

Basic Usage
----------

This project provides a solid foundation for Python development:

.. code-block:: python

    # Example code here
    from src.core import main
    result = main.run()
    print(result)

Next Steps
---------

- Check out the :doc:\`../examples/index\` for more examples
- Explore the :doc:\`../api/index\` for detailed API documentation
EOF

# Architecture overview
cat > docs/guides/architecture.rst << EOF
Architecture Overview
===================

This document describes the high-level architecture of the project.

Components
---------

The system consists of the following main components:

1. **Core** - The central logic module
2. **API** - External interfaces
3. **Utils** - Helper functions and utilities

Project Structure
-------

.. code-block::

    $PROJECT_NAME/
    ├── src/              # Main source code
    │   ├── __init__.py
    │   ├── core/         # Core functionality
    │   ├── utils/        # Utility functions
    │   └── main.py       # Application entry point
    ├── tests/            # Test suite
    │   ├── unit/         # Unit tests
    │   └── integration/  # Integration tests
    ├── docs/             # Documentation
    ├── data/             # Data files
    ├── scripts/          # Utility scripts
    └── pyproject.toml    # Project configuration
EOF

# API index
cat > docs/api/index.rst << EOF
API Reference
===========

.. toctree::
   :maxdepth: 2

   core
   utils
EOF

# Examples index
cat > docs/examples/index.rst << EOF
Examples
=======

.. toctree::
   :maxdepth: 2

   basic
   advanced
EOF

# Basic API doc templates
cat > docs/api/core.rst << EOF
Core Module
=========

.. automodule:: src.core
   :members:
   :undoc-members:
   :show-inheritance:
EOF

cat > docs/api/utils.rst << EOF
Utilities
========

.. automodule:: src.utils
   :members:
   :undoc-members:
   :show-inheritance:
EOF

# Example templates
cat > docs/examples/basic.rst << EOF
Basic Example
===========

This is a basic example of using the project.

.. code-block:: python

    # A basic example would go here
    from src import example
    example.run()
EOF

cat > docs/examples/advanced.rst << EOF
Advanced Example
==============

This is a more advanced example of using the project.

.. code-block:: python

    # A more advanced example would go here
    from src import advanced
    
    config = {
        'param1': 'value1',
        'param2': 'value2'
    }
    
    result = advanced.process(config)
    advanced.visualize(result)
EOF

# Create a Makefile for building documentation
echo -e "${YELLOW}${ARROW} Creating documentation Makefile${NC}"
cat > Makefile << EOF
# Minimal makefile for Sphinx documentation

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = docs
BUILDDIR      = docs/_build

.PHONY: help Makefile clean

# Put it first so that "make" without argument is like "make help".
help:
	@\$(SPHINXBUILD) -M help "\$(SOURCEDIR)" "\$(BUILDDIR)" \$(SPHINXOPTS) \$(O)

clean:
	rm -rf \$(BUILDDIR)/*

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  \$(O) is meant as a shortcut for \$(SPHINXOPTS).
%: Makefile
	@\$(SPHINXBUILD) -M \$@ "\$(SOURCEDIR)" "\$(BUILDDIR)" \$(SPHINXOPTS) \$(O)
EOF

# Add documentation scripts to pyproject.toml
echo -e "${YELLOW}${ARROW} Adding documentation scripts to pyproject.toml${NC}"
# Use poetry to add the scripts
poetry run python -c "
import toml
import os

# Read existing pyproject.toml
with open('pyproject.toml', 'r') as f:
    pyproject = toml.load(f)

# Make sure tool and poetry sections exist
if 'tool' not in pyproject:
    pyproject['tool'] = {}
if 'poetry' not in pyproject['tool']:
    pyproject['tool']['poetry'] = {}
if 'scripts' not in pyproject['tool']['poetry']:
    pyproject['tool']['poetry']['scripts'] = {}

# Add documentation scripts
scripts = pyproject['tool']['poetry']['scripts']
scripts['docs:build'] = 'sphinx-build -b html docs docs/_build/html'
scripts['docs:clean'] = 'rm -rf docs/_build'
scripts['docs:serve'] = 'python -m http.server -d docs/_build/html'

# Write updated pyproject.toml
with open('pyproject.toml', 'w') as f:
    toml.dump(pyproject, f)

print('Documentation scripts added to pyproject.toml')
"

echo -e "${GREEN}${CHECK} Sphinx documentation setup completed successfully!${NC}"
echo -e "\nNext steps:"
echo -e "1. Review the generated docs structure in the 'docs/' directory"
echo -e "2. Build the documentation with: ${CYAN}poetry run docs:build${NC}"
echo -e "3. View the documentation with: ${CYAN}poetry run docs:serve${NC}"
echo -e "4. Customize the documentation to fit your project's needs"