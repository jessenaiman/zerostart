#!/bin/bash
# Generate test directory and files
set -e  # Exit on error

echo "Generating test directory and files..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Create test structure
mkdir -p tests/integration tests/unit
cd tests

cat > __init__.py << 'EOF'
"""Test suite for Omega Spiral."""
EOF

# Create test for main.py
cat > unit/test_main.py << 'EOF'
import pytest
from io import StringIO
from unittest.mock import patch
from src.omega_project.main import main

def test_main():
    with patch('sys.stdout', new=StringIO()) as mock_stdout:
        with patch('builtins.input', return_value='World'):
            main()
        output = mock_stdout.getvalue()
        assert "Hello, World!" in output
EOF

cd ..

echo "✓ Test directory and files generated"
