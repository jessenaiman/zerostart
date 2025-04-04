#!/bin/bash
# ZeroStart Documentation Setup
# This script sets up Sphinx documentation for the project, including support for diagrams and mandatory docstrings.
set -euo pipefail

# Colors and Symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
ARROW="➜"
CHECK="✓"
CROSS="❌"

# Create documentation structure
echo -e "${YELLOW}${ARROW} Creating documentation directory structure${NC}"
if ! mkdir -p docs/{_static,_templates,api,guides,examples}; then
    echo -e "${RED}${CROSS} Failed to create documentation directories${NC}"
    exit 1
fi
if ! touch docs/.gitignore; then
    echo -e "${RED}${CROSS} Failed to create .gitignore in docs/${NC}"
    exit 1
fi
echo "_build/" > docs/.gitignore
echo -e "${GREEN}${CHECK} Documentation directory structure created${NC}"

# Extract project metadata
echo -e "${YELLOW}${ARROW} Reading project metadata${NC}"
if ! PROJECT_NAME=$(poetry version 2>/dev/null | cut -d' ' -f1); then
    echo -e "${YELLOW}${WARNING} Could not extract project name from Poetry, using default${NC}"
    PROJECT_NAME="ZeroStart"
fi
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${YELLOW}${WARNING} Project name is empty, using default${NC}"
    PROJECT_NAME="ZeroStart"
fi
echo -e "${GREEN}${CHECK} Project name set to: $PROJECT_NAME${NC}"

# Create Sphinx configuration
echo -e "${YELLOW}${ARROW} Creating Sphinx configuration${NC}"
if ! cat > docs/conf.py << EOF
# Configuration file for the Sphinx documentation builder

import os
import sys
sys.path.insert(0, os.path.abspath('..'))

# Project information
project = '$PROJECT_NAME'
copyright = '2025, Jesse Naiman'
author = 'Jesse Naiman'
release = '0.1.0'

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
    'sphinx_design',
    'sphinxcontrib.mermaid',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# HTML output
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_theme_options = {
    'style_nav_header_background': '#2980b9',
    'collapse_navigation': False,
    'titles_only': True
}

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
then
    echo -e "${RED}${CROSS} Failed to create Sphinx configuration (docs/conf.py)${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Sphinx configuration created${NC}"

# Create index.rst
echo -e "${YELLOW}${ARROW} Creating documentation index${NC}"
if ! cat > docs/index.rst << EOF
$PROJECT_NAME Documentation
$(printf '=' $(echo "$PROJECT_NAME Documentation" | wc -c))

Welcome to the official documentation for $PROJECT_NAME, a one-command Python project initialization tool. This documentation provides an overview of the project, its architecture, API reference, and examples to help you get started.

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
then
    echo -e "${RED}${CROSS} Failed to create documentation index (docs/index.rst)${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Documentation index created${NC}"

# Create starter docs
echo -e "${YELLOW}${ARROW} Creating starter documentation${NC}"

# Getting started guide
if ! cat > docs/guides/getting_started.rst << EOF
Getting Started
==============

Installation
-----------

To install and set up $PROJECT_NAME, follow these steps:

.. code-block:: bash

    # Clone the repository
    git clone https://github.com/jessnaiman/zerostart.git
    cd zerostart

    # Create and activate a virtual environment
    python -m venv .venv
    source .venv/bin/activate  # On Windows: .venv\\Scripts\\activate

    # Install dependencies and set up the project
    ./zerostart.sh

Basic Usage
----------

$PROJECT_NAME provides a solid foundation for Python development. After setup, you can run the sample application:

.. code-block:: python

    from src.main import run
    result = run()
    print(result)

Next Steps
---------

