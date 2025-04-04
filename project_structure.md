"""
Project Structure and Configuration for a Professional Python Game Project

This document outlines the complete structure and configuration for a professional
Python game development project using ZeroStart.
"""

# Directory Structure
project_structure = """
zerostart/
├── .github/                    # GitHub configuration
│   └── workflows/              # GitHub Actions workflows
│       ├── ci.yml              # Continuous Integration
│       └── release.yml         # Release automation
├── .vscode/                    # VSCode configuration
│   ├── launch.json             # Debug configuration
│   └── settings.json           # Editor settings
├── src/                        # Source code
│   ├── game/                   # Game code
│   │   ├── assets/             # Asset management
│   │   ├── engine/             # Game engine
│   │   ├── ui/                 # User interface
│   │   └── game.py             # Main game
│   ├── utils/                  # Utilities
│   │   ├── logging.py          # Logging setup
│   │   └── config.py           # Configuration
│   └── main.py                 # Entry point
├── tests/                      # Tests
│   ├── unit/                   # Unit tests
│   ├── integration/            # Integration tests
│   └── conftest.py             # pytest configuration
├── docs/                       # Documentation
│   ├── api/                    # API documentation
│   ├── guides/                 # User guides
│   └── examples/               # Examples
├── assets/                     # Game assets
│   ├── images/                 # Images
│   ├── sounds/                 # Sound files
│   └── fonts/                  # Fonts
├── scripts/                    # Utility scripts
│   ├── install_poetry.sh       # Install Poetry
│   ├── zerostart_init.sh       # Initialize project
│   ├── install_packages.sh     # Install packages
│   ├── install_sphinx.sh       # Install documentation
│   ├── run_app.sh              # Run application
│   └── run_tests.sh            # Run tests
├── logs/                       # Log files
├── .gitignore                  # Git ignore file
├── .pre-commit-config.yaml     # Pre-commit hooks
├── pyproject.toml              # Project configuration
├── README.md                   # Project README
├── LICENSE                     # License file
└── Makefile                    # Make targets
"""

# Configuration Files

# pyproject.toml
pyproject_toml = """
[tool.poetry]
name = "zerostart-game"
version = "0.1.0"
description = "A professional Python game template"
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"
license = "MIT"
repository = "https://github.com/yourusername/zerostart-game"
packages = [{include = "src"}]

[tool.poetry.dependencies]
python = "^3.9"
pydantic = "^2.6.1"
loguru = "^0.7.2"
rich = "^13.7.0"
alive-progress = "^3.1.5"
asciimatics = "^1.15.0"
orjson = "^3.9.10"
arcade = "^2.6.17"
pyglet = "^2.0.9"
sqlalchemy = "^2.0.27"
numpy = "^1.26.3"

[tool.poetry.group.dev.dependencies]
black = "^24.1.1"
isort = "^5.13.2"
flake8 = "^7.0.0"
flake8-docstrings = "^1.7.0"
mypy = "^1.8.0"
pre-commit = "^3.6.0"
ipdb = "^0.13.13"
debugpy = "^1.8.0"
green = "^3.4.9"

[tool.poetry.group.test.dependencies]
pytest = "^8.0.0"
pytest-cov = "^4.1.0"
hypothesis = "^6.92.1"

[tool.poetry.group.docs.dependencies]
sphinx = "^7.2.6"
myst-parser = "^2.0.0"
sphinx-rtd-theme = "^1.3.0"
sphinx-autodoc-typehints = "^1.25.2"
sphinx-copybutton = "^0.5.2"
sphinx-autobuild = "^2021.3.14"

[tool.poetry.scripts]
start = "src.main:main"
docs = "sphinx-build docs docs/_build/html"

[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"

[tool.black]
line-length = 88
target-version = ['py39']
include = '\.pyi?$'

[tool.isort]
profile = "black"
line_length = 88

[tool.mypy]
python_version = "3.9"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_functions = "test_*"

[tool.interrogate]
ignore-init-method = true
ignore-init-module = true
ignore-magic = false
ignore-semiprivate = false
ignore-private = false
ignore-module = false
ignore-nested-functions = false
ignore-nested-classes = false
fail-under = 80
"""

# .pre-commit-config.yaml
pre_commit_config = """
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files

-   repo: https://github.com/psf/black
    rev: 24.1.1
    hooks:
    -   id: black

-   repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
    -   id: isort

-   repo: https://github.com/pycqa/flake8
    rev: 7.0.0
    hooks:
    -   id: flake8
        additional_dependencies: [flake8-docstrings]

-   repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
    -   id: mypy
        additional_dependencies: [types-all]

-   repo: local
    hooks:
    -   id: protect-docstrings
        name: Protect Docstrings
        entry: python scripts/protect_docstrings.py validate
        language: system
        pass_filenames: false
        always_run: true
"""

# GitHub Actions CI workflow
github_actions_ci = """
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.9, 3.10, 3.11]

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Install Poetry
      run: |
        curl -sSL https://install.python-poetry.org | python3 -
        echo "$HOME/.local/bin" >> $GITHUB_PATH
    
    - name: Install dependencies
      run: |
        poetry install
    
    - name: Lint with flake8
      run: |
        poetry run flake8 src tests
    
    - name: Check types with mypy
      run: |
        poetry run mypy src
    
    - name: Check formatting with black
      run: |
        poetry run black --check src tests
    
    - name: Check imports with isort
      run: |
        poetry run isort --check src tests
    
    - name: Test with pytest
      run: |
        poetry run pytest --cov=src tests/
    
    - name: Check docstring coverage
      run: |
        poetry run python -m pip install interrogate
        poetry run interrogate -v src
    
    - name: Build documentation
      run: |
        poetry run sphinx-build -b html docs docs/_build/html
"""

