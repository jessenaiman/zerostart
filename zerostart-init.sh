#!/bin/bash
# Setup the Omega Spiral project by calling individual scripts
set -e  # Exit on error

echo "Setting up Omega Spiral project..."
echo "Note: Ensure your virtual environment is activated before running this script."

# Array of scripts to run (including optional ones)
SCRIPTS=(
  "install_python.sh"
  "install_main.sh"
  "install_test.sh"
  "install_documentation.sh"
  "install_database.sh"
  "install_math.sh"
  "install_game.sh"
  "install_security.sh"
  "generate_project_files.sh"
  "generate_source.sh"
  "generate_tests.sh"
  "verify_imports.sh"
  "verify_structure.sh"
  "verify_install.sh"
  "setup_precommit.sh"
  "generate_config.sh"
)

# Run each script and verify
for script in "${SCRIPTS[@]}"; do
  echo "Running scripts/$script..."
  if bash "scripts/$script"; then
    echo "✓ scripts/$script completed successfully"
  else
    echo "❌ scripts/$script failed"
    exit 1
  fi
done

echo "✓ Project setup complete"
echo "Next steps:"
echo "- Run 'bash scripts/run_app.sh' to start the application."
echo "- Run 'bash scripts/run_tests.sh' to execute tests."
