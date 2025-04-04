I’m truly sorry for the frustration you’ve experienced with the ZeroStart project, and I deeply appreciate your acknowledgment of my efforts to pivot and address the issues. I understand that my focus on optimization and custom output led us away from your core goal, and I’m committed to ensuring that the next steps align precisely with your needs. I also recognize that my context may be overwhelmed, and starting with a fresh instance is a good approach to reset and focus on your requirements. Below, I’ll craft a detailed prompt that you can share with a new instance to achieve your project goal, incorporating the next steps you’ve outlined and ensuring clarity about the file structure and objectives.

---

### Prompt for a New Instance

**Subject:** Finalize ZeroStart Project Setup with Detailed Package Installation Feedback Using `poetry add`

**Background:**
I am working on an open-source Python project called ZeroStart, which aims to provide a one-command initialization for Python projects using Poetry. The project has a specific structure and requirements, but previous attempts to implement the dependency installation process have not met my needs. I need a solution that prioritizes detailed, package-by-package feedback during installation to ensure compatibility and diagnose issues, without custom output strings or optimizations that obscure Poetry's native error messages. The project is nearly complete, but the installation step (Step 3 in `zerostart.sh`) needs to be revised to meet my requirements.

**Project Goal:**
The goal of ZeroStart is to create a one-command setup script (`zerostart.sh`) that initializes a Python project with the following features:
- Creates a project structure (`src/`, `tests/`, `docs/`, `data/`).
- Initializes a Poetry project using a provided `pyproject.toml` template.
- Installs dependencies in groups (`core`, `dev`, `test`, `docs`, and optional groups like `diagram`, `ml`, `game`, `data`) with detailed feedback for each package.
- Sets up Sphinx documentation.
- Runs all checks (Pytest, Ruff, Mypy, Bandit, Interrogate, pre-commit) and starts the application as the final step.

**File Structure:**
The project has the following structure, which should be understood and preserved:

- **Root Directory:**
  - `.coverage`: Coverage report file.
  - `.pre-commit-config.yaml`: Pre-commit configuration.
  - `mypy.ini`: Mypy configuration.
  - `pylint.ini`: Pylint configuration.
  - `pyproject.toml`: Poetry project configuration.
  - `pyproject.toml.bak`: A template for `pyproject.toml` (see details below).
  - `README.md`: Project documentation (currently minimal, to be expanded).
  - `ruff.toml`: Ruff configuration.

- **Folders:**
  - `.github/workflows/ci.yml`: CI configuration (currently missing, but referenced in tests).
  - `.venv/`: Virtual environment.
  - `assets/`, `benchmarks/`, `data/`, `docs/`, `vscode/`: Standard project directories.
  - `src/`:
    - `demo/`: Contains `app.py` (a demo application).
    - `game/`: Contains game-related files (`__init__.py`, `app.py`, `core.py`, `launcher.py`, `utils.py`).
    - `__init__.py`, `main.py`: Main application files.
  - `tests/`:
    - `integration/`: Contains `test_app.py` (integration tests).
    - `unit/`: Contains `test_game_engine.py`, `test_greeting.py`, `test_standards.py` (unit tests).
    - `__init__.py`: Test initialization file.
  - `scripts/`:
    - `generate_requirements.sh`, `header.sh`, `setup_game.sh`: Utility scripts (not currently used).
    - `install_packages.sh`: Script to install dependencies (needs revision).
    - `install_sphinx.sh`: Script to set up Sphinx documentation.
    - `run_all_checks.sh`: Script to run all checks (Pytest, Ruff, Mypy, etc.).
    - `run_app.sh`, `run_tests.sh`: Redundant scripts (to be removed).
    - `terminal_ui.sh`: Terminal UI styling definitions.
    - `zerostart.sh`: Main setup script.

**Current Issue:**
The current implementation of `install_packages.sh` (called in Step 3 of `zerostart.sh`) uses `poetry install --verbose` to install dependencies in groups, which installs all packages in a group at once. This approach obscures individual package errors and does not provide the granular, package-by-package feedback I need to ensure compatibility and diagnose issues. For example, when I added `pendulum` to the `core` group, it failed due to a missing `cargo` dependency, but the error was buried in a large log, making it hard to identify the specific package causing the issue. I want to revert to using `poetry add` for each package individually, with a delay between installs to ensure clear feedback.

**Requirements:**
1. **Reduce custom strings visual and text confirmations**
   - Clear all custom strings from the terminal output in `install_packages.sh` (e.g., "Installing pydantic... [1/2]", "✓ pydantic installed successfully"). Instead, rely entirely on Poetry's native output and error messages, which should be displayed directly in the terminal without suppression; the same goes for all errors during the install which must be pushed to the terminal so I can fix the project, not tinker with where we hid the install failure message.
   - Ensure that any errors (e.g., "Caused by: program not found") are explicitly shown, as they would be in a standard Poetry command, or a python failure (use the mypi or pylint to add information if possible on failures if they are system messages and not custom)

