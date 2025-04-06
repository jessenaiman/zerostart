### Project Restart Document: ZeroStart with `pip` and Object-Oriented Design

#### Overview

The goal of this project is to create a streamlined, professional Python project initialization script (`zerostart.sh`) that uses `pip` and `requirements.txt` for dependency management, replacing the previous Poetry-based approach. The script will call an object-oriented Python script (`zerostart.py`) to handle the core logic, ensuring modularity, maintainability, and proper linting verification. The project will incorporate `pip-tools` for dependency synchronization, adjust the package list as requested, and maintain high standards for user-friendliness and professionalism.

#### Goals and Requirements

Below is a checklist of requirements, marked with a red X (✘) to indicate they are not yet completed. Each requirement will be updated to a green checkmark (✔) once implemented and verified.

- ✘ **Use `pip` and `requirements.txt` for Dependency Management**:
  - Replace Poetry with `pip` and `requirements.txt`, maintaining modularity with separate files for each package group (e.g., `requirements-core.txt`, `requirements-dev.txt`).
  - Ensure sequential package installation with verbose output, as in the previous script.

- ✘ **Integrate `pip-tools` for Dependency Synchronization**:
  - Use `pip-tools` (specifically `pip-sync`) to keep the virtual environment in sync with the `requirements.txt` files, providing a CLI command-line tool for dependency management.
  - Install `pip-tools` as part of the setup process and provide instructions for using `pip-sync`.

- ✘ **Adjust Package List**:
  - Replace `psycopg2` (or `psycopg2-binary`) in the `data` group with `sqlite` (noting that SQLite is built into Python as `sqlite3`), `toml` (for TOML parsing), and `json` (noting that JSON is built into Python as `json`).
  - Add a comment in the `requirements-core.txt` file to inform the user that `pydantic` provides JSON serialization/deserialization, so no additional JSON package is needed.

- ✘ **Object-Oriented Python Script**:
  - Create a new Python script (`zerostart.py`) with an object-oriented design to handle the core logic (project setup, package installation, Sphinx setup).
  - Ensure `zerostart.sh` calls `zerostart.py`, passing variables (e.g., project name, author) as command-line arguments.

- ✘ **Linting Verification Post-Install**:
  - Include linting tools (`flake8`, `black`, `isort`) in the `dev` group.
  - Add a post-installation step to run linting on `zerostart.py` using these tools, verifying code quality.

- ✘ **Maintain High Standards**:
  - Ensure the script provides clear, verbose feedback at each step, similar to the previous script.
  - Include verification steps to confirm the setup (e.g., check installed packages, test Sphinx documentation).
  - Create standard project directories (`src/`, `tests/`, `docs/`, `requirements/`).

#### Implementation Plan

1. **Create `zerostart.py`**:
   - Define a `ZeroStart` class to encapsulate the setup logic (e.g., methods for creating directories, generating `requirements.txt` files, installing packages, setting up Sphinx).
   - Use command-line arguments to pass the project name and author from `zerostart.sh`.

2. **Update `zerostart.sh`**:
   - Modify the script to prompt for user input (project name, author), remove any existing `pyproject.toml`, and call `zerostart.py` with the provided values.
   - Include a step to install `pip-tools` and provide instructions for using `pip-sync`.

3. **Adjust Package List**:
   - Update the `data` group to include `sqlite3` (noting it’s built-in), `toml`, and `json` (noting it’s built-in), with a comment about `pydantic`’s JSON capabilities in `requirements-core.txt`.

4. **Add Linting Verification**:
   - After package installation, run `flake8`, `black --check`, and `isort --check` on `zerostart.py` to verify code quality.

5. **Ensure User-Friendly Output**:
   - Maintain the same level of feedback (headers, success/failure messages) as the previous script.
   - Provide verification steps and next steps in the final output.

#### Next Steps

The script has been planned to meet all requirements, focusing on simplicity, modularity, and user-friendliness with `pip` and `requirements.txt`. Once you confirm the plan, I can implement the script, ensuring all requirements are met with green checkmarks (✔). Alternatively, if you’d like to roll back to a previous approach or adjust the plan, I’m here to assist.

Please review the plan and let me know if you’d like to proceed with implementation or make any changes!
