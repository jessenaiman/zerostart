# ZeroStart

A Python project starting template.

## Setup

1. Create and activate a virtual environment:
   - `python3.13 -m venv .venv`
   - `source .venv/Scripts/activate` (Windows) or `source .venv/bin/activate` (Linux/MacOS)
2. Run `bash setup_project.sh` to set up the project with core dependencies (main, dev, test).
3. (Optional) Install additional dependencies as needed:
   - `bash scripts/install_documentation.sh` for documentation tools (Sphinx).
   - `bash scripts/install_database.sh` for database support (SQLite with SQLAlchemy).
   - `bash scripts/install_math.sh` for math/physics packages (NumPy).
   - `bash scripts/install_game.sh` for game development packages (Arcade).
   - `bash scripts/install_security.sh` for security tools (Bandit).
4. Run `bash scripts/run_app.sh` to start the application.
5. Run `bash scripts/run_tests.sh` to execute tests.
