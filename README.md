# 🚀 zerostart: Modern Python Foundation

[![Python 3.13+](https://img.shields.io/badge/python-3.13+-blue.svg)](https://www.python.org/downloads/)
[![Poetry](https://img.shields.io/badge/packaging-poetry-cyan.svg)](https://python-poetry.org/)

**Start clean. Stay modular. Scale right.**  
A batteries-removed template for serious Python projects.

## ▶️ Instant Start

```bash
# Clone & setup (Unix/WSL)
git clone https://github.com/your-repo/zerostart
cd zerostart
bash zerostart-init.sh

### Project Structure

zerostart/
├── .github/
│   └── workflows/
│       └── ci.yml
├── .vscode/
│   └── settings.json
├── config/
│   ├── pre-commit/
│   │   └── .pre-commit-config.yaml
│   ├── ruff/
│   │   └── ruff.toml
│   └── vscode/
│       └── settings.json
├── scripts/
│   ├── poetry/
│   │   ├── install_poetry.sh
│   │   ├── poetry-init.sh
│   │   └── generate_ruff_config.sh
│   ├── requirements_txt/
│   │   └── generate_requirements.py
│   ├── setup/
│   │   ├── copy_configs.sh
│   │   └── setup_core.sh
│   ├── install_main.sh
│   ├── install_game.sh
│   ├── run_app.sh
│   └── run_tests.sh
├── src/
│   └── main.py
├── tests/
│   └── test_main.py
├── .gitignore
├── LICENSE
├── pyproject.toml
├── README.md
└── zerostart-init.sh

```bash
# Install and run (from anywhere):
python -m pip install zerostart
zerostart-init my_project  # Creates new project dir
```

### What am I looking at?

Starting new projects is messy, and confusing. What you see is everything you will eventually need if you are developing a project. It doesn't matter if you're AAA or just a code tinkerer, you should value your time and effort by securing it so when it works you have it saved and locked so you can show that work off.

Stop dissapointing yourself and friends by having unexpected errors. 

Some of these might seem trivial at first, but 10 years later you'll thank yourself for doing the following:

1. Github save point. Nerds call it check in, and push, but if you think of this as a save point, it's technically the same thing.
2. Unit Testing, because isn't it nice when you know 100% if your stuff works?
3. Continuous Integration; look for the green checkmark on github to confirm that your project actually will run on multiple devices.
4. Remembering years from now that you can program, and you not only have the project you forked, but you have this repo to return to ready to help you spend zero time getting to the starting line of your code.

Here's what you do next

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