- Check out the :doc:\`../examples/index\` for more examples.
- Explore the :doc:\`../api/index\` for detailed API documentation.
- Review the :doc:\`architecture\` to understand the project's structure.
EOF
then
    echo -e "${RED}${CROSS} Failed to create getting started guide (docs/guides/getting_started.rst)${NC}"
    exit 1
fi

# Architecture overview with a high-level diagram
if ! cat > docs/guides/architecture.rst << EOF
Architecture Overview
===================

This document describes the high-level architecture of $PROJECT_NAME.

High-Level Diagram
----------------

The following diagram illustrates the main components and their interactions:

.. mermaid::

    graph TD
        A[User] -->|Runs| B[zerostart.sh]
        B --> C[Installs Dependencies]
        B --> D[Sets Up Documentation]
        B --> E[Configures Project Structure]
        C --> F[Core: pydantic, tomli]
        C --> G[Dev: mypy, black, etc.]
        C --> H[Test: pytest, pytest-cov, etc.]
        D --> I[Sphinx Documentation]
        E --> J[src/, tests/, docs/, data/]

Components
---------

The system consists of the following main components:

1. **Core** - The central logic module, handling essential functionality.
2. **API** - External interfaces for interacting with the project.
3. **Utils** - Helper functions and utilities for common tasks.

Project Structure
-----------------

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
then
    echo -e "${RED}${CROSS} Failed to create architecture overview (docs/guides/architecture.rst)${NC}"
    exit 1
fi

# API index
if ! cat > docs/api/index.rst << EOF
API Reference
============

This section provides detailed documentation for the $PROJECT_NAME API, automatically generated from the source code. All public modules, classes, and functions are documented with their docstrings.

.. note::
   $PROJECT_NAME enforces mandatory docstrings for all public code elements. If you contribute to the project, ensure your code includes comprehensive docstrings following the Google style guide.

.. toctree::
   :maxdepth: 2

   core
   utils
EOF
then
    echo -e "${RED}${CROSS} Failed to create API index (docs/api/index.rst)${NC}"
    exit 1
fi

# Examples index
if ! cat > docs/examples/index.rst << EOF
Examples
========

This section provides practical examples of using $PROJECT_NAME.

.. toctree::
   :maxdepth: 2

   basic
   advanced
EOF
then
    echo -e "${RED}${CROSS} Failed to create examples index (docs/examples/index.rst)${NC}"
    exit 1
fi

# Basic API doc templates
if ! cat > docs/api/core.rst << EOF
Core Module
===========

.. automodule:: src.core
   :members:
   :undoc-members:
   :show-inheritance:
EOF
then
    echo -e "${RED}${CROSS} Failed to create core API doc (docs/api/core.rst)${NC}"
    exit 1
fi

if ! cat > docs/api/utils.rst << EOF
Utilities
=========

.. automodule:: src.utils
   :members:
   :undoc-members:
   :show-inheritance:
EOF
then
    echo -e "${RED}${CROSS} Failed to create utils API doc (docs/api/utils.rst)${NC}"
    exit 1
fi

# Example templates
if ! cat > docs/examples/basic.rst << EOF
Basic Example
=============

This is a basic example of using $PROJECT_NAME.

.. code-block:: python

    from src.main import run
    result = run()
    print(result)
EOF
then
    echo -e "${RED}${CROSS} Failed to create basic example (docs/examples/basic.rst)${NC}"
    exit 1
fi

if ! cat > docs/examples/advanced.rst << EOF
Advanced Example
================

This is a more advanced example of using $PROJECT_NAME, demonstrating configuration and processing.

.. code-block:: python

    from src import advanced
    
    config = {
        'param1': 'value1',
        'param2': 'value2'
    }
    
    result = advanced.process(config)
    advanced.visualize(result)
EOF
then
    echo -e "${RED}${CROSS} Failed to create advanced example (docs/examples/advanced.rst)${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Starter documentation created${NC}"

# Create a Makefile for building documentation
echo -e "${YELLOW}${ARROW} Creating documentation Makefile${NC}"
if ! cat > docs/Makefile << EOF
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
then
    echo -e "${RED}${CROSS} Failed to create documentation Makefile (docs/Makefile)${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Documentation Makefile created${NC}"

# Set up docstring enforcement with interrogate
echo -e "${YELLOW}${ARROW} Setting up docstring enforcement with interrogate${NC}"
if ! poetry add --group dev interrogate > /dev/null 2>&1; then
    echo -e "${RED}${CROSS} Failed to install interrogate${NC}"
    exit 1
fi
if ! poetry run python -c "
import toml

# Read existing pyproject.toml
with open('pyproject.toml', 'r') as f:
    pyproject = toml.load(f)

# Ensure tool section exists
if 'tool' not in pyproject:
    pyproject['tool'] = {}

# Add interrogate configuration
pyproject['tool']['interrogate'] = {
    'ignore-init-method': True,
    'ignore-init-module': True,
    'ignore-magic': False,
    'ignore-semiprivate': False,
    'ignore-private': False,
    'ignore-module': False,
    'ignore-nested-functions': False,
    'ignore-nested-classes': False,
    'fail-under': 100
}

# Write updated pyproject.toml
with open('pyproject.toml', 'w') as f:
    toml.dump(pyproject, f)

print('Interrogate configuration added to pyproject.toml')
" > /dev/null 2>&1; then
    echo -e "${RED}${CROSS} Failed to configure interrogate in pyproject.toml${NC}"
    exit 1
fi
echo -e "${GREEN}${CHECK} Docstring enforcement setup complete${NC}"
echo -e "${YELLOW}Run 'poetry run interrogate src/' to check docstring coverage${NC}"

echo -e "${GREEN}${CHECK} Sphinx documentation setup completed successfully!${NC}"
echo -e "\nNext steps:"
echo -e "1. Review the generated docs structure in the 'docs/' directory"
echo -e "2. Build the documentation with: ${CYAN}poetry run docs:build${NC}"
echo -e "3. View the documentation with: ${CYAN}poetry run docs:serve${NC}"
echo -e "4. Customize the documentation to fit your project's needs"
echo -e "5. Ensure all public code has docstrings, as they are mandatory (checked by interrogate)"