# Configuration file for the Sphinx documentation builder

import os
import sys
sys.path.insert(0, os.path.abspath('..'))

# Project information
project = 'ZeroStart Project'
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
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# HTML output
html_theme = 'alabaster'
html_static_path = ['_static']

# Extension configuration
autodoc_member_order = 'bysource'