2. **Use `poetry add` with a Delay:**
   - Modify `install_packages.sh` to install each package individually using `poetry add --group <group> <package>` (e.g., `poetry add --group core pydantic`, `poetry add --group core tomli`).
   - Add a 10-second delay (and an alive visual in the terminal would be ideal) between each `poetry add` command to ensure that the installation process is not overwhelmed and that the output for each package is clearly separated in the terminal.
   - Retain the group structure (`core`, `dev`, `test`, `docs`, and optional groups `diagram`, `ml`, `game`, `data`) 
   -  the user prompt for optional groups is nice to have, so take it away and let everything install, and a final message can tell the user to comment out packages they don't want.

3. **Use `pyproject.toml.bak` as the project source of truth:**
   - The `pyproject.toml.bak` file is a template for the initial `pyproject.toml`, as suggested in a previous iteration. It contains a minimal Poetry configuration:
     ```
     [tool.poetry]
     name = "zerostart"
     version = "0.1.0"
     description = "One-command Python project initialization"
     authors = ["Jesse Naiman <jesse@example.com>"]

     [tool.poetry.dependencies]
     python = "^3.13.2"

     [build-system]
     requires = ["poetry-core>=1.0.0"]
     build-backend = "poetry.core.masonry.api"
     ```
   - For easy visual comparison add all the packages to the .bak file so I can share that file along with the install_package.sh script and you'll know instantly if something is missing.

4. **Documents: install_sphinx.sh**
- This script handles the complete documentation install, and needs to be evaluated to see if it is also suppressing error messags.

5. **Understand the File Structure and Existing Build:**
   - Ensure that the file structure (as shown above) is preserved, and understand the purpose of each file:
     - `zerostart.sh`: Main script that orchestrates the setup process.
     - `install_packages.sh`: Handles dependency installation (to be revised).
     - `install_sphinx.sh`: Sets up Sphinx documentation.
     - `run_all_checks.sh`: Runs all checks (Pytest, Ruff, Mypy, etc.).
     - `terminal_ui.sh`: Provides terminal styling (keep the header and colors
     - `src/main.py`: Main application file (a "Hello World" app).
     - `tests/`: Contains unit and integration tests.
   - These scripts all run critical tests to evaluate if the project is ready for development: `run_app.sh`, `run_tests.sh`) along with test_standards.py, test_greetings.py, and possibly test_app.py

**Additional Notes:**
- ensure that the setup script outputs all information about the install process, and that nothing is suppressed for efficiency.
- I am not concerned about performance or efficiency; my priority is to see detailed feedback for each package installation to ensure compatibility and diagnose issues immediately. 
- A 30 minute proper install is better than 50 almost perfect re-attemtped installs, 
- once a user is confident about the install on their system they can remove the wait on the timer, or even install it manually with the command line for poetry themselves. The goal is to grab the correct versions and have poetry validate each one, even if it takes a long time; which is why we should see on screen progress with packages like alive, or more color with rich
- The final step of `zerostart.sh` should run all checks (`run_all_checks.sh`) and instruct the developer to move on to trying the tests, which have a script as well run_tests.sh

**Expected Output for Step 3 (Install Dependencies):**
The terminal output for Step 3 should look like at least as good as what you see below, using `poetry add` for each package individually:

```
=== Installing Dependencies ===

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ Installing core Packages
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# core ecosystem: Essential packages for the project.
Packages:
  • pydantic: Data validation, serialization, and deserialization of objects, useful for settings management and API data handling
  • tomli: Lightweight TOML parser for reading configuration files (used as a fallback for older Python versions)

➜ Installing pydantic
poetry add --group core pydantic
Installing pydantic (2.9.2)...
[... Poetry's detailed output ...]
[... 1-second delay ...]

➜ Installing tomli
poetry add --group core tomli
Installing tomli (2.0.1)...
[... Poetry's detailed output ...]
[... 1-second delay ...]

[... similar output for dev, test, docs groups ...]
```

**Deliverables:**
1. Revised `install_packages.sh` that uses `poetry add` for each package with a 1-second delay, removes custom strings, and displays Poetry's native output.
2. Revised `zerostart.sh` that uses `pyproject.toml.bak` as the template for `pyproject.toml` if none exists.
3. Removal of redundant scripts (`generate_requirements.sh`, `header.sh`, `setup_game.sh`, `run_app.sh`, `run_tests.sh`).
4. Confirmation that the file structure is understood and preserved.

**Important Notes:**
- Do not optimize the installation process for performance or efficiency.
- Focus on providing detailed, package-by-package feedback using Poetry's native output or using python packages that are meant for outputing errors to the user on fails (no custom string errors when there are system ones)
- Ensure that the user prompt for optional groups is retained.
- Use the provided file structure and existing files as the foundation for the changes.

---

Just like I don't mind waiting for a good install base for the project, I want you to take your time evaluating the project to understand:
- the rationale (to help communicate code issues better to AI)
- to aid new developers or ML scientists who can't figure out which packages they need to load
- to be a professional grade AAA quality open source tool I can use to show employers because it's functioning in my game and ML projects.

Before submitting your first piece of code take the professional step to do a second review of the files before starting to provide solutions, as your first pass will not have all the important information. 

Please take as long as you need, and if you felt there was more to consider I'll give you more files and context for you to review.