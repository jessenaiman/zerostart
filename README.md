# ⚡ zerostart: The Clean-Slate Python Template

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PyPI Version](https://img.shields.io/pypi/v/zerostart)](https://pypi.org/project/zerostart/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/your-repo/zerostart/blob/main/CONTRIBUTING.md)

**zerostart** is a no-legacy Python template that lets you **start fresh** and **add only what you need**.  
Perfect for prototypes, packages, or experiments—without the boilerplate tax.

### Project Structure

omega_spiral/
├── scripts/
│   ├── install_python.sh
│   ├── install_main.sh
│   ├── install_dev.sh
│   ├── install_test.sh
│   ├── install_documentation.sh
│   ├── install_database.sh
│   ├── install_math.sh
│   ├── install_game.sh
│   ├── install_security.sh
│   ├── generate_project_files.sh
│   ├── generate_source.sh
│   ├── generate_tests.sh
│   ├── verify_imports.sh
│   ├── verify_structure.sh
│   ├── verify_install.sh
│   ├── setup_precommit.sh
│   ├── run_app.sh
│   ├── run_tests.sh
├── setup_project.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── .gitignore
├── .pre-commit-config.yaml
├── LICENSE
├── README.md
├── src/
│   └── omega_project/
│       ├── __init__.py
│       ├── main.py
│       └── shared/
│           ├── __init__.py
│           └── types.py
├── tests/
│   ├── __init__.py
│   ├── integration/
│   └── unit/
│       └── test_main.py
└── .venv/  


```bash
# Install and run (from anywhere):
python -m pip install zerostart
zerostart-init my_project  # Creates new project dir
```

---

## 🧹 Start Fresh (When Needed)
Need to reset? Run:
```bash
# Wipe generated files (except configs):
zerostart-clean

# Full nuclear reset (delete everything):
zerostart-nuke --confirm
```
*Safety: Prompts for confirmation before deleting.*

---

## 🌟 Why zerostart?
| Feature          | Description                                  | Customize?          |
|------------------|----------------------------------------------|---------------------|
| **Modular Scripts** | Enable/disable features (game, math, etc.)  | `scripts/*.sh`      |
| **Pre-Configured**  | Ruff, pytest, Sphinx, mypy out-of-the-box   | `pyproject.toml`    |
| **Cross-Platform**  | WSL, Windows, Linux tested                  | `scripts/adapters/` |
| **Zero Legacy**     | No hidden files—delete and restart cleanly  | N/A                 |

---

## 🛠️ Quick Start
1. **Initialize**:
   ```bash
   zerostart-init my_project --no-game --enable-math
   ```
2. **Build**:
   ```bash
   cd my_project
   bash scripts/run_tests.sh  # Verify setup
   ```
3. **Customize**:
   - Add scripts to `scripts/custom/` (auto-loaded)
   - Edit `zerostart-config.json` to enable features

---

## 🔄 Workflow: Add Your Own Module
1. Create a new script:
   ```bash
   echo '#!/bin/bash
   echo "📦 Adding Kubernetes config..."
   mkdir -p k8s/
   cat > k8s/deployment.yaml << EOF
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: {{PROJECT_NAME}}
   EOF
   ' > scripts/custom/generate_k8s.sh
   ```
2. Make it executable:
   ```bash
   chmod +x scripts/custom/generate_k8s.sh
   ```
3. **Contribute back?**  
   Submit a PR to our [community scripts](https://github.com/your-repo/zerostart/tree/main/scripts/_shared)!

---

## 📜 License
MIT License - **Your contributions remain yours**.  
Attribution appreciated but not required.
```