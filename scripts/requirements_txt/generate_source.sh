#!/bin/bash
# Generate source directory and modules
set -e  # Exit on error

echo "Generating source directory and modules..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Create source directories
ROOT_DIR="src/omega_project"
mkdir -p $ROOT_DIR
cd $ROOT_DIR

cat << 'EOF' > __init__.py
"""Top-level package for Omega Spiral."""
from pathlib import Path

# Auto-detect package directory for asset loading
PACKAGE_DIR = Path(__file__).parent
EOF

# Create main application
cat > main.py << 'EOF'
"""Main entry point for Omega Spiral."""
def main():
    print("Hello, ", end="")
    user_input = input()
    print(f"Hello, {user_input}!")

if __name__ == "__main__":
    main()
EOF

# Create shared module
mkdir -p shared
cat > shared/__init__.py << 'EOF'
"""Shared utilities."""
def init():
    """Initialize shared components."""
    return {"status": "online"}

# Auto-verify import path
if __name__ == "__main__":
    print(f"{__package__} import check passed")
EOF

cat > shared/types.py << 'EOF'
"""Common types."""
from typing import NamedTuple


class Vector2(NamedTuple):
    x: float
    y: float


class RGB(NamedTuple):
    r: int
    g: int
    b: int


# Auto-verify import path
if __name__ == "__main__":
    print(f"{__package__} import check passed")
EOF

cd ../..

echo "✓ Source directory and modules generated"
