#!/bin/bash
# Generate a configuration file listing installed packages
set -e  # Fail on error

echo "Generating configuration file..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Create a temporary Python script to list installed packages
cat > /tmp/list_packages.py << 'EOF'
import json
import pkg_resources

packages = {pkg.key: pkg.version for pkg in pkg_resources.working_set}
with open('config.json', 'w') as f:
    json.dump({"installed_packages": packages}, f, indent=2)
EOF

# Run the script to generate config.json
python /tmp/list_packages.py

# Clean up
rm /tmp/list_packages.py

echo "✓ Configuration file (config.json) generated with installed packages"