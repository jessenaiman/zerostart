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

    zerostart/
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
