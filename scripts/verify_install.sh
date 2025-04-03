#!/bin/bash
# Verify Arcade and SQLite installations
set -e  # Exit on error

echo "Verifying installations..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not activated. Please run 'source .venv/Scripts/activate' (Windows) or 'source .venv/bin/activate' (Linux/MacOS) first."
    exit 1
fi

# Verify Arcade (optional)
if python -c "import arcade" 2>/dev/null; then
    echo "Verifying Arcade:"
    python -c "import arcade; print(arcade.__version__); arcade.open_window(600, 600, 'Test'); arcade.set_background_color(arcade.color.WHITE); arcade.run()" &
    ARCADE_PID=$!
    sleep 2  # Give Arcade window time to open
    kill $ARCADE_PID 2>/dev/null || true  # Close the window
else
    echo "⚠ Arcade not installed. Run 'bash scripts/install_game.sh' to install game development tools."
fi

# Verify SQLite (optional)
if python -c "import sqlalchemy" 2>/dev/null; then
    echo "Verifying SQLite:"
    python -c "import sqlalchemy as sa; e = sa.create_engine('sqlite:///data/omega_project.db'); c = e.connect(); print(c.execute(sa.text('SELECT sqlite_version();')).scalar()); c.close()"
else
    echo "⚠ SQLAlchemy not installed. Run 'bash scripts/install_database.sh' to install."
fi

echo "✓ Installations verified"