# VSCode settings
vscode_settings = """
{
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.mypyEnabled": true,
    "python.formatting.provider": "black",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false,
    "python.testing.nosetestsEnabled": false,
    "python.testing.pytestArgs": [
        "tests"
    ],
    "python.analysis.typeCheckingMode": "basic",
    "python.analysis.extraPaths": [
        "${workspaceFolder}"
    ],
    "terminal.integrated.env.linux": {
        "PYTHONPATH": "${workspaceFolder}"
    },
    "terminal.integrated.env.osx": {
        "PYTHONPATH": "${workspaceFolder}"
    },
    "terminal.integrated.env.windows": {
        "PYTHONPATH": "${workspaceFolder}"
    }
}
"""

# VSCode launch configuration
vscode_launch = """
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "justMyCode": false
        },
        {
            "name": "Python: Game",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/src/main.py",
            "console": "integratedTerminal",
            "justMyCode": false
        },
        {
            "name": "Python: Remote Attach",
            "type": "python",
            "request": "attach",
            "connect": {
                "host": "localhost",
                "port": 5678
            },
            "pathMappings": [
                {
                    "localRoot": "${workspaceFolder}",
                    "remoteRoot": "."
                }
            ],
            "justMyCode": false
        }
    ]
}
"""

# README.md
readme_md = """
# ZeroStart Game

A professional Python game development template with best practices built-in.

## Features

- ✅ Modern Python packaging with Poetry
- ✅ Comprehensive testing setup with pytest
- ✅ Code quality tools (black, isort, flake8, mypy)
- ✅ Pre-commit hooks for quality enforcement
- ✅ Sphinx documentation
- ✅ GitHub Actions CI/CD
- ✅ Docstring protection against AI removal
- ✅ Terminal-based game engine
- ✅ Rich terminal UI
- ✅ Proper logging with loguru

## Quick Start

1. Install the project:

```bash
# Clone the repository
git clone https://github.com/yourusername/zerostart-game.git
cd zerostart-game

# Run the initialization script
./scripts/zerostart_init.sh
```

2. Start the game:

```bash
poetry run start
```

3. Run tests:

```bash
poetry run pytest
```

4. Build documentation:

```bash
poetry run docs
```

## Project Structure

```
zerostart/
├── src/                  # Source code
│   ├── game/             # Game code
│   └── utils/            # Utilities
├── tests/                # Tests
├── docs/                 # Documentation
├── assets/               # Game assets
└── scripts/              # Utility scripts
```

## Development

### Setting Up Your Development Environment

We recommend using VS Code with the following extensions:
- Python
- Pylance
- Python Test Explorer
- Python Docstring Generator
- Even Better TOML

### Running in Debug Mode

1. Open the project in VS Code
2. Set breakpoints in your code
3. Press F5 or select the "Python: Game" launch configuration

### Documentation

Build the documentation:

```bash
poetry run docs
```

View the documentation by opening `docs/_build/html/index.html` in your browser.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
"""

# Main entry point
main_py = """
#!/usr/bin/env python3
\"\"\"
Main entry point for the game.

This module:
1. Configures logging
2. Parses command line arguments
3. Initializes and runs the game
\"\"\"

import sys
import argparse
from pathlib import Path

# Configure logging first
from src.utils.logging import logger

# Import game
from src.game.game import Game


def parse_args() -> argparse.Namespace:
    \"\"\"Parse command line arguments.
    
    Returns:
        Parsed arguments
    \"\"\"
    parser = argparse.ArgumentParser(description="ZeroStart Game")
    parser.add_argument(
        "--debug", 
        action="store_true", 
        help="Enable debug logging"
    )
    parser.add_argument(
        "--name", 
        type=str, 
        default="ZeroStart Adventure",
        help="Game name"
    )
    return parser.parse_args()


def main() -> int:
    \"\"\"Main entry point.
    
    Returns:
        Exit code
    \"\"\"
    # Parse arguments
    args = parse_args()
    
    # Configure logging based on debug flag
    if args.debug:
        logger.info("Debug logging enabled")
    
    # Create logs directory if it doesn't exist
    Path("logs").mkdir(exist_ok=True)
    
    try:
        # Create and run game
        game = Game(args.name)
        game.run()
        return 0
    except Exception as e:
        logger.error(f"Unhandled exception: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
"""

# Final recommendations
recommendations = """
# Additional Recommendations

1. **Package Version Management**
   - Use Poetry's dependency resolution instead of pinning versions
   - Consider using `poetry.lock` for reproducible builds
   - Update dependencies regularly with `poetry update`

2. **Testing Best Practices**
   - Aim for high test coverage (>80%)
   - Use property-based testing with Hypothesis for complex logic
   - Test edge cases and error conditions
   - Use parameterized tests for similar test cases

3. **Documentation**
   - Use Google-style docstrings for better readability
   - Document all public APIs
   - Include examples in your documentation
   - Use type hints consistently

4. **Performance Considerations**
   - Profile your code with tools like `cProfile` or `py-spy`
   - Use `orjson` for performance-critical JSON operations
   - Consider using PyPy for CPU-bound code
   - Use `numpy` for numerical operations

5. **Deployment**
   - Use GitHub Releases for versioned releases
   - Consider using PyInstaller for standalone executables
   - Include detailed release notes for each version
   - Tag releases with semantic versioning

6. **Continuous Improvement**
   - Regularly update your dependencies
   - Refactor code when it becomes complex
   - Review and improve test coverage
   - Solicit user feedback and iterate

7. **IDE Integration**
   - Configure your IDE to use the project's style settings
   - Set up debugger configurations
   - Use integrated testing tools
   - Leverage code navigation and refactoring tools
"""