# Configuration file for the Sphinx documentation builder

import os
import sys
sys.path.insert(0, os.path.abspath('..'))

# Project information
project = 'zerostart'
copyright = '2025, Jesse Naiman'
author = 'Jesse Naiman'

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
    'sphinx_autodoc_typehints',
    'sphinx_copybutton',
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
